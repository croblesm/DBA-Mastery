[![N|Solid](http://dbamastery.com/wp-content/uploads/2019/01/cropped-DBM-LOGO-2.png)](http://dbamastery.com/)

**Just another witchcraft and wizardry site and DBA tips …**

Welcome to my GitHub repository, here you will find all source code of my previous and future contributions made through my [blog] as:

- [MAXDOP calculator - SQL Script](#maxdop-calculator)
- [MSDB tuning - SQL Script](#msdb-tuning)
- [Wait stats widget for Azure Data Studio - JSON \ SQL Script](#wait-stats-widget-for-Azure-Data-Studio)
- [PerfMon for DBAs - PowerShell (**New version**)](#perfMon-for-dbas)
- [Database Integrity Checker - SQL Script (**Under testing**)](#database-integrity-checker)
- [Orphan data files - PowerShell (**In development**)](#orphan-data-files)

## [MAXDOP Calculator](./MAXDOP%20Calculator)
This T-SQL script will help you to calculate to correct MAXDOP configuration for your SQL Server instance.

It runs starting from SQL Server 2012, for SQL Server 2016 or major it also returns the MAXDOP value configured at database level.

## [Azure Data Studio Notebooks](./ADS%20Notebooks)
A collection of Azure Data Studio Notebooks created as POC (proof of concept), to explore the capabilities of this new cool feature. You will find examples for the following scenarios:

* Creating a simple SQL container with Python
* Upgrading a SQL container to the latest CU with Python
* Troubleshooting guide with sp_WhoIsActive

## [MSDB Tuning](./MSDB%20Tuning)
This is a simple T-SQL script that creates a set of missing indexes on MSDB database, which improves the performance of backup\restore purge process.

The execution time for **_sp_delete_backuphistory_** stored procedure dropped in 60% after adding the recommended indexes included in this script. So go ahead and try it and let us know how everything works for you!

## [Wait stats widget for Azure Data Studio](./WaitStats%20widget)
This T-SQL script and JSON files will help you to create a custom widget for Azure Data Studio. Please make sure to check my blog post where I explain in detail how to create this custom widget.

## [PerfMon for DBAs](./PerfMon%20for%20DBAs)
This PowerShell script will help you to create a PerfMon data collector job in any Windows server, this first version only contains the PowerShell for the CPU counters.

## [Database Integrity Checker](./Database%20Integrity%20Checker)
This T-SQL script files will help you to run a DBCC CHECKDB for one or all databases from a SQL Server instance, it also identifies corruption issues for any iteration.

## [Orphan data files](./Orphan%20data%20files)
This PowerShell script uses DBATools the DBA-GetDatafiles function, it loops through a defined list of servers looking for datafiles sitting on disk not attached to a database.

## Questions?
If you have questions or comments about this demo, don't hesitate to contact me at <crobles@dbamastery.com>

# Follow me
[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_twitter_circle_color_107170.png)](https://twitter.com/dbamastery) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_github_circle_black_107161.png)](https://github.com/dbamaster) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_linkedin_circle_color_107178.png)](https://www.linkedin.com/in/croblesdba/) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_browser_1055104.png)](http://dbamastery.com/)

## License
[MIT](/LICENSE.md)

[blog]: <http://dbamastery.com/>
