#functions for creation

#users
#mailboxes
#security groups - done
#mail-enabled security groups
#365 groups
#Sharepoint sites

#>  notes
###create functions for each individual object type, build a more efficient combined function after we know how to build each one
###for groups, we will be the default owner as the creator (we are connected interatively, if we were connected with app-only access we should specify an owner in the request)
###We should add MS Team functionality automatically for 365 groups to complete the suite of available end-user tools - this is still not enforced by the 365 group create operation on Graph, so we add an extra function to add a new MS Team to the new 365 group as part of the function
###omit error handling for now, we're just writing some very basic functions outside of a production environment - we can add error handling if we need to here to get the basic functionality working as we test however. 

#functions
function create-SecurityGroup {
    [cmdletbinding()] 
    param( 
        [string]$groupName, 
        [string]$groupDescription
    ) 

    #body
    $bodyHash = @{
    'description' = "$($groupDescription)"
    'displayName' = "$($groupName)"
    'groupTypes' = @()
    'mailEnabled' = $false
    'mailNickname' = "None"
    'securityEnabled' = $true
    }
    $bodyJson = convertTo-Json -inputObject $bodyHash

    #endpoint
    $output = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -body $bodyJson -OutputType PSObject
    return $output
}

function create-UnifiedGroup {
[cmdletbinding()]
param(
    [string]$groupName,
    [string]$groupDescription
)

#body
    $bodyHash = @{
    'description' = "$($groupDescription)"
    'displayName' = "$($groupName)"
    'groupTypes' = @('unified')
    'mailEnabled' = $true
    'mailNickname' = "$($groupName)"
    'securityEnabled' = $true
    }
    $bodyJson = convertTo-Json -inputObject $bodyHash

    #endpoint
    $output = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -body $bodyJson -OutputType PSObject
    return $output

}

function create-TeamForUnifiedGroup {
[cmdletbinding()]
param(
    [string]$unifiedGroupGUID
)

#disable private channels, they cause weird backend behaviour for Sharepoint sites (creates a standalone site for backend storage for the channel that looks wholly disconnected from the MS Team for admins)
    $bodyHash = @{
        memberSettings = @{
            allowCreatePrivateChannels = $false
            allowCreateUpdateChannels = $true
        }
        messagingSettings = @{
            allowUserEditMessages = $true
            allowUserDeleteMessages = $true
        }
        funSettings = @{
            allowGiphy = $true
            giphyContentRating = "strict"
        }
    }
    $bodyJson = convertTo-Json -inputObject $bodyHash

    #MS recommended retry logic - up to 3 times, with 10 seconds between each attempt
    $attemptNumber = 0
    while($attemptNumber -ne 2){
    
    #print some useful information in a verbose manner (we can let the executing user of the function turn this off if they want)
    Write-Verbose "Attempt-number: $($attemptNumber)"
   
    $output = Invoke-MgGraphRequest -Method PUT -Uri "https://graph.microsoft.com/v1.0/groups/$($unifiedGroupGUID)/team" -body $bodyJson -OutputType PSObject
    Write-Verbose "Output: $($output)"
    #if we don't get an object with an id property, it has failed, increment the try counter by 1 - we could use http status codes, but these are a little ureliable in some cases (I prefer to check the existance of something, rather than relying on the server-side vendor to tell us)
    if(Get-Member -inputobject $output -name "id" -Membertype Properties -ErrorAction SilentlyContinue){
        return $output
    }
    else{
        start-sleep -Seconds 10
        $attemptNumber ++
    }
    }
}

#connect and execute
Connect-MgGraph

create-SecurityGroup -groupName "test1" -groupDescription "groupdesc" -verbose
$newUnifiedGroup = create-UnifiedGroup -groupName "test7" -groupDescription "groupdesc" -Verbose
#add MS Team to new unified group separately, MS docs recommend strong retry logic for this as there may be server-side delays in propagation, handling this in the same function as the group creation has too much liability
#>see more: https://learn.microsoft.com/pl-pl/graph/api/team-put-teams?view=graph-rest-1.0&tabs=http
$newTeamForUnifiedGroup = create-TeamForUnifiedGroup -unifiedGroupGUID $newUnifiedGroup.id -Verbose
