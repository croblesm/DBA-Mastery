## MSDB Tuning

This is a simple T-SQL script that creates a set of missing indexes on MSDB database, which improves the performance of backup\restore purge process.

The execution time for sp_delete_backuphistory stored procedure dropped in 60% after adding the recommended indexes included in this script. So go ahead and try it and let us know how everything works for you!

For more information, please take a look at this [post](http://dbamastery.com/scripts/msdbtuning-purgehistory/) from my blog.

## Questions?
If you have questions or comments about this demo, don't hesitate to contact me at <crobles@dbamastery.com>

## Follow me
[![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_twitter_circle_color_107170.png)](https://twitter.com/dbamastery) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_github_circle_black_107161.png)](https://github.com/dbamaster) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_linkedin_circle_color_107178.png)](https://www.linkedin.com/in/croblesdba/) [![N|Solid](http://dbamastery.com/wp-content/uploads/2018/08/if_browser_1055104.png)](http://dbamastery.com/)
