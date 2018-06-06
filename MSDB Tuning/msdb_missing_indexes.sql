/*
-- +----------------------------------------------------------------------------+
-- |                  			DBA Mastery		                                |
-- |                        dbamastery@gmail.com                                |
-- |                      http://www.dbamastery.com                             |
-- |----------------------------------------------------------------------------|
-- |                                                                            |
-- |----------------------------------------------------------------------------|
-- | DATABASE : SQL Server                                                      |
-- | FILE     : msdb_missing_indexes.sql                                        |
-- | CLASS    : Performance tuning                                              |
-- | PURPOSE  : Creates a set of missing indexes for MSDB database              |
-- |																			|
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

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
*/

-- switching to MSDB database
USE MSDB
GO

-- backupset table
CREATE NONCLUSTERED INDEX IX_backupset_media_set_id ON backupset (media_set_id);
CREATE NONCLUSTERED INDEX IX_backupset_backup_finish_date_media_set_id ON backupset (backup_finish_date) INCLUDE (media_set_id);
CREATE NONCLUSTERED INDEX IX_backupset_backup_start_date ON backupset (backup_start_date);

-- backupfile table
CREATE NONCLUSTERED INDEX IX_backupfile_backup_set_id ON backupfile (backup_set_id);

-- backupfilegroup table
CREATE NONCLUSTERED INDEX IX_backupfilegroup_backup_set_id ON backupfilegroup (backup_set_id);

-- restorefile table
CREATE CLUSTERED INDEX IX_restorefile_restore_history_id ON restorefile (restore_history_id);

-- restorefilegroup table
CREATE CLUSTERED INDEX IX_restorefilegroup_restore_history_id ON restorefilegroup (restore_history_id);

-- backupmediafamily table
CREATE NONCLUSTERED INDEX IX_backupmediafamily_media_set_id ON backupmediafamily (media_set_id);