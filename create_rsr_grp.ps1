################################################################################################################################################
# cr_res_groups : funzione per creare / svuotare (se esistenti) gruppi di risorse                                                              #
# parametri richiesti :                                                                                                                        #
# - nome della sottosrizione (stringa)                                                                                                         #
# - luogo in cui creare il gruppo di risorse ex. "North Europe" (stringa) (https://azure.microsoft.com/en-us/global-infrastructure/locations/) #
# - pattern dei gruppi di risorse (string) ex. user1 , user2 , .. .. , userN --> in questo caso il pattern è "user"                            #
# - numero studenti ex. 13 --> creerà 13 gruppi di risorse chiamate : user1, user2, .. .. , user13                                             #
################################################################################################################################################

function cr_res_groups([string]$subscription, [string]$location, [string]$pattern, [int]$to_ptr) {
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

#$name_subscription = "<***>"
#$location_resource_group = "<***>"
#$pattern_name = "<***>"
#$students_number = <***>

#cr_res_groups $name_subscription $location_resource_group $pattern_name $students_number


