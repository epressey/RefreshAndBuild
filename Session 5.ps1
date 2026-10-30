#functions for creation

#users
#mailboxes
#security groups - done
#mail-enabled security groups
#365 groups
#Sharepoint sites


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

Connect-MgGraph

create-SecurityGroup -groupName "test1" -groupDescription "groupdesc" -verbose
