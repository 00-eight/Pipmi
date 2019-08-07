function Set-iDRACPassword {
    <#
    .Synopsis
        Set Password for Local user in iDRAC
    .Description
        Set Password for Local user in iDRAC
    .Example
        Set-iDRACPassword -CimSession $remoteSystem -userindex 2 -password calvin
    .Parameter CimSession
        Used to execute this cmdlet against a remote system.  See New-CimSession cmdlet on creating a CimSession.
        If not specified, cmdlet is executed against local machine.  Administrator rights required to execute IPMI commands.
    #>
    [CmdletBinding(DefaultParametersetName="CimSession")]
    Param (
        [Parameter(ParameterSetName="CimSession",Position=0)]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,
        [Parameter(Mandatory=$true, HelpMessage="Enter iDRAC Local User Index between 2 and 16")]
        [ValidateRange(2,16)]
        [byte] $user,
        [Parameter(Mandatory=$true, HelpMessage="Enter Password up to 20 characters")]
        [ValidateLength(1,20)] 
        [string] $password)

    Process {
        $ErrorActionPreference = "Stop"
        [byte] $userindex = $user + 0x80
        [byte] $databyte2 = 0x2
        [System.Text.Encoding] $encoding = [System.Text.Encoding]::ASCII
        [byte[]] $pwdbytes = $encoding.GetBytes($password)
        [System.Collections.ArrayList] $requestData = @($userindex, $databyte2)
        for ($i = 0; $i -lt $pwdbytes.Length; $i++){
            $requestData.Add($pwdbytes[$i]) | Out-Null
        }
        [byte] $numpadbyte = [math]::Abs($pwdbytes.Length - 20)
        if ($numpadbyte) {
            for ($i = 0; $i -lt $numpadbyte; $i++) {
                $requestData.Add([byte]0x00) | Out-Null
            }
        }
        
        Write-Debug "SetiDRACPasswordCmd -Command $SetiDRACPasswordCmd -RquestData $requestData"
        $out = Invoke-IPMIRequestResponse -CimSession $CimSession -Command $SetiDRACPasswordCmd -RequestData $requestData
        
    }
}