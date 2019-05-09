[![N|Solid](http://dbamastery.com/wp-content/uploads/2019/01/cropped-DBM-LOGO-2.png)](http://dbamastery.com/)


**Just another witchcraft and wizardry site and DBA tips …**

Welcome to my GitHub repository, here you will find all source code of my previous and future contributions made through my [blog] as:

- MSDB tuning - SQL Script
- MAXDOP calculator - SQL Script
- Wait stats widget for Azure Data Studio (macOS) - JSON \ SQL Script
- PerfMon for DBAs - PowerShell (**New version**)
- Database Integrity Checker - SQL Script (**Under testing**)
- SQL Server docker image creator - Linux (**In development**)
- Orphan data files - PowerShell (**In development**)
- Query Store monitoring - SQL Script (**In development**)
- Availability groups monitoring - Powershell \ SQL Script (**In development**)

## MSDB Tuning
This is a simple T-SQL script that creates a set of missing indexes on MSDB database, which improves the performance of backup\restore purge process.

The execution time for **_sp_delete_backuphistory_** stored procedure dropped in 60% after adding the recommended indexes included in this script. So go ahead and try it and let us know how everything works for you!

## MAXDOP Calculator
This T-SQL script will help you to calculate to correct MAXDOP configuration for your SQL Server instance.

It runs starting from SQL Server 2012, for SQL Server 2016 or major it also returns the MAXDOP value configured at database level.

## Wait stats widget for Azure Data Studio (macOS)
This T-SQL script and JSON files will help you to create a custom widget for Azure Data Studio. Please make sure to check my blog post where I explain in detail how to create this custom widget.

## PerfMon for DBAs
This PowerShell script will help you to create a PerfMon data collector job in any Windows server, this first version only contains the PowerShell for the CPU counters.

## Database Integrity Checker
This T-SQL script files will help you to run a DBCC CHECKDB for one or all databases from a SQL Server instance, it also identifies corruption issues for any iteration.

## SQL Server docker image creator
This shell script will help you to create a SQL Server docker image in the 2017 or 2019 version. It works for Ubuntu and RHEL.

## Orphan data files
This PowerShell script uses DBATools the DBA-GetDatafiles function, it loops through a defined list of servers looking for datafiles sitting on disk not attached to a database.

## Query Store monitoring
This T-SQL script can help you to monitor Query Store without the need of the SSMS built-nt reports, it shows the current storage utilization, queries with multiple execution plans, longest duration queries and more.

## Availability groups monitoring
This T-SQL script and PowerShell script will help you to monitor your AGs without using the SSMS buil-in report.

# Follow me
[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_twitter_circle_color_107170.png)](https://twitter.com/dbamastery) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_github_circle_black_107161.png)](https://github.com/dbamaster) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_linkedin_circle_color_107178.png)](https://www.linkedin.com/in/croblesdba/) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_browser_1055104.png)](http://dbamastery.com/)

## License
[MIT](/LICENSE.md)

[blog]: <http://dbamastery.com/>
