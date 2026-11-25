#get connected interactively, this will pop open a sign-in window
Connect-MgGraph -Scopes "User.ReadWrite.All"

#import newStarterRequest.csv
$csvWithNewStarterData = import-csv -path "C:\Users\Admin\Downloads\newStarterRequest.csv"
 
#build the information into a hashtable with everything that is required
$body = @{
        accountEnabled = $false #we're not really using the account, it's good practise to leave test accounts deactivated
        displayName = "$($csvWithNewStarterData.'First Name') $($csvWithNewStarterData.'Last Name')" #combination of 'first name' and 'last name'
        mailNickname = "$($csvWithNewStarterData.'First Name').$($csvWithNewStarterData.'Last Name')" #combination of 'first name' and 'last name', with a period instead of a space
        userPrincipalName = "$($csvWithNewStarterData.'First Name').$($csvWithNewStarterData.'Last Name')@validdomainname.com" ##combination of 'first name' and 'last name', with a period and valid domain name
        passwordProfile = @{
            'forceChangePasswordNextSignIn' = $true
            'forceChangePasswordNextSignInWithMfa' = $false
            'password' = "randomly generated password of your choice"
            } #hashtable with randomly generated password
}

$json = convertTo-Json -inputObject $body #convert the hashtable stored in $body to a json object

#make the call to build the new user
Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users" -body $json -OutputType PSObject
