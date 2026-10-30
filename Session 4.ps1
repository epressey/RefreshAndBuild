#get all modules, see if we have a verison of PnP installed already - PnP versioning is a right pain (we can use Graph, but we're refreshing memory - not everything can be done in Graph)
$modules = get-module -ListAvailable
$modules | where-object {$_.Name -match "PnP"} #print any with a name that matches PnP

#install PnP
Install-Module -Name PnP.PowerShell -RequiredVersion 3.4.1

#register a new app in EntraID, required for PnP now (not just as best practise), 'interactive' switch is required despite official docs not stating otherwise - it isn't default
Register-PnPEntraIDAppForInteractiveLogin -ApplicationName "PnP.PowerShell" -Tenant 'heraklion.onmicrosoft.com' -Interactive

#store newly created app ID
$clientID = ""

#connect, pass in the 
Connect-PnPOnline -url "https://heraklion-admin.sharepoint.com/" -ClientId $clientID -Interactive

#get all sites, while being connect to the admin site
$allSites = Get-PnPTenantSite
$allSites #print it, PnP returns a very minimum number of fields and needs more explicit guidance for anything else