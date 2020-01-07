##############################################################################
# Process Partition Script
# Author: Stefano Brusamolino (by Danilo Selva)
# Revision: 1.1
# Date: 2019/05/09
##############################################################################
Param(
  [Parameter(Mandatory=$true)][String] $table,          #AAS Table
  [Parameter(Mandatory=$true)][String] $sourceSchema,   #Source Schema
  [Parameter(Mandatory=$true)][String] $sourceTable,    #Source Table
  [Parameter(Mandatory=$true)][String] $filterColumn,   #Filter Column (DateTime columun)
  [Parameter(Mandatory=$true)][DateTime] $date,         #Date
  [Parameter(Mandatory=$true)][String] $frequency,      #Frequency (Y, M, W)
  [Parameter(Mandatory=$true)][Int] $interval           #Interval (1, 2, ...)
)
# Get variable values
$asServerName = Get-AutomationVariable -Name 'ASServerName'
$asServerURI = Get-AutomationVariable -Name 'ASServerURI'
$asDatabaseName = Get-AutomationVariable -Name 'ASDatabaseName'
$asDataSource = Get-AutomationVariable -Name 'ASDataSource'
$SQLServerMURI = Get-AutomationVariable -Name 'SQLServerMURI'

$sqlServerName = Get-AutomationVariable -Name 'SQLServerName'

$resourceGroupName= Get-AutomationVariable -Name 'ResourceGroupName'
$automationAccountName = Get-AutomationVariable -Name 'AutomationAccountName'

# Get the service principal credentials connected to the automation account. 
$psCredential = Get-AutomationPSCredential -Name "lpiiotqscred_ext_brusast1" #Probabilmente serve utente admin, in caso creare credenziali admin:  lpiiotqscred_admin

# Connect to a connection to get TenantId and SubscriptionId
$connection = Get-AutomationConnection -Name "AzureRunAsConnection"
$tenantId = $connection.TenantId
$subscriptionId = $connection.SubscriptionId   

function Get-PartitionMetadata{
#$outputType: StartDate, EndDate, PartitionSuffix
param( [DateTime]$date, [string] $frequency, [int]$interval, [string]$outputType )
   # Inner Variables
   $firstDayOfYear = (Get-Date -Year $date.Year.ToString() -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0)
   $periodStartDate = $firstDayOfYear
   
   # Frequency: Year
   if ($frequency -eq "Y") {

     # $startDate and $endDate
     while ($date -ge $periodStartDate) {
       $startDate = $periodStartDate
       $periodStartDate = $periodStartDate.AddYears($interval)
       $endDate = $periodStartDate.AddDays(-1)
     }

     # $partitionSuffix
     $startYear = $startDate.Year.ToString()
     $endYear = $endDate.Year.ToString()
     if ($startYear -eq $endYear) {
       $partitionSuffix = $startYear
     }
     else {
       $partitionSuffix = $startYear + "-" + $endYear
     }

   }
   # Frequency: Month
   elseif($frequency -eq "M") {

     # $startDate and $endDate
     while ($date -ge $periodStartDate) {       
       $startDate = $periodStartDate
       $periodStartDate = $periodStartDate.AddMonths($interval)
       $endDate = $periodStartDate.AddDays(-1)
       if ($endDate.Year -gt $startDate.Year)
       {
         $endDate = (Get-Date -Year $startDate.Year.ToString() -Month 12 -Day 31)
       }
     }

     # $partitionSuffix
     $startMonth = ("00" + $startDate.Month.ToString()).Substring($startDate.Month.ToString().Length, 2)
     $endMonth = ("00" + $endDate.Month.ToString()).Substring($endDate.Month.ToString().Length, 2)
     if ($startMonth -eq $endMonth) {
       $partitionSuffix = $startDate.Year.ToString() + "_M" + $startMonth
     }
     else {
       $partitionSuffix = $startDate.Year.ToString() + "_M" + $startMonth + "-" + $endMonth
     }

   }
   # Frequency: Week
   elseif($frequency -eq "W") {
     
     # $startDate and $endDate
     while ($date -ge $periodStartDate) {
       $startDate = $periodStartDate
       $periodStartDate = $periodStartDate.AddDays($interval*7 - ($startDate.DayOfWeek))
       $endDate = $periodStartDate.AddDays(-1)
       if ($endDate.Year -gt $startDate.Year)
       {
         $endDate = (Get-Date -Year $startDate.Year.ToString() -Month 12 -Day 31)
       }
     }

     # $partitionSuffix (Weeks start on Sunday! First week can have less than 7 days)
     $startDateFixed = $startDate.AddDays($firstDayOfYear.DayOfWeek-1)
     $startWeek = ("00" + (Get-Date -date $startDateFixed -uformat %V))
     $startWeek = ("00" + $startWeek).Substring($startWeek.Length, 2)
     $endDateFixed = $endDate.AddDays($firstDayOfYear.DayOfWeek-1)
     if ($endDateFixed.Year -gt $startDate.Year)
     {
       $endDateFixed = (Get-Date -Year $startDate.Year.ToString() -Month 12 -Day 31)
     }     
     $endWeek = ("00" + (Get-Date -date $endDateFixed -uformat %V))
     $endWeek = ("00" + $endWeek).Substring($endWeek.Length, 2)
     
     if ($startWeek -eq $endWeek) {
       $partitionSuffix = $startDate.Year.ToString() + "_W" + $startWeek
     }
     else {
       $partitionSuffix = $startDate.Year.ToString() + "_W" + $startWeek + "-" + $endWeek
     }
   }
   else {
    #Raise error
   }

   if ($outputType -eq "StartDate"){
     $startDate
   }
   elseif ($outputType -eq "EndDate"){
     $endDate
   }
   elseif ($outputType -eq "PartitionSuffix"){
     $partitionSuffix
   }
   elseif ($outputType -eq "DaysFromStart"){
     (New-TimeSpan -Start(get-date -Year $startDate.Year -Month $startDate.Month -Day $startDate.Day) -End(get-date -Year $date.Year -Month $date.Month -Day $date.Day)).Days.ToString()
   }  
}

