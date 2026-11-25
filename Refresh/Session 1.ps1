$PSVersionTable #check which version of PS we're running


$currentModules = get-module -ListAvailable #Check a Graph module is installed (not necessarily the most up to date one)
$currentModules[0] #check what properties we get back by looking at first object in array
$currentModules | Where-Object -Property "Name" -Match "Graph" #see what matches against the 'name' property
#2.17.0

get-help 'Connect-MgGraph' -detailed #get some example formats for the cmdlet, needs the tenantId at minimum

$tenantId = '' #store it in a variable for re-use

Connect-MgGraph -TenantId $tenantId #connect
Get-MgUser #print users to the screen to start with *something* to show that we've been successfull
$allUsers= Get-MgUser #add all the returend objects to an array, it's brought back some mailboxes too
$allUsers[-1] #check the last object in the array as we could see in the terminal it was a mailbox, find the closest thing to a name property for the object

#we *can* split on space and omit anything with the first object in the resulting array from the split with "SMBX" (as we had given this prefix to our shared mailboxes on creation to denote them as different to users)
$userObjects = $allUsers | Where-Object {($_.DisplayName).split(" ")[0] -ne "SMBX"} #don't use shorthand % to start with

#we now have user objects only (not full-proof obviously as 'displayname' property is not immutable, it can be changed), as a fast way to check the data:
$userObjects.count #count
#or
$userObjects | Measure-Object #count

$userObjects.DisplayName #print everyone's name
