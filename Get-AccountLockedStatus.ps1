
<#
.SYNOPSIS
    Get-AccountLocked-Status.ps1 returns event logs from PDC for specified user.
 
.DESCRIPTION
    Get-AccountLocked-Status.ps1 is a script that returns event logs of specified EventId and Users from specified Log File. 
    by querying the event logs on the PDC emulator in the domain.
       
.PARAMETER User
    The userid of the specific user you are searching for lockouts for. The default is mike user.
 
.PARAMETER EventId
    The event id of the event log to be searched. The default value is 4740 (Account Locked Out Event Id).
 
.PARAMETER LogFile
    The name of the Log file. The default is .\Account-Locked.log.

.PARAMETER LogName
    The name of the Log Type (Security, Application, System etc). The default is Security logs.

.PARAMETER Last
    The time period from present time up to which logs are required. The default value is 15 minutes.
 
.EXAMPLE
    Get-AccountLocked-Status.ps1
    This example shows how to get the account status with the default values
 
.EXAMPLE
    Get-AccountLocked-Status.ps1 -User 'mike'
    This example shows how to get the account status for user 'mike'

.EXAMPLE
    Get-AccountLocked-Status.ps1 -EventId <EventId>
    This example shows how to get the account status for event with id <EventId>

.EXAMPLE
    Get-AccountLocked-Status.ps1 -LogFile 'C:\Users\<Username>\Desktop\<Filename>'
    This example shows how to get the account status and log it in the file 'C:\Users\<Username>\Desktop\<Filename>'
  
.EXAMPLE
    Get-AccountLocked-Status.ps1 -LogName 'Application'
    This example shows how to get the account status from the Application logs

.EXAMPLE
    Get-AccountLocked-Status.ps1 -Last 10
    This example shows how to get the account status logs for the last 10 minutes
 
.EXAMPLE
    Get-AccountLocked-Status.ps1 -User 'mike' -LogFile <LogfileName> -LogName 'Application' -EventId 4647 -last 10
    This example shows how to get the account status
    for user 'mike'
    and log it in the file <LogFile>
    from the 'Application' logs
    having event id 4767
    for the last 10 minutes
  
#>


[CmdletBinding()]
Param
(
    [String]
    $User="mike",

    [Int32]
    $EventId=4740,

    [String]
    $LogName = "Security",

    [Int32]
    $Last = 15,

    [String]
    $LogFile=".\Account-Locked.log"
)

$locked = Get-ADUser $User -Properties * | Select-Object LockedOut

If ($locked) 
{

    $Pdc = (Get-ADDomain).PDCEmulator
    
    # $now = Get-Date -Format dd-MMM-yyyy-HH-MM-ss
    # $LogFile=$LogFile + $now.ToString() + ".log"
    
    $before=Get-Date
    $Last = $Last*-1
    $after=$before.AddMinutes($Last)

    Get-EventLog -LogName $LogName -ComputerName $Pdc -after $after -before $before | 
    Where-Object {$_.EventID -eq $EventId} | 
    Select-Object -Property TimeGenerated, ReplacementStrings, Message | 
    Export-Csv -Append -Path $LogFile

}