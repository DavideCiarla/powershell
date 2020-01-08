#$name_subscription = "<***>"
#$location_resource_group = "<***>"
#$pattern_name = "<***>"

#$name_subscription = "Porini Education Microsoft Azure"
#$location_resource_group = "North Europe"
#$pattern_name = "rdvd"

Install-Module AzureRM -Scope CurrentUser
Import-Module AzureRM

################################################################################################################################################
# cr_from_to_res_groups : funzione per creare / svuotare (se esistenti) gruppi di risorse con pattern da a                                     #
# parametri richiesti :                                                                                                                        #
# - nome della sottosrizione (stringa)                                                                                                         #
# - luogo in cui creare il gruppo di risorse ex. "North Europe" (stringa) (https://azure.microsoft.com/en-us/global-infrastructure/locations/) #
# - pattern dei gruppi di risorse (string) ex. user1 , user2 , .. .. , userN --> in questo caso il pattern è "user"                            #
# - numero studenti ex. 13 --> creerà 13 gruppi di risorse chiamate : user1, user2, .. .. , user13                                             #
################################################################################################################################################

function cr_from_to_res_groups{
    
    Param(
      [Parameter(Mandatory=$true)][String] $subscription,         
      [Parameter(Mandatory=$true)][String] $location,
      [Parameter(Mandatory=$true)][String] $pattern,
      [Parameter(Mandatory=$true)][String] $to_ptr                         #from 1 to number specified here (1,2, .. .. 13)
    )

    Connect-AzureRmAccount -Subscription $subscription                     #connect to azure

    $fr_to_pattern = @(1..$to_ptr)                                        
                                                                         
    $arr_students = @()                                                    #dump list
                                                                         
    Foreach ($value in $fr_to_pattern) {                                   #| full
        $student = $pattern + $value                                       #|     fill
        $arr_students += $student                                          #|         list     (user1, user2, .. .. user 13)
    }

    foreach ($student in $arr_students) {                                  #| resource
        New-AzureRmResourceGroup -Name $student -Location $location        #|         groups
    }                                                                      #|               creation
                                                                           
    Disconnect-AzureRmAccount                                              #disconnect to azure

    "created " + $to_ptr + " resource groups :) : "   
    $arr_students  
}

cr_from_to_res_groups 

################################################################################################################################################
#cr_from_to_res_groups : funzione per creare / svuotare (se esistenti) only specified res groups                                               #                                             #
#to do it modify id and pass only numbers you want create                                                                                      #
################################################################################################################################################


function cr_from_to_res_groups {
    
    Param(
      [Parameter(Mandatory=$true)][String] $subscription,         
      [Parameter(Mandatory=$true)][String] $location,
      [Parameter(Mandatory=$true)][String] $pattern,
      [Parameter (Mandatory = $true)][String[]] $id_students
    )

    $arr_students = @()  

    Connect-AzureRmAccount -Subscription $subscription 

    Foreach ($value in $id_students) {                                   
            $student = $pattern + $value                                       
            $arr_students += $student                                          
    }

    foreach ($student in $arr_students) {                                  
            New-AzureRmResourceGroup -Name $student -Location "North Europe"   
    } 

    Disconnect-AzureRmAccount     
    "created " + $id_students.Count + " resource groups :) :"  
    $arr_students
}

cr_from_to_res_groups 

################################################################################################################################################
#del_res_groups : funzione per rimuovere only specified res groups                                                                             #                                                                                    #
################################################################################################################################################
function del_res_groups{
    
    Param(
      [Parameter(Mandatory=$true)][String] $subscription,         
      [Parameter(Mandatory=$true)][String] $pattern,
      [Parameter (Mandatory = $true)][String[]] $id_students
    )

    $arr_students = @()  

    Connect-AzureRmAccount -Subscription $subscription 

    Foreach ($value in $id_students) {                                   
            $student = $pattern + $value                                       
            $arr_students += $student                                          
    }

    #foreach ($student in $arr_students) {                                  
    #        Remove-AzureRmResourceGroup -name $student
    #} 

    Disconnect-AzureRmAccount     
    "delated " + $id_students.Count + " resource groups :) : "
    $arr_students
}

del_res_groups


