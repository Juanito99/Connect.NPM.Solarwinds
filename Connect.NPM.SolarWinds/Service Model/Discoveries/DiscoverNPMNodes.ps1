param($sourceId, $managedEntityId, $NPMRegPath, $SwitchNamePattern, $CoreSwitchNamePattern, $ArubaControllerNamePattern, $RouterNamePattern, $FireWallNamePattern, $OtherDeviceNamePattern)

$api           = New-Object -ComObject 'MOM.ScriptAPI'
$discoveryData = $api.CreateDiscoveryData(0, $sourceId, $managedEntityId)

$Global:Error.Clear()
$ErrorActionPreference = 'Continue' 

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

#$api.LogScriptEvent('Connect.NPM.SolarWindsDiscoverNPMNodes.ps1',5000,4,"DiscoverNPMNodes Started - Source $($sourceId) managEnt $($managedEntityId) discoveryItem $discoveryItem registry Key $NPMRegPath `n SWITHCH: $($SwitchNamePattern) Core: $($CoreSwitchNamePattern) Aruba: $($ArubaControllerNamePattern) Router: $($RouterNamePattern)) FW: $($FireWallNamePattern) Other: $($OtherDeviceNamePattern)")
 
$NPMRegPath               = 'HKLM:\' + $NPMRegPath
$npmServerProtocoll       = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerProtocoll
$npmServerName            = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerName
$npmServerPort            = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMServerPort
$npmInformationServiceURL = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMInformationServiceURL
$npmQryUsr                = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMQryUsr
$npmQryPwd                = Get-ItemProperty -Path $NPMRegPath | Select-Object -ExpandProperty NPMQryPwd

# Below discovery of Nodes

$npmSecPwd  = ConvertTo-SecureString $npmQryPwd -AsPlainText -Force
$npmCreds   = New-Object System.Management.Automation.PSCredential ($npmQryUsr, $npmSecPwd)


$qrySQL     = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
$qrySQL    += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
$qrySQL    += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
$qrySQL    += "FROM+Orion.Nodes+WHERE+ObjectSubType='SNMP'"

$npmFullUrl = $npmServerProtocoll + '://' + $npmServerName + ':' + $npmServerPort + '/' + $npmInformationServiceURL + 'query=' + $qrySQL

#$api.LogScriptEvent('Connect.NPM.SolarWindsDiscoverNPMNodes.ps1',5001,4,"DiscoverNPMNodes Qry URL: $npmFullUrl  with User: $npmQryUsr found pwd in $npmQryPwdPath " )

$npmQryRsp  = Invoke-RestMethod -Method Get -Uri $npmFullUrl -Credential $npmCreds -UseBasicParsing 

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

	$msg  = " Values: `n "
	$msg += " TotalMemOrg : $($nTotalMemoryOrg)"
	$msg += " nMemLen : $($nMemLen)"
	$msg += " tmpFourNum : $($tmpFourNum)"
	$msg += " tmpMissNum : $($tmpMissNum)"
	$msg += " tmpSuffNum : $($tmpSuffNum)"
	$msg += " rndMem : $($rndMem)"
	$msg += " nTotalMemory : $($nTotalMemory)"

	#$api.LogScriptEvent('Connect.NPM.SolarWindsDiscoverNPMNodes.ps1',5001,2,"DiscoverNPMNodes MSG: `n $($msg)" )

	switch -regex ($nCaption) {
		
		$RouterNamePattern {
			$displayName = 'Router-' + $nCaption			
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.Router']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)			
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
			$discoveryData.AddInstance($instance)					
		  break
		}		
		$SwitchNamePattern {
		  $displayName = 'Switch-' + $nCaption
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.Switch']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
			$discoveryData.AddInstance($instance)		
		  break
		}		
		$CoreSwitchNamePattern {
			$displayName = 'CoreSwitch-' + $nCaption			
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.CoreSwitch']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
			$discoveryData.AddInstance($instance)					
		  break
		}
		$FireWallNamePattern {		
			$displayName = 'FireWall-' + $nCaption			
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.FireWall']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
			$discoveryData.AddInstance($instance)					
		  break
		}		
		$ArubaControllerNamePattern {
			$displayName = 'ArubaController-' + $nCaption			
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.ArubaController']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)	
			$discoveryData.AddInstance($instance)					
		  break
		}
		$OtherDeviceNamePattern {		  
			$displayName = 'OtherDevice-' + $nCaption			
			$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.OtherDevice']$")			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
			$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
			$discoveryData.AddInstance($instance)					
			break
		}

	}
		
} #END $npmQryRsp.results | ForEach-Object 


#$qrySQL  = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,DNS,Vendor,Status,"
#$qrySQL += "StatusDescription+FROM+Orion.Nodes+WHERE+ObjectSubType='ICMP'"

$qrySQL     = "SELECT+NodeID,ObjectSubType,IPAddress,Caption,NodeDescription,Description,DNS,Vendor,SysObjectID,Location,"
$qrySQL    += "Contact,Status,StatusDescription,IOSImage,IOSVersion,LastBoot,CPUCount,CPULoad,TotalMemory,"
$qrySQL    += "PercentMemoryAvailable,MachineType,AgentPort,SNMPVersion,Community,IP,NodeName+"
$qrySQL    += "FROM+Orion.Nodes+WHERE+ObjectSubType='ICMP'"

$npmFullUrl = $npmServerProtocoll + '://' + $npmServerName + ':' + $npmServerPort + '/' + $npmInformationServiceURL + 'query=' + $qrySQL
$npmQryRsp  = Invoke-RestMethod -Method Get -Uri $npmFullUrl -Credential $npmCreds -UseBasicParsing 

$api.LogScriptEvent('Connect.NPM.SolarWindsDiscoverNPMNodes.ps1',5010,2,"DiscoverNPMNodes No: $(($npmQryRsp.results).count) - `n $($npmFullUrl) " )

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

	$nNodeID = $nNodeID -as [string]
	$nNodeID = $nNodeID -replace '\s',''
	$nNodeID = $nNodeID -replace ' ',''
	$nNodeID = $nNodeID.Trim()

	$displayName = 'ICMPEndPoint-' + $nCaption			
	$instance = $discoveryData.CreateClassInstance("$MPElement[Name='Connect.NPM.SolarWinds.ICMPEndPoint']$")			
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeID$",$nNodeID)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Caption$",$nCaption)			
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeName$",$nNodeName)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IPAddress$",$nIPAddress)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IP$",$nIP)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/NodeDescription$",$nNodeDescription)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Description$",$nDescription)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/DNS$",$nDNS)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Vendor$",$nVendor)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Contact$",$nContact)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Location$",$nLocation)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SysObjectID$",$nSysObjectID)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/ObjectSubType$",$nObjectSubType)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/MachineType$",$nMachineType)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/LastBoot$",$nLastBoot)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSImage$",$nIOSImage)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/IOSVersion$",$nIOSVersion)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/CPUCount$",$nCPUCount)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/TotalMemory$",$nTotalMemory)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/AgentPort$",$nAgentPort)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/SNMPVersion$",$nSNMPVersion)
	$instance.AddProperty("$MPElement[Name='Connect.NPM.SolarWinds.Node']/Community$",$nCommunity)
	$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
	$discoveryData.AddInstance($instance)					
	
	
} #END $npmQryRsp.results | ForEach-Object 


$discoveryData