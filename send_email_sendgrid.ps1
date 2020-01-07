##USA SENDGRID SE NON CI SONO ACCOUNTS OFFICE 365

$emailFrom = Get-AutomationVariable -Name "EmailFrom"       ##variables set from interface
$emailTo = Get-AutomationVariable -Name "EmailTo"           ##variables set from interface

$smtp = "smtp.sendgrid.net"
$port = 25

$subject = "email runbook"
$body = "ERROR"
$credential = Get-AutomationPSCredential -Name "SendGridCredential"         
##da inserire nelle credenziali 
##(dev'essere attivato un servizio "sendgrid", 
  ###nome utennte è sempre : "apikey" 
  ##pw va generata una chiave : nel portale della sendgrid : 
    ###- manage (in alto a sinistra) 
    ###- settings (a sinistra) 
    ###- apikey : copialo e usalo come pw)
                                                                              

Try {
    Write-Output "Prepare Message"
    $message = New-Object System.Net.Mail.MailMessage                   ##oggetto email
    $message.From = $emailFrom
    $message.ReplyTo = $emailFrom
    $message.To.Add($emailTo)
    $message.Subject = $subject
    $message.Body = $body
    $message.SubjectEncoding = ([System.Text.Encoding]::UTF8)
    $message.BodyEncoding = ([System.Text.Encoding]::UTF8)
    $message.IsBodyHtml = $true

    Write-Output "Prepare Connection"
    $smtpClient = New-Object System.Net.Mail.SmtpClient('smtp.sendgrid.net', 25)     ##oggetto connessione
    $smtpClient.Credentials = $credential

    Write-Output "Send Message"
    $smtpClient.Send($message)                                        ##oggetto connessione ha metodo .send() usato per inviare oggetto email
}
Catch {
    $errorMessage = $_                                                ## $_ : modo per intercettare l'errore

    Write-Output "Enter Catch Block"
    Write-Output "Error:"
    
    Write-Output $errorMessage
}