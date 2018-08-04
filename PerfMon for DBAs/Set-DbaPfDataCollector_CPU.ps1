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

function Set-DbaPfDataCollector_CPU
{

<#
    .SYNOPSIS
        Creates a Windows PerfMon data collector set to monitor SQL Server CPU utilization for a local or remote server.
        In order to execute this script as function, you need to "source" it using the following command:
        . ./Set-DbaPfDataCollector_CPU.ps1

        Once the function it's sourced, you can call the function as follows:
        Set-DbaPfDataCollector_CPU

    .DESCRIPTION
        Creates a Windows PerfMon log to monitor SQL Server CPU utilization, the output file created by Perfmon uses the "CSV" format

    .PARAMETER SQLServerName 
        A single SQL Server default or named instance from your SQL Farm, this script can run from a centralized server

    .PARAMETER OutputDirectory
        The path where the PerfMon configuration file and results will be created on the target server 

    .EXAMPLE
        Creating PerfMon for standalone instance
        Set-DbaPfDataCollector_CPU -SQLServerName MyInstance -OutputDirectory "D:\SQLCPU\MyServerName"

    .EXAMPLE 
        Creating PerfMon for named instance
        Set-DbaPfDataCollector_CPU -SQLServerName "ServerName\MyInstance" -OutputDirectory "D:\SQLCPU\MyServerName"

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

    # Creating destination directory in case it doesn't exist
    if (!(Test-Path -path "$OutputDirectory")) {
	    New-Item "$OutputDirectory" -type directory | out-null
    }

    
    if ($SQLCntr -eq 'SQLServer') {

        $DC = "SQLCPU_$ServerName"
    }
    else{

        $DC = "SQLCPU_$Instance"
    }

    # Looking for old instances of this PerfMon data collector
    echo "Checking for old data collectors ..."

    $LogManQuery = Invoke-Expression "logman query -s $ServerName $DC"

    #if ($LogManQuery.Count -eq 3) {
        #echo $LogManQuery "Please check the SQL Server targer server name parameters"
        #break
    #}
    #else{

    $LogManQueryStatus = $LogManQuery | Select-String "Status";

    if (-Not([string]::IsNullOrEmpty($LogManQueryStatus))) {

        echo "And old PerfMon data collector was found in $LogManQueryStatus status..."

        if($LogManQueryStatus -Match "Running"){
            Write-Output "Stopping and removing old data collector"
            Invoke-Expression "logman stop $DC -s $ServerName"
            Invoke-Expression "logman delete $DC -s $ServerName"
        }

        if($LogManQueryStatus -Match "Stopped"){
            Write-Output "Removing old data collector"
            Invoke-Expression "logman delete $DC -s $ServerName"
        }

    $Directory = $OutputDirectory -replace ":","$"
    
    $OldLogManCSV = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".csv"
    $OldLogManConfig = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".config"

    try {
        echo "Cleaning old CSV files..."
        Remove-Item $OldLogManCSV -Force
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        echo "Failed to delete old CSV files on " +$ServerName + " - " + $FailedItem + ":" + $ErrorMessage
        echo "Check your " + $OutputDirectory + "directory"
        #break
        throw
        exit
    }

    try {
        echo "Cleaning old PerfMon config files..."
        Remove-Item $OldLogManConfig -Force
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        echo "Failed to delete old CSV files on " +$ServerName + " - " + $FailedItem + ":" + $ErrorMessage
        echo "Check your " + $ServerName + "name"
        #break
        throw
        exit
    }
    
    # Creating PerfMon configuration file
    $PerfMonCfgFile | out-file "$OutputDirectory\$DC.config" -encoding ASCII

    echo "Creating Perfmon data collector ..."
    $LogManCreation="logman create counter $DC -s $ServerName -f csv -max 100 -si 15 --v -o ""$OutputDirectory\$DC"" -cf ""$OutputDirectory\$DC.config"""
    Invoke-Expression $LogManCreation
    
    $NewLogManQuery = Invoke-Expression "logman query -s $ServerName $DC"

    if ($NewLogManCreation.Count -eq 3) {
        echo $LogManQuery 
        #break
        throw "There was an error when creating the data collector, please check your parameters"
        exit
    }

    else {
        echo "Starting Perfmon data collector ..."
        Invoke-Expression "logman start $DC -s $ServerName"
    }

    echo "Checking status of Perfmon data collector ..."
    Invoke-Expression "logman query $DC -s $ServerName"
    write-host -f green "Script finished, if the PerfMon data collector was configured for the local host PerfMon will pop-up"
        
    # Lauching PerfMon if local host
        if ($ServerName -eq $HostName) {
            perfmon
        }
    }

    else {

    echo "Cleaning old files ..."
    $Directory = $OutputDirectory -replace ":","$"
    
    $OldLogManCSV = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".csv"
    $OldLogManConfig = "\\" + $ServerName +"\"+ $Directory +"\"+ $DC + ".config"

    #Remove-Item $OldLogManCSV -Force
    #Remove-Item $OldLogManConfig -Force

    try {
        echo "Cleaning old CSV files..."
        Remove-Item $OldLogManCSV -Force
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        echo "Failed to delete old CSV files on " +$ServerName + " - " + $FailedItem + ":" + $ErrorMessage
        echo "Check your " + $OutputDirectory + "directory"
        #break
        throw
        exit
    }

    try {
        echo "Cleaning old PerfMon config files..."
        Remove-Item $OldLogManConfig -Force
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        echo "Failed to delete old CSV files on " +$ServerName + " - " + $FailedItem + ":" + $ErrorMessage
        echo "Check your " + $ServerName + "name"
        #break
        throw
        exit
    }

    # Creating PerfMon configuration file
    $PerfMonCfgFile | out-file "$OutputDirectory\$DC.config" -encoding ASCII

    echo "Creating Perfmon data collector ..."
    $LogManCreation="logman create counter $DC -s $ServerName -f csv -max 100 -si 15 --v -o ""$OutputDirectory\$DC"" -cf ""$OutputDirectory\$DC.config"""
    Invoke-Expression $LogManCreation
    
    $NewLogManQuery = Invoke-Expression "logman query -s $ServerName $DC"

    if ($NewLogManCreation.Count -eq 3) {
        echo $LogManQuery 
        #break
        throw "There was an error when creating the data collector, please check your parameters"
        exit
    }

    else {
        echo "Starting Perfmon data collector ..."
        Invoke-Expression "logman start $DC -s $ServerName"
    }

    echo "Checking status of Perfmon data collector ..."
    Invoke-Expression "logman query $DC -s $ServerName"

    write-host -f green "Script finished, if the PerfMon data collector was configured for the local host PerfMon will pop-up"
        
    # Lauching PerfMon if local host
        if ($ServerName -eq $HostName) {
            perfmon
        }
    }
    
}      
else {
    write-host -f red "The host: $ServerName is unreachable, please check your parameters."
}
} #end function Set-DbaPfDataCollector_CPU