#install Graph auth module (not the entire MgGraph module, we just need a way to authenticate and fire requests at Graph API endpoints - using the MgGraph cmdlets abstracts the backend structure we are trying to remember)
Install-Module -Name Microsoft.Graph.Authentication -RequiredVersion 2.0.0

#connect interactively, for delegated access
Connect-MgGraph

#fire a request, see what we get back, users is a very memorable endpoint
$users = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users" -OutputType PSObject
$users.Value #print to screen

#get all groups
$allGroupsResult = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups" -OutputType PSObject
$allGroups = $allGroupsResult.value #returned in nested property, store data in property in another variable

#print displaynames and group types iteratively to see what we've got back at a glance
ForEach($group in $allGroups){
    if($group.groupTypes){
        write-host "$($group.groupTypes): $($group.displayName)"
    }
    else{
        write-host "Security or Mail-Enabled Group: $($group.displayName)" #seems that groupTypes field is still being used for 'unified' or null, if null it's s security or mail-enabled secuirty group, so we'll manually write that part in
    }
}


