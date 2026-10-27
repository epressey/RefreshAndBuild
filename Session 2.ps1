#check if we have *any* Exchange modules installed already
$installedModules = get-installedmodule
$installedModules | Where-Object {$_.Name -match "Ex"} #print it to the screen, an Exchange module will probably have 'Ex' in it somewhere

#install most recent EXO module following MS documentation
Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.2.0 #bug with anything above this version still present for VS Code - auth window doesn't open and PS session still hangs!

Connect-ExchangeOnline #connect interactively

$allMailboxes = get-mailbox #get all mailboxes from tenant (connected with MS account in session), store it in an array

$allMailboxes | Measure-Object #count how many we got back, print

$allMailboxes.DisplayName #print all the displaynames to see what we got back

#export the data as a CSV file locally (as we haven't done this in a practise session yet)
$allMailboxes | Export-Csv -Path "C:\Users\Admin\Downloads\mailboxes.csv" -NoClobber -NoTypeInformation

#import it back in, because we haven't done this in a practise session yet either
$allMailoxesFromCSV = import-csv -Path "C:\Users\Admin\Downloads\mailboxes.csv"

#check we got all the data by matching the count of objects from our array created directly using data from Exchange Vs our data from the CSV file (really, just an excuse to use an if statement)
if(($allMailboxes | Measure-Object).count -eq ($allMailoxesFromCSV | Measure-Object).count){
    write-host "We have a matching number of mailboxes between Exchange and our CSV" -ForegroundColor Green
}
else{
    write-host "We DON'T have a matching number of mailboxes between Exchange and our CSV" -ForegroundColor Red
}