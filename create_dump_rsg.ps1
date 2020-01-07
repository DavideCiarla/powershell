#$name_subscription = "<***>"
#$location_resource_group = "<***>"
#$pattern_name = "<***>"
#$students_number = <***>

#$name_subscription = "Porini Education Microsoft Azure"
#$location_resource_group = "North Europe"
#$pattern_name = "rdvd"
#$students_number = 4
#$id = @(1,2, 3)   

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

function cr_from_to_res_groups([string]$subscription, [string]$location, [string]$pattern, [int]$to_ptr) {
    
    Connect-AzureRmAccount -Subscription $subscription                     #connect to azure
    $fr_to_pattern = @(1..$to_ptr)                                         #(user) from 1 to number specified in function (1,2, .. .. 13) 
                                                                         
    $arr_students = @()                                                    #dump list
                                                                         
    Foreach ($value in $fr_to_pattern) {                                   #| full
        $student = $pattern + $value                                       #|     fill
        $arr_students += $student                                          #|         list     (user1, user2, .. .. user 13)
    }

    foreach ($student in $arr_students) {                                  #| resource
        New-AzureRmResourceGroup -Name $student -Location "North Europe"   #|         groups
    }                                                                      #|               creation
                                                                           
    Disconnect-AzureRmAccount                                              #disconnect to azure

    "created " + $to_ptr + " resource groups :)"     

}



cr_from_to_res_groups $name_subscription $location_resource_group $pattern_name $students_number

################################################################################################################################################
#cr_from_to_res_groups : funzione per creare / svuotare (se esistenti) only specified res groups                                               #                                             #
#to do it modify id and pass only numbers you want create                                                                                      #
################################################################################################################################################


function cr_from_to_res_groups([string]$subscription, [string]$location, [string]$pattern) {

    $arr_students = @()  

    Connect-AzureRmAccount -Subscription $subscription 

    Foreach ($value in $id) {                                   
            $student = $pattern + $value                                       
            $arr_students += $student                                          
    }

    foreach ($student in $arr_students) {                                  
            New-AzureRmResourceGroup -Name $student -Location "North Europe"   
    } 

    Disconnect-AzureRmAccount     
    "created " + $id.Count + " resource groups :)"  
}

cr_from_to_res_groups $name_subscription $location_resource_group $pattern_name

################################################################################################################################################
#del_res_groups : funzione per rimuovere only specified res groups                                                                             #                                                                                    #
################################################################################################################################################
function del_res_groups([string]$subscription, [string]$pattern) {

    $arr_students = @()  

    Connect-AzureRmAccount -Subscription $subscription 

    Foreach ($value in $id) {                                   
            $student = $pattern + $value                                       
            $arr_students += $student                                          
    }

    foreach ($student in $arr_students) {                                  
            Remove-AzureRmResourceGroup -name $student
    } 

    Disconnect-AzureRmAccount     
    "delated " + $id.Count + " resource groups :)"

}

del_res_groups $name_subscription $pattern_name


