#ping go0gle
ping 8.8.8.8

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
  [Parameter(Mandatory=$true)][String] $years   
)
    #console asks you to insert a name and years

$name + " - " + $years
	
#connect to azure
#	article : https://www.jgspiers.com/how-to-connect-to-azure-powershell-arm-azuread/
	
	$PSVersionTable.PSVersion ---- version must be at least 5 
	Install-Module AzureRM   ---- runned as administrator 
	
	Import-Module AzureRM -- ERROR
		https://docs.microsoft.com/it-it/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6
		
		Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
		Import-Module AzureRM OK
	
	Connect-AzureRmAccount -Subscription "Porini Education Microsoft Azure"
	
		check connection : Get-AzureRmContext

#or
Install-Module Az.Accounts -Scope CurrentUser -AllowClobber #clobber = picchiare
Connect-AzAccount

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