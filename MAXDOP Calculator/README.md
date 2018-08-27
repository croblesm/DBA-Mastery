## MAXDOP Calculator
This T-SQL script will help you to calculate to correct MAXDOP configuration for your SQL Server instance.
It runs for any SQL Server instance, starting from the 2012 version.

Here is an example of the output message from a SQL Server instance running on the 2016 version or major:
~~~~
------------------------------------------------------------------------
MAXDOP at Database level:
------------------------------------------------------------------------
DatabaseName                   ConfigurationName MAXDOP Configured Value
------------------------------ ----------------- -----------------------
MyDB_01                        MAXDOP            0
MyDB_02                        MAXDOP            0
MyDB_03                        MAXDOP            0
 
--------------------------------------------------------------
MAXDOP at Instance level:
--------------------------------------------------------------
MAXDOP configured value: 	8                             
MAXDOP recommended value: 	8                             
--------------------------------------------------------------
~~~~
The output also returns the MAXDOP configuration at **database level**, this information is retrieved from the **_sys.database_scoped_configurations_** DMV.

Here is an example of the output message from a SQL Server instance running on a version prior to SQL Server 2016 version:
~~~~
--------------------------------------------------------------
MAXDOP at Instance level:
--------------------------------------------------------------
MAXDOP configured value: 	0                             
MAXDOP recommended value: 	4                             
--------------------------------------------------------------
 
In case you want to change MAXDOP to the recommeded value, please use this script:
 
EXEC sp_configure 'max degree of parallelism',4                             
GO
RECONFIGURE WITH OVERRIDE;
~~~~

The output message returns the current and recommended MAXDOP configuration, also the syntax to change it in case it is wrong.

**_Please don't hesitate to leave your feedback, thanks!_**

# Follow me
[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_twitter_circle_color_107170.png)](https://twitter.com/dbamastery) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_github_circle_black_107161.png)](https://github.com/dbamaster) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_linkedin_circle_color_107178.png)](https://www.linkedin.com/in/croblesdba/) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_browser_1055104.png)](http://dbamastery.com/)

## License
[MIT](/LICENSE.md)

[blog]: <http://dbamastery.com/>
