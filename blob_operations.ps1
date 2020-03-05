Install-Module Az -Scope CurrentUser -AllowClobber #clobber = picchiare
Connect-AzAccount -Subscription "<>"  #subscription facoltativo


#if you forget location names
#Get-AzLocation | select Location

Param(
  [Parameter(Mandatory=$true)][String] $location,                   #"northeurope"
  [Parameter(Mandatory=$true)][String] $resourceGroupName,          #"resgndvd"
  [Parameter(Mandatory=$true)][String] $storageAccountName,         #"standvd"
  [Parameter(Mandatory=$true)][String] $containerName               #"cntndvd"
)

#$location = "northeurope"
#$resourceGroupName = "resgndvd"
#$storageAccountName = "standvd"
#$containerName = "cntndvd"
$containerName2 = "<>"
$storageAccountName2 = "<>" 

New-AzResourceGroup -Name $resourceGroupName -Location $location

#create new storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName "Standard_LRS"

$ctx2 = $storageAccount.Context

#create new container
$container = New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob
$container = New-AzStorageContainer -Name $containerName2 -Context $ctx -Permission blob

$container = New-AzStorageContainer -Name $containerName -Context $ctx2 -Permission blob
$container = New-AzStorageContainer -Name $containerName2 -Context $ctx2 -Permission blob

#show storage accounts 
Get-AzStorageAccount -ResourceGroupName $resourceGroupName 

#get keys 
$key1 = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
$key2 = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[1]

#get tag
$x = (Get-AzTag -name key_tag).Values[0][0]
#Get-AzTag -name key_tag
$x.GetType()    # ---- tag object

#set context
    Connect-AzAccount -Subscription "Porini Education Microsoft Azure"

    $str_account_name = "<>"
    $str_account_key = "<sorage account key>"

    $ctx = New-AzStorageContext -StorageAccountName $str_account_name -StorageAccountKey $str_account_key

#set retrive metadata blob
    $resource = Get-AzResource -ResourceName $adlname 
    Set-AzResource -Tag @{ "Data"=$date, "data2" = "sddd"} -ResourceId $resource.ResourceId -Force 
    (Get-AzStorageBlob -Container $container_name -Context $ctx -Blob $blob_name).ICloudBlob.Metadata

#show containers 
Get-AzStorageContainer -Context $ctx


#add file to container 
Set-AzStorageBlobContent -File "C:\Users\DavideCiarlariello\Desktop\leaf.JPG" -Container $containerName -Blob "leaf2.JPG" -Context $ctx 
    # -Blob : name of the file once in the container

#show files in a container 
Get-AzStorageBlob -Container $ContainerName -Context $ctx | select Name

#download from a container
Get-AzStorageBlobContent -Blob "leaf2.JPG" -Container $containerName -Destination "C:\Users\DavideCiarlariello\Desktop\" -Context $ctx 

#Remove container
Remove-AzRmStorageContainer $resourceGroupName $storageAccountName -Name $containerName

#Remove storage account
Remove-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName

#Remove resource group
Remove-AzResourceGroup -Name $resourceGroupName








