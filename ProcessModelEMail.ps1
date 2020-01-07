#Definizione Parametri
param(
    [Parameter(Mandatory=$true)][string]$AutomationAccountName,
    [Parameter(Mandatory=$true)][string]$AnalysisServerName,
    [Parameter(Mandatory=$true)][string]$ASDatabaseName
)
Import-Module SqlServer
try
{
    $resourceGroupName = 'AlpitourDwhPaasProd'
    $ServiceLevelUp = 'S2'
    $ServiceLevelDown = 'S0'
    $asServerName = 'alpitouraas'
    $serverName = 'alpitour-dwh'
    $poolName = 'Alpitour-DWH-Pool'
    # Open the SQL connection
    # Get the service principal credentials connected to the automation account. 
    $null = $SPCredential = Get-AutomationPSCredential -Name "Cred_AlpitourAS"
    # Connect to a connection to get TenantId and SubscriptionId
    $Connection = Get-AutomationConnection -Name "AzureRunAsConnection"
    $TenantId = $Connection.TenantId
    $SubscriptionId = $Connection.SubscriptionId 
    # Login to Azure ($null is to prevent output, since Out-Null doesn't work in Azure)
    Write-Output "Login to Azure using automation account 'Cred_AlpitourAS'."
    $null = Login-AzureRmAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -Credential $SPCredential
    # Scale UP AS
    Write-Output "Scaling UP $($asServerName) to $($ServiceLevelUp)"
    $null = Set-AzureRmAnalysisServicesServer -ResourceGroupName $resourceGroupName -Name $asServerName -Sku $ServiceLevelUp
    # Output final status message 
    Write-Output "$($asServerName) scaled to $($ServiceLevelUp)" 

    # Process cube 
    # Select the correct subscription
    Write-Output "Selecting subscription '$($SubscriptionId)'."
    $null = Select-AzureRmSubscription -SubscriptionID $SubscriptionId
    Write-Output "Processing $ASDatabaseName on $($AnalysisServerName)"
    #Process database
    $null = Invoke-ProcessASDatabase -databasename $ASDatabaseName -server $AnalysisServerName -RefreshType "Full" -Credential $SPCredential 
    # Show done when finished (for testing/logging purpose only)
    # Scale DOWN AS
    Write-Output "Scaling DOWN $($asServerName) to $($ServiceLevelDown)"
    $null = Set-AzureRmAnalysisServicesServer -ResourceGroupName $resourceGroupName -Name $asServerName -Sku $ServiceLevelDown
    # Output final status message 
    Write-Output "$($asServerName) scaled to $($ServiceLevelDown)" 
     # Scale the pool
    $ElasticPool = Set-AzureRmSqlElasticPool -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -ElasticPoolName $poolName `
            -Edition "Standard" `
            -Dtu 100 `
            -DatabaseDtuMin 0 `
            -DatabaseDtuMax 100

    # Output final status message 
    Write-Output "Completed scale DOWN" 
   Write-Output "Done"
}
catch
{
    Write-Output "Begin send mail..."
    $SPCredentialEmail = Get-AutomationPSCredential -Name "Email_Cred"
    $errorMessage = $_
    $Message = New-Object System.Net.Mail.MailMessage
    $Message.From = "svinstall@alpitourworld.it"
    $Message.To.Add("davide.sortino@porini.it")
    $Message.To.Add("marco.mancini@porini.it")
    $Message.SubjectEncoding = ([System.Text.Encoding]::UTF8)
    $Message.Subject = "[ALPITOUR] Failed job ProcessAzureAS DataModel"
    # Set email body
    $Message.Body = "Error message: <br /><br /><br /><br /><br /> $errorMessage"
    $Message.BodyEncoding = ([System.Text.Encoding]::UTF8)
    $Message.IsBodyHtml = $true
    # Create and set SMTP
    $SmtpClient = New-Object System.Net.Mail.SmtpClient('smtp.office365.com', 587)
    $SmtpClient.Credentials = $SPCredentialEmail
    $SmtpClient.EnableSsl = $true
    # Send email message
    $SmtpClient.Send($Message)
    Write-Output "Mail sent..." 
}