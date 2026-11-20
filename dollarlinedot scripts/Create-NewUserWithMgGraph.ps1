#get connected interactively, this will pop open a sign-in window
Connect-MgGraph -Scopes "User.ReadWrite.All"

#import newStarterRequest.csv
$csvWithNewStarterData = import-csv -path "C:\Users\Admin\Downloads\newStarterRequest.csv"

$accountEnabled = $false #we're not really using the account, it's good practise to leave test accounts deactivated
$displayName = "$($csvWithNewStarterData.'First Name') $($csvWithNewStarterData.'Last Name')" #combination of 'first name' and 'last name'
$mailNickname = "$($csvWithNewStarterData.'First Name').$($csvWithNewStarterData.'Last Name')" #combination of 'first name' and 'last name', with a period instead of a space
$passwordProfile = @{
    'forceChangePasswordNextSignIn' = $true
    'forceChangePasswordNextSignInWithMfa' = $false
    'password' = "randomly generated password of your choice"
    } #hashtable with randomly generated password
$userPrincipalName = "$($csvWithNewStarterData.'First Name').$($csvWithNewStarterData.'Last Name')@validdomainname.com" ##combination of 'first name' and 'last name', with a period and valid domain name

#MgGraph cmdlet to create new user account
New-MgUser -AccountEnabled:$accountEnabled -DisplayName $displayName -MailNickname $mailNickname -PasswordProfile $passwordProfile -UserPrincipalName $userPrincipalName