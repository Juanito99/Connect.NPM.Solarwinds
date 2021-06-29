param($sourceId, $managedEntityId, $NPMRegPath, $SwitchNamePattern, $CoreSwitchNamePattern, $ArubaControllerNamePattern, $RouterNamePattern, $FireWallNamePattern, $OtherDeviceNamePattern, $ICMPEndPointNamePattern, $MonitorItem,$Threshold)

$api  = New-Object -ComObject 'MOM.ScriptAPI'

$Global:Error.Clear()
$ErrorActionPreference = 'Stop'

$testedAt = "Tested on: $(Get-Date -Format u) / $(([TimeZoneInfo]::Local).DisplayName)"

$dbgLog = "C:\Temp\solarwinds-monitor-debug-" + $MonitorItem +"-log"

#region PREWORK Disabling the certificate validations
add-type -TypeDefinition @"
	using System.Net;
	using System.Security.Cryptography.X509Certificates;
	public class TrustAllCertsPolicy : ICertificatePolicy {
		public bool CheckValidationResult(
			ServicePoint srvPoint, X509Certificate certificate,
			WebRequest request, int certificateProblem) {
			return true;
		}
	}
"@
[Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy
#endregion PREWORK



if ($NPMRegPath -notmatch 'HKLM') {
	$NPMRegPath = 'HKLM:\' + $NPMRegPath 
} 

$npmServerProtocoll       = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerProtocoll
$npmServerName            = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerName
$npmServerPort            = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerPort
$npmInformationServiceURL = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMInformationServiceURL
$npmQryUsr                = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMQryUsr
$npmQryPwd                = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMQryPwd

#$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7000,4,"MonitorNPMNodes Started - Source $($sourceId) managEnt $($managedEntityId) MonitorItem $MonitorItem Key $NPMRegPath `n SWITHCH: $($SwitchNamePattern) Core: $($CoreSwitchNamePattern) Aruba: $($ArubaControllerNamePattern) Router: $($RouterNamePattern)) FW: $($FireWallNamePattern) Other: $($OtherDeviceNamePattern)")

#$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',6000,2,"MonitorNPMNodes Started - Source $($sourceId) managEnt $($managedEntityId) discoveryItem $discoveryItem registry Key $NPMRegPath `n SWITHCH: $($SwitchNamePattern) Core: $($CoreSwitchNamePattern) Aruba: $($ArubaControllerNamePattern) Router: $($RouterNamePattern)) FW: $($FireWallNamePattern) Other: $($OtherDeviceNamePattern)")
 
#$qrySQL     = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
#$qrySQL    += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
#$qrySQL    += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
#$qrySQL    += "FROM+Orion.Nodes+WHERE+ObjectSubType='SNMP'"

$MonitorItemSwitch = $MonitorItem.ToLower()
switch ($MonitorItemSwitch) {
	'router' {		
		$inQrySQL = $RouterNamePattern -replace '\s','+'		
		#$qrySQL  = "SELECT+NodeID,NodeCaption,AgentIP,Status,SysContact,SysLocation,"
		#$qrySQL += "MachineType,City+FROM+NCM.Nodes+WHERE+$($inQrySQL)"		
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes Router QRY : $($qrySQL)")				
		break
	}
	'switch' {
		$inQrySQL = $SwitchNamePattern -replace '\s','+'	
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes Switch QRY : $($qrySQL)")	
		break
	}
	'coreswitch' {
		$inQrySQL = $CoreSwitchNamePattern -replace '\s','+'
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes CoreSwitch QRY : $($qrySQL)")	
		break
	}
	'firewall' {
		$inQrySQL = $FireWallNamePattern -replace '\s','+'
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes Firewall QRY : $($qrySQL)")				
		break
	}
	'arubacontroller' {
		$inQrySQL = $ArubaControllerNamePattern -replace '\s','+'
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes Arubacontroller QRY : $($qrySQL)")				
		break
	}
	'otherdevice' {
		$inQrySQL = $OtherDeviceNamePattern -replace '\s','+'
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+$($inQrySQL)"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes Otherdevice QRY : $($qrySQL)")				
		break
	}	
	'icmpendpoint' {		
		$inQrySQL = $ICMPEndPointNamePattern -replace '\s','+'
		$qrySQL   = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
		$qrySQL  += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
		$qrySQL  += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
		$qrySQL  += "FROM+Orion.Nodes+WHERE+ObjectSubType='ICMP'"		
		$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7006,2,"MonitorNPMNodes ICMPEndpoint QRY : $($qrySQL)")				
		break
	}	

}


