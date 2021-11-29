$ErrorActionPreference = "Stop"
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

function Set-PerfMonDBA_IO
{

<#
    .SYNOPSIS
        Creates a Windows PerfMon data collector set to monitor SQL Server CPU utilization for a local or remote server.
        In order to execute this script as function, you need to "source" it using the following command:
        . ./PerfMonDBA_IO.ps1

        Once the function it's sourced, you can call the function as follows:
        Set-PerfMonDBA_IO

    .DESCRIPTION
        Creates a Windows PerfMon log to monitor SQL Server disk utilization, the output file created by Perfmon uses the "CSV" format

    .PARAMETER SQLServerName 
        A single SQL Server default or named instance from your SQL Farm, this script can run from a centralized server

    .PARAMETER OutputDirectory
        The path where the PerfMon configuration file and results will be created on the target server 

    .EXAMPLE
        Creating PerfMon for standalone instance
        Set-PerfMonDBA_IO -SQLServerName MyInstance -OutputDirectory "D:\SQLCPU\MyServerName"

    .EXAMPLE 
        Creating PerfMon for named instance
        Set-PerfMonDBA_IO -SQLServerName "ServerName\MyInstance" -OutputDirectory "D:\SQLCPU\MyServerName"

    .NOTES
        Version:        1.0
        Author:         Carlos Robles
        Creation Date:  2018
        Purpose/Change: N/A

        For questions or comments please contact me at:

        Email:			dbamastery@gmail.com
        Website:		http://www.dbamastery.com
        Twitter:		@dbamastery
    .LINK
        https://github.com/dbamaster/dbamastery/tree/master/PerfMonDataCollector
#>

    [cmdletbinding()]

    Param(

        [Parameter (Mandatory=$true)]
        [string]$SQLServerName,
        [string]$OutputDirectory

    ) #end param

# Declaring variables
$Instance = $SQLServerName.Split("\")
$HostName = [System.Environment]::MachineName

if ($Instance.Count -eq 1) {
	    $SQLCntr = 'SQLServer'
        $ServerName = $SQLServerName
	}
	
else {
	    $SQLCntr = 'MSSQL$' + $Instance[1]
	    $ServerName = $Instance[0]
	}

# Testing connectivity 
if (Test-Connection $ServerName -count 1 -quiet) {

# Defining PerfMon counters for CPU
$PerfMonCfgFile = @"
\PhysicalDisk(*)\Disk Reads/sec
\PhysicalDisk(*)\Disk Writes/sec
\PhysicalDisk(*)\Disk Read Bytes/sec
\PhysicalDisk(*)\Disk Write Bytes/sec
\PhysicalDisk(*)\Current Disk Queue Length
\PhysicalDisk(*)\Avg. Disk Read Queue Length
\PhysicalDisk(*)\Avg. Disk Write Queue Length
\PhysicalDisk(*)\Avg. Disk sec/Read
\PhysicalDisk(*)\Avg. Disk sec/Write
"@

    # Creating destination directory in case it doesn't exist
    if (!(Test-Path -path "$OutputDirectory")) {
	    New-Item "$OutputDirectory" -type directory | out-null
    }
    
    if ($SQLCntr -eq 'SQLServer') {

        $DC = "SQLIO_$ServerName"
    }
    else{

        $DC = "SQLIO_$Instance"
    }

    # Looking for old instances of this PerfMon data collector
    echo "Checking for old data collectors ..."

    $LogManQuery = Invoke-Expression "logman query -s $ServerName $DC" | out-null

    #if ($LogManQuery.Count -eq 3) {
        #echo $LogManQuery "Please check the SQL Server targer server name parameters"
        #break
    #}
    #else{

    $LogManQueryStatus = $LogManQuery | Select-String "Status";

    if (-Not([string]::IsNullOrEmpty($LogManQueryStatus))) {

        if($LogManQueryStatus -Match "Running"){
            echo "An old PerfMon data collector was found in 'Running' status..."
            Write-Output "Stopping and removing old data collector"
            Invoke-Expression "logman stop $DC -s $ServerName" | out-null
            Invoke-Expression "logman delete $DC -s $ServerName" | out-null
        }

        if($LogManQueryStatus -Match "Stopped"){
            echo "An old PerfMon data collector was found in 'Stopped' status..."
            Write-Output "Removing old data collector"
            Invoke-Expression "logman delete $DC -s $ServerName" | out-null
        }

    if ($ServerName -eq $HostName) {
        $OldLogManCSV = $OutputDirectory +"\"+ $DC + ".csv"
        $OldLogManConfig = $OutputDirectory +"\"+ $DC + ".config"
    }
    else {
        $Directory = $OutputDirectory -replace ":","$"
    
        $OldLogManCSV = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".csv"
        $OldLogManConfig = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".config"
    }

        echo "Cleaning old CSV files..."
        Remove-Item $OldLogManCSV -Force -ErrorAction Continue -WarningAction Continue

        echo "Cleaning old PerfMon config files..."
        Remove-Item $OldLogManConfig -Force -ErrorAction Continue -WarningAction Continue
    
    # Creating PerfMon configuration file
    $PerfMonCfgFile | out-file "$OutputDirectory\$DC.config" -encoding ASCII

    echo "Creating Perfmon data collector ..."
    $LogManCreation="logman create counter $DC -s $ServerName -f csv -max 100 -si 15 --v -o ""$OutputDirectory\$DC"" -cf ""$OutputDirectory\$DC.config"""
    Invoke-Expression $LogManCreation | out-null
    
    $NewLogManQuery = Invoke-Expression "logman query -s $ServerName $DC" | out-null

    if ($NewLogManCreation.Count -eq 3) {
        echo $LogManQuery 
        #break
        throw "There was an error when creating the data collector, check your parameters"
        exit
    }

    else {
        echo "Starting Perfmon data collector ..."
        Invoke-Expression "logman start $DC -s $ServerName" | out-null
    }

    echo "Checking status of Perfmon data collector ..."
    Invoke-Expression "logman query $DC -s $ServerName" | out-null
    write-host -f green "Script finished, if the PerfMon data collector was configured for the local host PerfMon will pop-up"
        
    # Lauching PerfMon if local host
        if ($ServerName -eq $HostName) {
            perfmon
        }
    }

    else {

    echo "Cleaning old files ..."

    if ($ServerName -eq $HostName) {
        $OldLogManCSV = $OutputDirectory +"\"+ $DC + ".csv"
        $OldLogManConfig = $OutputDirectory +"\"+ $DC + ".config"
    }
    else {
        $Directory = $OutputDirectory -replace ":","$"
    
        $OldLogManCSV = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".csv"
        $OldLogManConfig = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".config"
    }

    #Remove-Item $OldLogManCSV -Force
    #Remove-Item $OldLogManConfig -Force

        echo "Cleaning old CSV files..."
        Remove-Item $OldLogManCSV -Force -ErrorAction Continue -WarningAction Continue

        echo "Cleaning old PerfMon config files..."
        Remove-Item $OldLogManConfig -Force -ErrorAction Continue -WarningAction Continue

    # Creating PerfMon configuration file
    $PerfMonCfgFile | out-file "$OutputDirectory\$DC.config" -encoding ASCII

    echo "Creating Perfmon data collector ..."
    $LogManCreation="logman create counter $DC -s $ServerName -f csv -max 100 -si 15 --v -o ""$OutputDirectory\$DC"" -cf ""$OutputDirectory\$DC.config"""
    Invoke-Expression $LogManCreation | out-null
    
    $NewLogManQuery = Invoke-Expression "logman query -s $ServerName $DC" | out-null

    if ($NewLogManCreation.Count -eq 3) {
        echo $LogManQuery 
        #break
        throw "There was an error when creating the data collector, check your parameters"
        exit
    }

    else {
        echo "Starting Perfmon data collector ..."
        Invoke-Expression "logman start $DC -s $ServerName" | out-null
    }

    echo "Checking status of Perfmon data collector ..."
    Invoke-Expression "logman query $DC -s $ServerName" | out-null
    write-host -f green "Script finished, if the PerfMon data collector was configured for the local host PerfMon will pop-up"
        
    # Lauching PerfMon if local host
        if ($ServerName -eq $HostName) {
            perfmon
        }
    }
    
}      
else {
    write-host -f red "The host: $ServerName is unreachable, check the server name parameter."
}
} #end function Set-PerfMonDBA_IO
