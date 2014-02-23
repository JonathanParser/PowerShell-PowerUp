<#
$Metadata = @{
	Title = "Submit-SPPSCheckIn"
	Filename = "Submit-SPPSCheckIn.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = ""
	Author = "Jeffrey Paarhuis"
	AuthorContact = "http://jeffreypaarhuis.com/"
	CreateDate = "2013-02-2"
	LastEditDate = "2014-02-2"
	Url = ""
	Version = "0.1.2"
	License = @'
The MIT License (MIT)
Copyright (c) 2014 Jeffrey Paarhuis
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'@
}
#>

function Submit-SPPSCheckIn
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string]$targetPath
	)
	
	$targetPath = Join-SPPSParts -Separator '/' -Parts $clientContext.Site.ServerRelativeUrl, $targetPath
	
    $remotefile = $clientContext.Web.GetFileByServerRelativeUrl($targetPath)
    $clientContext.Load($remotefile)
    $clientContext.ExecuteQuery()
    
    $remotefile.CheckIn("",[Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
    
    $clientContext.ExecuteQuery()
}