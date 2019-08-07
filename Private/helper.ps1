[byte]$BMCResponderAddress = 0x20
[byte]$GetLANInfoCmd = 0x02
[byte]$GetChannelInfoCmd = 0x42
[byte]$SetSystemInfoCmd = 0x58
[byte]$GetSystemInfoCmd = 0x59
[byte]$DefaultLUN = 0x00
[byte]$IPMBProtocolType = 0x01
[byte]$8023LANMediumType = 0x04
[byte]$MaxChannel = 0x0b
[byte]$EncodingAscii = 0x00
[byte]$MaxSysInfoDataSize = 19
[byte]$SetiDRACPasswordCmd = 0x47
[byte]$MountScratchCmd = 0x10
[byte]$DismountScratchCmd = 0x15

$CompletionCodes = @(
"C0h Node Busy. Command could not be processed because command processing resources are temporarily unavailable.",
"C1h Invalid Command. Used to indicate an unrecognized or unsupported command.",
"C2h Command invalid for given LUN.",
"C3h Timeout while processing command. Response unavailable.",
"C4h Out of space. Command could not be compl eted because of a lack of storage space required to execute the given command operation.",
"C5h Reservation Canceled or Invalid Reservation ID.",
"C6h Request data truncated.",
"C7h Request data length invalid.",
"C8h Request data field length limit exceeded.",
"C9h Parameter out of range. One or more parameters in the data field of the Request are out of range. This is different from ‘Invalid data field’ (CCh) code in that it indicates that the erroneous field(s) has a contiguous range of poss ible values.",
"CAh Cannot return number of requested data bytes.",
"CBh Requested Sensor, data, or record not present.",
"CCh Invalid data field in Request",
"CDh Command illegal for specified sensor or record type.",
"CEh Command response could not be provided.",
"CFh Cannot execute duplicated request. This completion code is for devices which cannot return the response that was returned for the original instance of the request. Such devices should provide separate commands that allow the completion status of the original request to be determined. An Event Receiver does not use this completion code, but returns the 00h completion code in the response to (valid) duplicated requests.",
"D0h Command response could not be provided. SDR Repository in  update mode.",
"D1h Command response could not be provided. Device in firmware update mode.",
"D2h Command response could not be provided. BMC initialization or initialization agent in progress.",
"D3h Destination unavailable. Cannot deliver request  to selected destination. E.g. this code can be returned if a request message is targeted to SMS, but receive message queue reception is disabled for the particular channel.",
"D4h Cannot execute command due to insufficient privilege level or other security-based restriction (e.g. disabled for ‘firmware firewall’).",
"D5h Cannot execute command. Command, or request parameter(s), not supported in present state. ",
"D6h Cannot execute command. Parameter is illegal because command sub-function has been disabled or is unavailable (e.g. disabled for ‘firmware firewall’).")

function Convert-CompletionCodeToText([byte] $code) {
    if ($code -gt 0xD6) {
        return "Unknown error: $code"
    }
    return $CompletionCodes[$code - 0xC0]
}

function Get-NetFn ([byte] $Command) {
    [byte]$TransportNetFn = 0x0c
    [byte]$AppNetFn = 0x06
    [byte]$FirmNetFn = 0x08

    switch ($Command) {
        $GetLANInfoCmd { $TransportNetFn }
        $MountScratchCmd {$FirmNetFn}
        $DismountScratchCmd {$FirmNetFn}
        default { $AppNetFn }
    }
}

function Invoke-IPMIRequestResponse {
    [CmdletBinding(DefaultParametersetName="CimSession")]
    Param (
        [Parameter(ParameterSetName="CimSession",Position=0)]
        [Microsoft.Management.Infrastructure.CimSession] $CimSession,
        [byte]$Command,
        [byte]$LUN = $DefaultLUN,
        [byte[]]$RequestData,
        [byte]$ResponderAddress = $BMCResponderAddress)

    Process {
        $ErrorActionPreference = "SilentlyContinue"

        if ($CimSession -eq $null) {
            $CimSession = New-CimSession
        }

        $ipmi = Get-CimInstance -Namespace root/wmi -CimSession $CimSession Microsoft_IPMI
        $ErrorActionPreference = "Stop"

        if ($null -eq $ipmi) {
            Write-Error "Microsoft IPMI Driver not running on specified system"
        }

        $arguments = @{Command=$Command;LUN=$LUN;NetworkFunction=$(Get-NetFn $command);RequestData=$RequestData;RequestDataSize=[uint32]$RequestData.Length;ResponderAddress=$ResponderAddress}
        Write-Debug "InvokeIPMI -command $command -lun $lun -netfn $(Get-NetFn $command) -requestData $requestData -ResponderAddress $responderaddress"
        $out = Invoke-CimMethod -InputObject $ipmi -CimSession $CimSession RequestResponse -Arguments $arguments
        if ($out.CompletionCode -ne 0) {
            Write-Error ("IPMI Command failed (0x{0:x}): {1}" -f $out.CompletionCode,(Convert-CompletionCodeToText $out.CompletionCode))
        }
        $out.ResponseData
        Write-Debug "InvokeIPMI -responsedata $($out.responseData)"
    }
}
