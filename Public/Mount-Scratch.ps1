function Mount-Scratch {
    <#
    .Synopsis
        Present Scratch
    .Description
        Present Scratch
    .Example
        Mount-Scratch -CimSession $remoteSystem
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
        [byte] $databyte1 = 0x00
        [System.Collections.ArrayList] $requestData = @($databyte1)
        Write-Debug "Mount-Scratch -Command $MountScratchCmd -RquestData $requestData"
        $out = Invoke-IPMIRequestResponse -CimSession $CimSession -Command $MountScratchCmd -RequestData $requestData
    }
}
