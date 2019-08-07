function Dismount-Scratch {
    <#
    .Synopsis
        Remove Scratch
    .Description
        Remove Scratch
    .Example
        Remove-Scratch -CimSession $remoteSystem
    .Parameter CimSession
        Used to execute this cmdlet against a remote system.  See New-CimSession cmdlet on creating a CimSession.
        If not specified, cmdlet is executed against local machine.  Administrator rights required to execute IPMI commands.
    #>
    [CmdletBinding(DefaultParametersetName="CimSession")]
    Param (
        [Parameter(ParameterSetName="CimSession",Position=0)]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession
        )

    Process {
        $ErrorActionPreference = "Stop"
        [System.Collections.ArrayList] $requestData = @($databyte1)
        Write-Debug "Dismount-Scratch -Command $DismountScratchCmd"
        $out = Invoke-IPMIRequestResponse -CimSession $CimSession -Command $DismountScratchCmd
    }
}
