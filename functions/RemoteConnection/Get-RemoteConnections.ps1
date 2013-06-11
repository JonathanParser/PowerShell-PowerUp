﻿function Get-RemoteConnections{

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
        [parameter(Mandatory=$false)]
        [string[]] 
        $Names,
        [parameter(Mandatory=$false)]
        [Switch]
        $ListAvailable
	)

	$Metadata = @{
		Title = "Get Remote Connections"
		Filename = "Get-RemoteConnections.ps1"
		Description = ""
		Tags = "powershell, function, remote"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-04-08"
		LastEditDate = "2013-05-11"
		Version = "3.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
    
    # Server configuration collection
	$ServerConfigs = @()
    
    # server data collection
    $Servers = @()
    
    # load configuration files
    $ConfigurationFiles = Get-ChildItem -Path $PSconfigs.Path -Filter "*.remote.config.*" -Recurse
    
    # merge information
    foreach($ConfigurationFile in $ConfigurationFiles){
        [xml]$Content  = Get-Content $ConfigurationFile.FullName
        $ServerConfig = $Content.Content.Server
        $ServerConfigs += $ServerConfig
    }
    
    # check ListAvailable-parameter
    if($ListAvailable -and $Names -eq $null){
		try{
			$ServerConfigs | Out-Gridview
		}catch{
			$error[0]
			$ServerConfigs | format-table
		}
    }else{
        if($Names -ne $null){

            # search server by key and name
            foreach($Server in $ServerConfigs){
			
                if($Names -contains $Server.Key -or $Names -contains $Server.Name){
                    $Servers += $Server
                }
            }
            
            # check result
            if($Servers.count -eq 0){
                foreach($Name in $Names){
                    $Servers += New-ObjectRemoteConnection -Name $Name
                }
            }
            
            $Servers
            
        }else{
            throw "Enter values for the following parameters: Names[]"  
        }
    }
}