# DBA Mastery

[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/database-2.png)](http://dbamastery.com/)
Just another witchcraft and wizardry site and DBA tips …

Welcome to my GitHub repository, here you will find all source code of my previous and future contributions made through my [blog] as:

- MSDB tuning - SQL Script
- MAXDOP calculator - SQL Script
- Wait stats widget for Azure Data Studio (macOS)
- Database Integrity Checker (**Under testing**)
- PerfMon for DBAs - PowerShell (**Under testing**)
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

So go ahead and try it and let us know how everything works for you!

# Follow me
[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_twitter_circle_color_107170.png)](https://twitter.com/dbamastery) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_github_circle_black_107161.png)](https://github.com/dbamaster) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_linkedin_circle_color_107178.png)](https://www.linkedin.com/in/croblesdba/) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_browser_1055104.png)](http://dbamastery.com/)

## License
[MIT](/LICENSE.md)

[blog]: <http://dbamastery.com/>
