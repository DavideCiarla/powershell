## Takes a table and add the users into an azure active directory


# Install-Module -Name AzureAD

##login azure

#still to implement
#$credential = Get-AutomationPSCredential -Name "<>"
#Connect-AzAccount -Credential $credential

Connect-AzAccount 

## list users in active directory
#Get-AzADUser

## list groups in active directory
#Get-AzADGroup

## list users in group
#Get-AzADGroupMember -GroupDisplayName 'Gruppo_Amazon'

## remove member from the group
#Remove-AzADGroupMember -MemberUserPrincipalName "davide.ciarlariello_porini.it#EXT#@MPGKPI.onmicrosoft.com" -GroupDisplayName "Gruppo_Amazon"


## add new user

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile

$PasswordProfile.Password = <>

#Connect-AzureAD -Credential $credential
Connect-AzureAD

# il dominio di -MailNickName 'porini.it' dev essere registrato
New-AzureADUser -AccountEnabled $true -DisplayName 'DC' -PasswordProfile $PasswordProfile -MailNickName "davide.ciarlariello@porini.it" -UserPrincipalName "davide.ciarlariello_porini.it#EXT#@MPGKPI.onmicrosoft.com"

## add a member to the group
#Get-Help Add-AzADGroupMember
Add-AzADGroupMember -MemberUserPrincipalName "davide.ciarlariello_porini.it#EXT#@MPGKPI.onmicrosoft.com" -TargetGroupDisplayName "Gruppo_Amazon"

## remove user
Remove-AzADUser -UserPrincipalName 'davide.ciarlariello_porini.it#EXT#@MPGKPI.onmicrosoft.com'

## creatre an array from a view

#$tables = (invoke-sqlcmd -server mpgkpi.database.windows.net -Username hradmin -Password <> -Database hr_dwh "select distinct(Username) from [model].[RLS_Profilazione_AMZ]").Username
#
#Foreach ($value in $tables) 
#    {
#       ($value -replace '@', '_') + '#EXT#@MPGKPI.onmicrosoft.com'
#    }

$tables = (invoke-sqlcmd -server localhost  -Database test "select distinct(Username) from tbl_mnpSecurity").Username

$tables.GetType()    #array


## bug to fix :
    # se viene creato un New-AzureADUser, l'utente non deve accettare (noi impostiamo la pw quindi non potra accedere a azure con la propria email). STRADA DA PERCORRERE
        # per aggiungere utente in questa modalita bisogna registare i domini ex @porini.it @gmail.com
        # l'utente puo essere aggiunto direttamente al gruppo (non dobbiamo aspettare l accettazione dell invito

    # se viene creato un -InvitedUserEmailAddress, all utente arriva una email di conferma e gli viene chiesto di inserire una password, (anche se solo in lettura l'utente potrebbe potenzialmente entrare dentro azure)
        #prima di poterlo aggiungere al gruppo bisogna aspettare che l utente accetti
        
Foreach ($value in $tables) 
    {
        $mpn = ($value -replace '@', '_') + '#EXT#@MPGKPI.onmicrosoft.com'
        New-AzureADUser -AccountEnabled $true -DisplayName $value -PasswordProfile $PasswordProfile -MailNickName 'ciao' -UserPrincipalName $mpn 
        Add-AzADGroupMember -MemberUserPrincipalName $mpn -TargetGroupDisplayName "Gruppo_Amazon"
    }



Foreach ($value in $tables) 
    {
        $mpn = ($value -replace '@', '_') + '#EXT#@MPGKPI.onmicrosoft.com'
        New-AzureADMSInvitation -InvitedUserEmailAddress $value -SendInvitationMessage $True -InviteRedirectUrl "https://www.google.com/" 
        Add-AzADGroupMember -MemberUserPrincipalName $mpn -TargetGroupDisplayName "Gruppo_Amazon" # ERRROR - bisogna aspettare che l'utente accetti
    }

        New-AzureADMSInvitation -InvitedUserEmailAddress 'davide.ciarlariello@porini.it' -SendInvitationMessage $True -InviteRedirectUrl "https://www.google.com/" 
        Add-AzADGroupMember -MemberUserPrincipalName 'davide.ciarlariello_porini.it#EXT#@MPGKPI.onmicrosoft.com' -TargetGroupDisplayName "Gruppo_Amazon"

        
        New-AzureADMSInvitation -InvitedUserEmailAddress 'davide.ciarlariello@gmail.com' -SendInvitationMessage $True -InviteRedirectUrl "https://www.google.com/" 
        Add-AzADGroupMember -MemberUserPrincipalName 'davide.ciarlariello_gmail.com#EXT#@MPGKPI.onmicrosoft.com' -TargetGroupDisplayName "Gruppo_Amazon"