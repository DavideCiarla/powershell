##USA SENDGRID SE CI SONO ACCOUNTS OFFICE 365

$emailFrom = Get-AutomationVariable -Name "EmailFrom"    ###parameter set in the variables from the interface
$emailTo = Get-AutomationVariable -Name "EmailTo"        ###parameter set in the variables from the interface

$smtp = "smtp.office365.com"
$port = 587

$subject = "email runbook"
$body = "ERRORE"
$credential = Get-AutomationPSCredential -Name "MyEmailAccount"     ###parameter set in credentials (remember to put an office365
                                                                    ###account, and the pw must be the real one )

Try {
    Write-Output "Prepare Message"
    $message = New-Object System.Net.Mail.MailMessage        ###oggetto email
    $message.From = $emailFrom
    $message.ReplyTo = $emailFrom
    $message.To.Add($emailTo)
    $message.Subject = $subject
    $message.Body = $body
    $message.SubjectEncoding = ([System.Text.Encoding]::UTF8)
    $message.BodyEncoding = ([System.Text.Encoding]::UTF8)
    $message.IsBodyHtml = $true

    Write-Output "Prepare Connection"
    $smtpClient = New-Object System.Net.Mail.SmtpClient('smtp.office365.com', 587)   ###oggetto connesione
    $smtpClient.Credentials = $credential
    $smtpClient.EnableSsl = $true

    Write-Output "Send Message"
    $smtpClient.Send($message)                                ###oggetto connessione ha il metodo .Send() che invia l'oggetto email
}
Catch {
    $errorMessage = $_                                              ### $_ : tipo errore

    Write-Output "Enter Catch Block"
    Write-Output "Error:"
    
    Write-Output $errorMessage
}