function Get-mQuery{
  #$outputType: StartDate, EndDate, PartitionSuffix
  param([string]$asDatabaseName, [string]$table, [string]$partitionName, [string]$sqlServerName, [string]$dwhDatabaseName, [string]$sourceTable, [string]$sourceSchema, [string]$filterColumn, [DateTime]$startDate, [DateTime]$endDate)      
  "{
  `"createOrReplace`": {
      `"object`": {
      `"database`": `""+$asDatabaseName+"`",
      `"table`": `""+$table+"`",
      `"partition`": `""+$partitionName+"`"
      },
      `"partition`": {
      `"name`": `""+$partitionName+"`",
      `"source`": {
          `"type`": `"m`",
          `"expression`": [       
              `"let`",
              `"    Source = #\`""+$SQLServerMURI+"`",`",
              `"    model_Fact = Source{[Schema=\`""+$sourceSchema+"\`",Item=\`""+$sourceTable+"\`"]}[Data],`",
              `"    #\`"Filtered Rows\`" = Table.SelectRows(model_Fact, each ["+$filterColumn+"] >= #date("+$startDate.Year.ToString()+", "+$startDate.Month.ToString()+", "+$startDate.Day.ToString()+") and ["+$filterColumn+"] <= #date("+$endDate.Year.ToString()+", "+$endDate.Month.ToString()+", "+$endDate.Day.ToString()+"))`",
              `"in`",
              `"    #\`"Filtered Rows\`"`"
          ]
      }
      }
  }
  }"
}

