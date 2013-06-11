param([switch]$OutPutToGridView, [parameter(Mandatory=$true)][String]$Path, [parameter(Mandatory=$true)][int]$Levels)

$Metadata = @{
	Title = "Report Filesystem Permissions"
	Filename = "Report-FileSystemPermissions.ps1"
	Description = ""
	Tags = "powershell, function, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-03-14"
	LastEditDate = "2013-05-15"
	Version = "2.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
.EXAMPLE
    .\Report-FileSystemPermissions -OutPutToGridView -Path "D:\Dat" -Levels 3

.EXAMPLE
    $Report = .\Report-FileSystemPermissions.ps1 -Path "D:\Dat" -Levels 3

#>

#--------------------------------------------------#
# functions
#--------------------------------------------------#

# this function is included due to remote execution dependencies
function Get-ChildItemRecurse{

<#
	.SYNOPSIS
		Return a list of of files

	.DESCRIPTION
		A detailed description of the function.

	.PARAMETER  Path
		Paht to cycle through.

	.PARAMETER  OnlyDirectories
		Switch parameter wether only to show directories

	.PARAMETER  Levels
		Scope levels.

	.EXAMPLE
		Get-ChildItemRecurse -Path C:\ -OnlyDirectories -Levels 3
		
#>
	
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
	    [parameter(Mandatory=$true)]
	    [String]
		$Path,
        [parameter(Mandatory=$false)]
        [int]
        $Levels = 0,
        [switch]
        $OnlyDirectories
	)

	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#

    if($Host.Version.Major -lt 1){
        throw "Only compatible with Powershell version 2 and higher"
    }else{

        if($OnlyDirectories){
        
            $files = @(Get-ChildItem $Path -Force | Where {$_.PSIsContainer})
            $OnlyDirectories = $true
            
        }else{
        
            $files = @(Get-ChildItem $Path -Force)
            $OnlyDirectories = $false
            
        }


        foreach ($file in $files) {
            
            Write-Progress -Activity "collecting data" -status $file.Fullname -percentComplete ([int]([array]::IndexOf($files, $file)/$files.Count*100))
            
            Write-Output $file

            if ($levels -gt 0 -and $file.PSIsContainer) {

                Get-ChildItemRecurse -Path $file.FullName -Levels ($levels - 1) -OnlyDirectories:$OnlyDirectories

            }
        }
    }
}

#--------------------------------------------------#
# Main
#--------------------------------------------------#

$FileSystemPermissionReport = @()

function New-SPReportItem {
    param(
        $Name,
        $Url,
        $Member,
        $Permission,
        $Type
    )
    New-Object PSObject -Property @{
        Name = $Name
        Url = $Url
        Member = $Member
        Permission = $Permission
        Type = $Type
    }
}

$FSfolders = Get-ChildItemRecurse -Path $Path -Levels $Levels -OnlyDirectories

foreach ($FSfolder in $FSfolders)
{

    Write-Progress -Activity "anlayse access rights" -status $FSfolder.FullName -percentComplete ([int]([array]::IndexOf($FSfolders, $FSfolder)/$FSfolders.Count*100))
    
    # read access rights
    $Acls = Get-Acl -Path $FSfolder.Fullname

    foreach($Acl in $Acls.Access){

        if($Acl.IsInherited -eq $false){
            
            $Member = $Acl.IdentityReference  -replace "VBL\\","" 
    
            $FileSystemPermissionReport += New-SPReportItem -Name $FSfolder.Name -Url $FSfolder.FullName -Member $Member -Permission $Acl.FileSystemRights   -Type "Directory"

        }else{
            break
        }
    }
}

if($OutPutToGridView -eq $true){

    $FileSystemPermissionReport | Out-GridView
    
    Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green
    Read-Host "`nPress Enter to exit"
    
}else{

    return $FileSystemPermissionReport
    
}