param
(
    [Parameter (Mandatory = $false)]
    [object] $WebhookData,

    [Parameter (Mandatory = $false)]
    [String] $DatabaseName,

    [Parameter (Mandatory = $false)]
    [String] $AnalysisServer,

    [Parameter (Mandatory = $false)]
    [String] $RefreshType,

    [Parameter (Mandatory = $false)]
    [String] $ObjectType,
    
    [Parameter (Mandatory = $false)]
    [String[]] $TablesList
)

$_Credential = Get-AutomationPSCredential -Name "<>"

# Connect to a connection to get TenantId and SubscriptionId
$connection = Get-AutomationConnection -Name "AzureRunAsConnection"
$tenantId = $connection.TenantId
$subscriptionId = $connection.SubscriptionId   

# Login to Azure
$null = Login-AzureRmAccount -TenantId $tenantId -SubscriptionId $subscriptionId -Credential $_Credential

# If runbook was called from Webhook, WebhookData will not be null.
if ($WebhookData)
{ 
    # Retrieve AAS details from Webhook request body
    $atmParameters = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    Write-Output "CredentialName: $($atmParameters.CredentialName)"
    Write-Output "AnalysisServicesDatabaseName: $($atmParameters.AnalysisServicesDatabaseName)"
    Write-Output "AnalysisServicesServer: $($atmParameters.AnalysisServicesServer)"
    Write-Output "DatabaseRefreshType: $($atmParameters.DatabaseRefreshType)"
    
    $_databaseName = $atmParameters.AnalysisServicesDatabaseName
    $_analysisServer = $atmParameters.AnalysisServicesServer
    $_refreshType = $atmParameters.DatabaseRefreshType

    Invoke-ProcessASDatabase -DatabaseName $_databaseName -RefreshType $_refreshType -Server $_analysisServer -ServicePrincipal -Credential $_credential
}
else 
{
    if($ObjectType -eq 'TABLE')
    {
        foreach ($table in $TablesList)
        {
            Invoke-ProcessTable -DatabaseName $DatabaseName -RefreshType $RefreshType -Server $AnalysisServer -TableName $table -Credential $_Credential
        }
    }
    elseif($ObjectType -eq 'DATABASE')
    {
        Invoke-ProcessASDatabase -DatabaseName $DatabaseName -RefreshType $RefreshType -Server $AnalysisServer  -Credential $_Credential
    }
                
}
