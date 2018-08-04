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

function Get-SQLFarm_OrphanDataFiles
{
<#
.SYNOPSIS
Retrieves information about orphan database files left behind in file systems.

.DESCRIPTION
The Get-SQLFarm_OrphanDataFiles function uses DBATools "DbaOrphanedFile" function, but it analyzes a list of SQL Server instances in a farm storing the results into a table
in a central repository (database)

About "Find-DbaOrphanedFile" function:
Searches all directories associated with SQL database files for database files that are not currently in use by the SQL Server instance.
https://dbatools.io/functions/find-dbaorphanedfile/

.PARAMETER CentralSQL 
A single computer name or an array of computer names. You may also provide IP addresses.

.PARAMETER CentralDB
The name of the Central repository database where you want to save the results

.PARAMETER InventoryTable
The name of the table where you have the list of SQL Server instances.

.PARAMETER ResultsTable
The name of the table from the central repository database where you want to save the results.

.PARAMETER CleanupOldScan
In case you want to delete results from previous scans.

.EXAMPLE
Read computer names from Active Directory and retrieve their inventory information.
Get-OrphanFiles -CentralSQL PITDBAP01 -CentralDB CDBM -InventoryTable "CDBM.dbo.DCP_MSL" -ResultsTable "CDBM.SQL.OrphanDataFiles" -CleanupOldScan 1

.EXAMPLE 
Read computer names from a file (one name per line) and retrieve their inventory information
Get-OrphanFiles -CentralSQL PITDBAP01 -CentralDB CDBM -InventoryTable "CDBM.dbo.DCP_MSL" -ResultsTable "CDBM.SQL.OrphanDataFiles" -CleanupOldScan 0

.NOTES
You need to run this function as a member of the Domain Admins group; doing so is the only way to ensure you have permission to query WMI from the remote computers.
#>

    [cmdletbinding()]

    Param (

            [Parameter (Mandatory=$true)]
            [String] $CentralSQL,
            [String] $CentralDB,
            [String] $InventoryTable,
            [String] $ResultsTable,
            [int] $CleanupOldScan

    ) #end param

Begin 
    {

    if ($CleanupOldScan -eq 1) {

        $SQLFarm = @(Invoke-Sqlcmd -ServerInstance $CentralSQL -Database $CentralDB -Query "SELECT InstanceName FROM $InventoryTable WHERE StatusId = 1;") | select-object -expand InstanceName

        # Cleaning up target table
        Invoke-Sqlcmd -ServerInstance $CentralSQL -Database $CentralDB -Query "TRUNCATE TABLE $ResultsTable"

        # Scanning list of servers
        foreach ($SQL in $SQLFarm)
        {
	        Find-DbaOrphanedFile -SqlServer $SQL | Out-DbaDataTable | Write-DbaDataTable -SqlServer $CentralSQL -Table $ResultsTable
        }		

        # Listing information
        Invoke-Sqlcmd -ServerInstance $CentralSQL -Database $CentralDB -Query "SELECT SQLInstance, RemoteFileName FROM $ResultsTable" | FT

    }

    else {

        $SQLFarm = @(Invoke-Sqlcmd -ServerInstance $CentralSQL -Database $CentralDB -Query "SELECT InstanceName FROM $InventoryTable WHERE StatusId = 1;") | select-object -expand InstanceName

        # Scanning list of servers
        foreach ($SQL in $SQLFarm)
        {
	        Find-DbaOrphanedFile -SqlServer $SQL | Out-DbaDataTable | Write-DbaDataTable -SqlServer $CentralSQL -Table $ResultsTable -AutoCreateTable
        }		

        # Listing information
        Invoke-Sqlcmd -ServerInstance $CentralSQL -Database $CentralDB -Query "SELECT SQLInstance, RemoteFileName FROM $ResultsTable" | FT

        }
    }

} #end function Get-SQLFarm_OrphanDataFiles