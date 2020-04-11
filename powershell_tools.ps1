#folder where cmd are lounched
path

#navigate folder
dir #not ls like linux

#download a file 
cd C: .. .. /desktop
wget http://lamastex.org/datasets/public/NYCUSA/social-media-usage.csv # (before dowload wget, put .exe in 'path' folder (sys32))

#ping go0gle
ping 8.8.8.8

#help
Get-Help Add-AzADGroupMember

#set variable : 
$a = 5

#help : 
Get-Help Get-AzureRmContext

#types :
	$a = "1"
	$b = [int]$a
	$c = [string]$b

	[int32]$value       
	[float]$value       
	[string]$value      
	[boolean]$value     
	[datetime]$value
 
$mix_array.GetType() ----- output : System.Array  

#array :
	$a = 5
	$b = 2
	$c = "hello"
	$mixed_array = $a, $b, $c ----- output : 5,2,"hello"
	
	#official operator of arrays : @ 
	$mixed_array = @(5 ; 2 ; "hello")
	
	#position of array : 
    $mix_array[1]  ---- output = 2
	
	#BE CAREFULL!!! $mix_array + 5 adds an element to the array (it dowsn t add 5 to each element of the array)
	#	----- output 5, 2, "hello", 5
		
	#	array from 0 to 10
			$arr_0_10 = @(0..10) ---- OUTPUT 0,1,2 .. .. 10

#dictionary : 
	$mixed_dictionary = @{"a" = "5" ; "b" = "2" ; "c" = "hello"}
	

#function :
	function fn_sum([int]$number0, [int]$number1) {
		$sum = $number0 + $number1
		$sum
	}
	
	fn_sum 4 8 ------ output 12   (BECAREFULL HOW YOU PASS THE INPUTS, IF fn_sum(4,8) IT READS A LIST --- OUTPUT 4, 8)

#pass dictionary to function
    # @ used in this way called "splatter operator" when you pass many items to one variable
$params = @{"a" = 1;
           "b" = 2;
           "c" = 3}

function sum ( $a, $b, $c ) {
    $result = $a + $b + $c
    $result
}

sum 1 2 3       # 6
sum @params     # 6

#foreach loop : 
	Foreach ($value in $mix_array) 
    {
        $value + 5
    }
	
	------ otuput : 10,7,hello5

#set input from cmd
Param(
  [Parameter(Mandatory=$true)][String] $name,         
  [Parameter(Mandatory=$true)][String] $years,
  [Parameter (Mandatory = $true)][String[]] $list    #it makes you add items. to interrupt the loop click ENTER again (don't stop the script
                                                     #otherwise it interrupt the Param method hence no variable is set)
)
    #console asks you to insert a name and years

$name + " - " + $years + " - " + $list
	
#connect to azure
#	article : https://www.jgspiers.com/how-to-connect-to-azure-powershell-arm-azuread/
# becarefull to "Get-AzureContext", don t use it! many command in documentation are written as ..-Azure.. but is deprecated, use ..-Az..("Get-AzContext")
	
    Get-AzContext -ListAvailable
	$PSVersionTable.PSVersion ---- version must be at least 5 
	Install-Module AzureRM   ---- runned as administrator 
	
	Import-Module AzureRM -- ERROR
		https://docs.microsoft.com/it-it/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6
		
		Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
		Import-Module AzureRM OK
	
	Connect-AzureRmAccount -Subscription "<>"
	Get-AzContext -ListAvailable
		check connection : Get-AzureRmContext

#or
Install-Module Az.Accounts -Scope CurrentUser -AllowClobber #clobber = picchiare
Connect-AzAccount

#set context
    Connect-AzAccount -Subscription "Porini Education Microsoft Azure"

    $str_account_name = "<>"
    $str_account_key = "<sorage account key>"
        
    $ctx = New-AzStorageContext -StorageAccountName $str_account_name -StorageAccountKey $str_account_key

#set retrive metadata blob
    $resource = Get-AzResource -ResourceName $adlname 
    Set-AzResource -Tag @{ "Data"=$date, "data2" = "sddd"} -ResourceId $resource.ResourceId -Force 
    (Get-AzStorageBlob -Container $container_name -Context $ctx -Blob $blob_name).ICloudBlob.Metadata

#disconnect to azure
	Disconnect-AzureRmAccount
	
	create and remove resurce group
		Get-AzureRmResourceGroup --- list resources 
		New-AzureRmResourceGroup -Name RG_from_script_dvd -Location "North Europe"    ---- create
		Remove-AzureRmResourceGroup -Name RG_from_script_dvd                          ---- remove
		
#see available locations
Get-AzLocation
Get-AzLocation | select Location
$location = "northeurope"