$npmFullUrl = $npmServerProtocoll + '://' + $npmServerName + ':' + $npmServerPort + '/' + $npmInformationServiceURL + 'query=' + $qrySQL

#$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7007,4,"MonitorNPMNodes Qry URL: $npmFullUrl  with User: $npmQryUsr, PWD = $npmQryPwd" )

$npmSecPwd  = ConvertTo-SecureString $npmQryPwd -AsPlainText -Force
$npmCreds   = New-Object System.Management.Automation.PSCredential ($npmQryUsr, $npmSecPwd)

$npmQryRsp  = Invoke-RestMethod -Method Get -Uri $npmFullUrl -Credential $npmCreds -UseBasicParsing 

$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7008,1,"MonitorNPMNodes Qry Count $(($npmQryRsp.results).count) for $($MonitorItem)" )

if ($error) {
	$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',7066,1,"Error: $($Error)  ")
}

Get-Date | Out-File -FilePath $dbgLog

$npmQryRsp.results | ForEach-Object {

	$nNodeID          = $_.NodeID			-as [string]      
	$nCaption         = $_.Caption			-as [string]
	$nNodeName        = $_.NodeName			-as [string]
	$nIPAddress       = $_.IPAddress		-as [string]
	$nIP              = $_.IP				-as [string]
	$nNodeDescription = $_.NodeDescription	-as [string]
	$nDescription     = $_.Description		-as [string]
	$nDNS             = $_.DMS				-as [string]
	$nVendor          = $_.Vendor			-as [string]
	$nContact         = $_.Contact			-as [string]
	$nLocation        = $_.Location			-as [string]
	$nSysObjectID     = $_.SysObjectID		-as [string]
	$nObjectSubType   = $_.ObjectSubType	-as [string]
	$nMachineType     = $_.MachineType		-as [string]
	$nLastBoot        = $_.LastBoot			-as [string]
	$nIOSImage        = $_.IOSImage			-as [string]
	$nIOSVersion      = $_.IOSVersion		-as [string]
	$nCPUCount        = $_.CPUCount			-as [string]
	$nTotalMemory     = $_.TotalMemory		-as [string]
	$nAgentPort       = $_.AgentPort		-as [string]
	$nSNMPVersion     = $_.SNMPVersion		-as [string]
	$nCommunity       = $_.Community		-as [string]
	$nStatus		  = $_.Status			-as [string]

	if ([String]::IsNullOrEmpty($nNodeID))          {continue}
	if ([String]::IsNullOrEmpty($nCaption))         {$nCaption = '.'}
	if ([String]::IsNullOrEmpty($nNodeName))        {$nNodeName = '.'}
	if ([String]::IsNullOrEmpty($nIPAddress))       {$nIPAddress = '.'}
	if ([String]::IsNullOrEmpty($nIP))              {$nIP = '.'}
	if ([String]::IsNullOrEmpty($nNodeDescription)) {$nNodeDescription = '.'}
	if ([String]::IsNullOrEmpty($nDescription))     {$nDescription = '.'}
	if ([String]::IsNullOrEmpty($nDNS))             {$nDNS = '.'}
	if ([String]::IsNullOrEmpty($nVendor))          {$nVendor = '.'}
	if ([String]::IsNullOrEmpty($nContact))         {$nContact = '.'}
	if ([String]::IsNullOrEmpty($nLocation))        {$nLocation = '.'}	
	if ([String]::IsNullOrEmpty($nSysObjectID))     {$nSysObjectID = '.'}
	if ([String]::IsNullOrEmpty($nObjectSubType))   {$nObjectSubType = '.'}
	if ([String]::IsNullOrEmpty($nMachineType))     {$nMachineType = '.'}
	if ([String]::IsNullOrEmpty($nLastBoot))        {$nLastBoot = '.'}
	if ([String]::IsNullOrEmpty($nIOSImage))        {$nIOSImage = '.'}
	if ([String]::IsNullOrEmpty($nIOSVersion))      {$nIOSVersion = '.'}	
	if ([String]::IsNullOrEmpty($nCPUCount))        {$nCPUCount = '.'}
	if ([String]::IsNullOrEmpty($nTotalMemory))     {$nTotalMemory = '.'}
	if ([String]::IsNullOrEmpty($nAgentPort))       {$nAgentPort = '.'}
	if ([String]::IsNullOrEmpty($nSNMPVersion))     {$nSNMPVersion = '.'}
	if ([String]::IsNullOrEmpty($nCommunity))       {$nCommunity = '.'}

	if ($nTotalMemory -ne '.') {
		$nTotalMemoryOrg = ''
		$nTotalMemoryOrg = $nTotalMemory
		[int64]$rndMem   = 0
		$nTotalMemory    = $nTotalMemory -as [int64]
		$nTotalMemory    = $nTotalMemory.ToString()
		$nMemLen         = $nTotalMemory.Length
		if ($nMemLen -gt 3) {
			$tmpFourNum   = ($nTotalMemory.Substring(0,4)) -as [int64]
			$tmpMissNum   = ($nMemLen - 4) -as [int64]
			$tmpSuffNum   = ([math]::Pow(10,$tmpMissNum)) -as [int64]
			$rndMem       = $tmpFourNum * $tmpSuffNum
			$nTotalMemory = ''
			$nTotalMemory = $rndMem.ToString()
		}
	}

	$nStatus = $nStatus -replace '\s',''
	$nStatus = $nStatus -replace ' ',''
	$nStatus = $nStatus.Replace(' ','')
	$nStatus = $nStatus.Trim()

	if ($nStatus -eq '1') {
		$state = 'Green'		
	} elseif ($nStatus -eq '2')  {
		$state = 'Red'
	} else {
		$state = 'Yellow'
	}

	if ($nCaption.Length -le 3) { $nCaption = "Capt: $nNodeName" } 
	
	$supplement = " IP: $($nIP)`n Status: $($nStatus)`n Contact: $($nContact)`n Location: $($nLocation)`n LastBoot: $($nLastBoot)"
	$supplement2 = " IP: $($nIP); Status: $($nStatus); Contact: $($nContact); Location: $($nLocation); LastBoot: $($nLastBoot)"
	$displayName = $MonitorItem + "-" + $nCaption

	$api.LogScriptEvent('Connect.NPM.SolarWinds MonitorNPMNodes.ps1',6070,2,"MonitorNPMNodes SEND BAG Key: $($nNodeID) `n State: $($state) `n Caption: ($nCaption) `n Supplement: $($supplement) ")
	"MonitorNPMNodes SEND BAG Key:$($nNodeID);State:$($state);NodeCaption:$($nCaption);DisplayName:$($DisplayName);Supplement:$($supplement2);TesteadAt:$($testedAt) " | Out-File -FilePath $dbgLog -Append	
	if ($error) { $error | Out-File -FilePath $dbgLog -Append }
	
	$nNodeID = $nNodeID -as [string]
	$nNodeID = $nNodeID -replace '\s',''
	$nNodeID = $nNodeID -replace ' ',''
	$nNodeID = $nNodeID.Trim()
		
	$bag = $api.CreatePropertybag()					
	$bag.AddValue("Key",$nNodeID)
	$bag.AddValue("NodeID",$nNodeID)
	$bag.AddValue("Name",$nNodeID)	
	$bag.AddValue("DisplayName",$displayName)
	$bag.AddValue("NodeName",$nNodeName)	
	$bag.AddValue("Caption",$nCaption)			
	$bag.AddValue("State",$state)				
	$bag.AddValue("Supplement",$supplement)		
	$bag.AddValue("TestedAt",$testedAt)			
	$bag
	
}

