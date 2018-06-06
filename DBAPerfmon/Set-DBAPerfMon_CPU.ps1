<#
Copyright (c) 2018 DBA Mastery

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

function Set-DBAPerfMon_CPU
{

<#
.SYNOPSIS
Creates a Windows PerfMon log to monitor SQL Server CPU utilization

.DESCRIPTION
Creates a Windows PerfMon log to monitor SQL Server CPU utilization

.PARAMETER Mandatory 
A single SQL Server default or named instance from your SQL Farm

.PARAMETER OutputDirectory
The path where the PerfMon configuration file and results will be created 

.EXAMPLE
Creating PerfMon for standalone instance
Set-PerfMonCPU -SQLServerName MyInstance -OutputDirectory "D:\SQLCPU\MyServerName\"

.EXAMPLE 
Creating PerfMon for named instance
Set-PerfMonCPU -SQLServerName "ServerName\MyInstance" -OutputDirectory "D:\SQLCPU\MyServerName\"

.NOTES
You need to run this function as a member of the Domain Admins group; doing so is the only way to ensure you have permission to query WMI from the remote computers.
#>
    [cmdletbinding()]
    Param(

        [Parameter (Mandatory=$true)]
        [string]$SQLServerName,
        [string]$OutputDirectory
    ) #end param

# Determining if it's a default or named instance
$Instance = $SQLServerName.Split("\")

if ($Instance.Count -eq 1) {
	    $SQLCntr = 'SQLServer'
	    $ServerName = $SQLServerName
	}
else {
	    $SQLCntr = 'MSSQL$' + $Instance[1]
	    $ServerName = $Instance[0]
	}

# Creating destination directory in case it doesn't exist
if (!(Test-Path -path "$OutputDirectory")) {
	New-Item "$OutputDirectory" -type directory | out-null
}

echo "Removing old Perfmon config files in case exists ..."
Remove-Item "$OutputDirectory\SQLCPU_$SQLCntr*.config"

# Defining PerfMon counters for SQL Server CPU
$PerfMonCfgFile = @"
\Process(_Total)\% Privileged Time
\Process(sqlservr)\% Privileged Time
\Process(_Total)\% Processor Time
\Process(sqlservr)\% Processor Time
\Process(_Total)\Working Set
\Process(sqlservr)\Working Set
\Process(_Total)\Working Set Peak
\Process(sqlservr)\Working Set Peak
\System\Processor Queue Length
\System\Context Switches/sec
\$($SQLCntr):SQL Statistics\SQL Compilations/sec
\$($SQLCntr):SQL Statistics\SQL Re-Compilations/sec
\$($SQLCntr):SQL Statistics\Batch Requests/sec
\$($SQLCntr):Buffer Manager\Page life expectancy
\$($SQLCntr):Buffer Manager\Lazy writes/sec
\$($SQLCntr):Buffer Manager\Checkpoints/sec
\$($SQLCntr):Plan Cache\Cache Hit Ratio: SQL Plans
\$($SQLCntr):Buffer Manager\Buffer Cache Hit Ratio
"@

# Creating PerfMon configuration file
$PerfMonCfgFile | out-file "$OutputDirectory\SQLCPU_$SQLCntr.config" -encoding ASCII

echo "Stopping Perfmon in case exists ..."
logman stop SQLCPU_$SQLCntr -s $ServerName

echo "Deleting Perfmon in case exists ..."
logman delete SQLCPU_$SQLCntr -s $ServerName

echo "Removing old Perfmon log files in case exists ..."
Remove-Item "$OutputDirectory\SQLCPU_$SQLCntr*.csv"

echo "Creating Perfmon ..."
logman create counter SQLCPU_$SQLCntr -s $ServerName -f csv -max 100 -si 15 --v -o ""$OutputDirectory\SQLCPU_$SQLCntr"" -cf ""$OutputDirectory\SQLCPU_$SQLCntr.config""

echo "Starting Perfmon ..."
logman start SQLCPU_$SQLCntr -s $ServerName

write-host -f green "Script finished"
perfmon
} #end function DBAPerfMon_CPU