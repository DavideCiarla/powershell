######################################################################################################################

#https://cloudblogs.microsoft.com/industry-blog/en-gb/cross-industry/2018/06/22/how-to-automate-processing-your-azure-analysis-services-models/

$credential = Get-AutomationPSCredential -Name "<>"
$asServerURI = Get-AutomationVariable -Name '<>'

# Connect to a connection to get TenantId and SubscriptionId
$connection = Get-AutomationConnection -Name "AzureRunAsConnection"
$tenantId = $connection.TenantId
$subscriptionId = $connection.SubscriptionId   

# Login to Azure
$null = Login-AzureRmAccount -TenantId $tenantId -SubscriptionId $subscriptionId -Credential $credential

$db_name = "TEST_Partitioning" 
$tbl_name = "ft_saldi_mlo"  
#$TablesList = @("tbl1", "tbl2", "tblN")   ## dovrebbe essere solo una tbl (se no creare un foreach)   

$path_year = (get-date).ToString(“yyyy”) #$path_year.GetType() -- string
$path_month = (get-date).ToString(“MM”) #$path_month.GetType() -- string
$pr_name = $tbl_name + "_" + $path_year + $path_month   #"ft_saldi_mlo_201911" ------ ft_saldi_mlo201912  $pr_name.GetType() ---- string

$params = @{'db_name'  = $db_name;
             'tbl_name' = $tbl_name;
             'pr_name'  = $pr_name}

function cr_query ([string]$db_name, [string]$tbl_name, [string]$pr_name) {

    '{
      "createOrReplace": {
        "object": {
          "database": "'+$db_name+'",
          "table": "'+$tbl_name+'",
          "partition": "'+$pr_name+'"      
        },
        "partition": {
          "name": "'+$pr_name+'",
          "source": {
            "type": "m",
            "expression": [
              "let",
              "    Source = ft_saldi_mlo,",
              "   #\"Partition Filter Year\"   =   Table.SelectRows(Source, each [year]= '+$path_year+'), ",
              "   #\"Partition Filter Month\" =  Table.SelectRows(#\"Partition Filter Year\" , each [month]= '+$path_month+')",
              "in",
              "    #\"Partition Filter Month\""
            ]
          }
        }
      }
    }'

}

$query = cr_query @params

##Creating the partition
Invoke-ASCmd -Server $asServerURI -Credential $credential -Query $query


##Processing the partition
$result = Invoke-ProcessPartition -Server $asServerURI -Database $db_name -TableName $tbl_name -PartitionName $pr_name –RefreshType Full -Credential $credential

######################################################################################################################