try
{
  Write-Output "Begin Try..."
  Write-Output "Start Processing Partition"

  $startDate = Get-PartitionMetadata -Date $date -Frequency $frequency -Interval $interval -OutputType "StartDate"
  $endDate = Get-PartitionMetadata -Date $date -Frequency $frequency -Interval $interval -OutputType "EndDate"
  $partitionSuffix = Get-PartitionMetadata -Date $date -Frequency $frequency -Interval $interval -OutputType "PartitionSuffix"
  $partitionName = $table.Replace(" ", "") + "_" + $partitionSuffix  
  Write-Output "Partition Name: $($partitionName)" 

  ##Query definition
  $qParams = @{'asDatabaseName'  = $asDatabaseName;
               'table'           = $table ;
               'partitionName'   = $partitionName ;
               'sqlServerName'   = $sqlServerName ;
               'dwhDatabaseName' = $dwhDatabaseName ;
               'sourceSchema'    = $sourceSchema ;
               'sourceTable'     = $sourceTable ;
               'filterColumn'    = $filterColumn ;
               'startDate'       = $startDate ;
               'endDate'         = $endDate }
  $query = Get-mQuery @qParams
  Write-Output "Query:" 
  Write-Output $query 
  
  Write-Output "ASCmd... start"
  ##Creating the partition
  Invoke-ASCmd -Server $asServerURI -Credential $psCredential -Query $query
  Write-Output "ASCmd... end"

Write-Output "Process... start"
 ##Processing the partition
 $result = Invoke-ProcessPartition -Server $asServerURI -Database $asDatabaseName -TableName $table -PartitionName $partitionName –RefreshType Full -Credential $psCredential
Write-Output "Process... end"
 ##Process Previous Partition (if necessary)
 $daysFromStart = Get-PartitionMetadata -Date $date -Frequency $frequency -Interval $interval -OutputType "DaysFromStart"
 if ($daysFromStart -eq 0) {
   $partitionSuffix = Get-PartitionMetadata -Date $date.AddDays(-1) -Frequency $frequency -Interval $interval -OutputType "PartitionSuffix"
   $partitionName = $table.Replace(" ", "") + "_" + $partitionSuffix
   ##Processing the previous partition
   try {
       Write-Output "Start Processing Previous Partition"
       Write-Output "Previous Partition Name: $($partitionName)"
       $result = Invoke-ProcessPartition -Server $asServerURI -Database $asDatabaseName -TableName $table -PartitionName $partitionName –RefreshType Full -Credential $psCredential 
   }
   catch {
     $errorMessage = "Previous Partition [" + $partitionName + "] does not exist."
     Write-Output $errorMessage
   } 
 }  
}
catch
{
    Write-Output "Begin Catch..."

    $emailFrom = Get-AutomationVariable -Name 'EmailFrom'
    $emailToList = Get-AutomationVariable -Name 'EmailToList'
    $emailCCList = Get-AutomationVariable -Name 'EmailCCList'
    $emailCCList2 = Get-AutomationVariable -Name 'EmailCCList2'
    $emailCCList3 = Get-AutomationVariable -Name 'EmailCCList3'
   
    $psCredentialEmail = Get-AutomationPSCredential -Name "lpiiotqscred_alerts.textile" #CREDENZIALI DELL'UTENTE AUTORIZZATO AD INVIARE EMAIL
    # Set $errorMessage
    $errorMessage = $_
    Write-Output "Error: " + $errorMessage    
    # Create new MailMessage
    $message = New-Object System.Net.Mail.MailMessage
     
    # Set address-properties
    $message.From = $emailFrom
    $message.replyTo = $emailFrom
    $message.To.Add($emailToList)
    $message.CC.Add($emailCCList)
    $message.CC.Add($emailCCList2)   
    $message.CC.Add($emailCCList3)
              
    # Set email subject
    $message.SubjectEncoding = ([System.Text.Encoding]::UTF8)
    $message.Subject = "[LPIOT] Failed job: lpiiotqsrunb_AAS_lpiiotqsas_CreatePartition - Partition: $partitionName"
     
    # Set email body
    $message.Body = "Error message:<br><br>$errorMessage"
    $message.BodyEncoding = ([System.Text.Encoding]::UTF8)
    $message.IsBodyHtml = $true
     
    # Create and set SMTP
    $smtpClient = New-Object System.Net.Mail.SmtpClient('smtp.office365.com', 587)
    $smtpClient.Credentials = $psCredentialEmail
    $smtpClient.EnableSsl   = $true
           
    # Send email message
    $smtpClient.Send($message)
    # Output status to console
    Write-Output "Mail sent"
}