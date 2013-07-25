<#
$Metadata = @{
    Title = "Get SharePoint Object Permissions"
	Filename = "Get-SPObjectPermissions.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-07-25"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPObjectPermissions{

<#

.SYNOPSIS
    Get permissions on SharePoint objects.

.DESCRIPTION
	Get permissions on SharePoint objects.
    
.PARAMETER Identity
	Url of the SharePoint website.
    
.PARAMETER IncludeChildItems
	Requires Identity, includes the child items of the specified website.
    
.PARAMETER Recursive
	Requires Identity, includes the every sub item of the specified website.
    
.PARAMETER OnlyLists
	Only report list items.
    
.PARAMETER OnlyWebsites
	Only report website items.

.EXAMPLE
	PS C:\> Get-SPObjectPermissions -Identity "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -IncludeChildItems -Recursive -OnlyLists -OnlyWebsites

#>

	param(
		[Parameter(Mandatory=$false)]
		[string]$Identity,
		
		[switch]$IncludeChildItems,

		[switch]$Recursive,
        
        [switch]$OnlyLists,
        
        [switch]$OnlyWebsites
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
        Add-PSSnapin “Microsoft.SharePoint.PowerShell”
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    # array for the output data    
    $SPObjectPermissions = @()
    
    # array for the website objects
    $SPWebs = @()
    
    # check if url has bee passed
    if($Identity -ne $Null){
    
        # get url
        [Uri]$SPWebUrl = $Identity.ToString() -replace "/SitePages/Homepage.aspx",""
                
        if($IncludeChildItems -and -not $Recursive){
        
            # get spweb object and child spweb objects
            $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString
            $SPWebs += $SPWeb
            $SPWebs += $SPWeb.webs            
        
        }elseif($Recursive -and -not $IncludeChildItems){
        
            # get all sp subsites
            $SPWebs = Get-SPSubwebs -Identity $SPWebUrl.OriginalString
        }else{
        
            # only add this website
            $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString
            $SPWebs += $SPWeb
        }        
     }else{
    
        # Get all Webapplictons
        $SPWebApps = Get-SPWebApplication
        
        # Get all sites
        $SPSites = $SPWebApps | Get-SPsite -Limit all 
    
        foreach($SPSite in $SPSites){

            # Get all websites
            $SPWebs = $SPSite | Get-SPWeb -Limit all
    
        }
    }
           
    #Loop through each website and write permissions
    foreach ($SPWeb in $SPWebs){

        Write-Progress -Activity "Read permissions" -status $SPWeb -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
            
        if (($SPWeb.permissions -ne $null) -and  ($SPWeb.HasUniqueRoleAssignments) -and -not $OnlyLists){  
                
            foreach ($RoleAssignment in $SPWeb.RoleAssignments){
            
                # get member
                $Member =  $RoleAssignment.Member.UserLogin -replace ".*\\",""
                if($Member -eq ""){
					 $Member =  $RoleAssignment.Member.LoginName
				}
                                        
                # get permission definition
                $Permission = $RoleAssignment.roledefinitionbindings[0].Name
                
                # add to report
                $SPObjectPermissions += New-ObjectSPReportItem -Name $SPWeb -Url $SPWeb.url -Member $Member -Permission $Permission -Type "Website"
            }        
        }
        
        # output list permissions
        if(-not $OnlyWebsites){                
            foreach ($SPlist in $SPWeb.lists){
                
                if (($SPlist.permissions -ne $null) -and ($SPlist.HasUniqueRoleAssignments)){  
                      
                    foreach ($RoleAssignment in $SPlist.RoleAssignments){
                    
                        # set list url
                        $SPListUrl = $SPWeb.url + "/" + $SPlist.Title 
                                                    
                        # get member
                        $Member =  $RoleAssignment.Member.UserLogin -replace ".*?\\",""
                        if($Member -eq ""){
                            $Member =  $RoleAssignment.Member.LoginName
                        }
                                                    
                        # get permission definition
                        $Permission = $RoleAssignment.roledefinitionbindings[0].Name   
                                                 
                        # add to report
                        $SPObjectPermissions += New-ObjectSPReportItem -Name $SPlist.Title -Url $SPListUrl -Member $Member -Permission $Permission -Type "List"
                    }
                }
            }
        }                
    }

    return $SPObjectPermissions

}

# Get-SPObjectPermissions -Identity "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -IncludeChildItems -Recursive -OnlyLists