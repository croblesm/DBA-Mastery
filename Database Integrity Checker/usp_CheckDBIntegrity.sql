/*
-- +------------------------------------------------------------------------------------+
-- |                  					DBA Mastery                                		|
-- |                        		dbamastery@gmail.com                         		|
-- |                      		  http://www.dbamastery.com								|
-- |------------------------------------------------------------------------------------|
-- |                                                                            		|
-- |------------------------------------------------------------------------------------|
-- | DATABASE	: SQL Server                                                      		|
-- | FILE     	: usp_CheckDBIntegrity.sql												|
-- | CLASS    	: Database Maintenance													|
-- | PURPOSE  	: Performs a database integrity check for one or all databases			|
-- | INPUT		:																		|
-- |                                                                            		|
-- | @DBName		Optional parameter, in case you want to run this process for a		|
-- | 				single or a list of databases. In case no value is passed, it will	|
-- | 				it will run for all databases in the SQL Server instance.			|
-- |                                                                            		|
-- | @PhysicalOnly	If a PHYSICAL_ONLY check is required, set this parameter to "1"		|
-- |				If no parameter is passed, it will run a standard DBCC CHECKDB.		|
-- |                                                                            		|
-- |@PrintOnly		Optional parameter, set this parameter to "1" in case you want to	|
-- |				see the output of the parameter combination you have chosen.		|
-- |				This parameter only shows the information, it does not execute it.	|
-- |																					|
-- | NOTE		: 	As with any code, ensure to test this script in a development		|
-- |            	environment before attempting to run it in production.				|
-- |																					|
-- |            	This stored procedure uses a table called CheckDBIntegrity_History	|
-- |            	and runs for any SQL Server version major than 2016.				|
-- |																					|
-- +------------------------------------------------------------------------------------+
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

CREATE PROCEDURE [dbo].[usp_CheckDBIntegrity]

	@DBName VARCHAR(1024) = NULL
	,@PhysicalOnly BIT = 1
	,@PrintOnly BIT = 0

AS

-- Declaring SQL statement variable
DECLARE @SQLStm VARCHAR(MAX)

-- If no parameter is passed, it will run against all databases
IF @DBName IS NULL 

	BEGIN

		DECLARE database_cursor CURSOR
		FOR
		SELECT NAME
		FROM master..sysdatabases
		WHERE 
			-- Excluding offline mode databases
			(STATUS & 512) <> 512
			-- Excluding read only mode databases
			AND (STATUS & 1024) <> 1024 
			-- Excluding suspect mode databases
			AND (STATUS & 256) <> 256
			-- Excluding system and sample databases
			AND NAME NOT IN ('master','model','msdb','tempdb','AdventureWorks2016','AdventureWorksDW2016','AdventureWorks2012','WideWorldImporters') 
		ORDER BY NAME ASC

		OPEN database_cursor

		FETCH NEXT FROM database_cursor INTO @DBName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @PhysicalOnly = 0
			BEGIN
				IF @PrintOnly = 0
				BEGIN
					INSERT INTO CheckDBIntegrity_History 
					([Error], [Level], [State], [MessageText], [RepairLevel], 
					[Status], [DbId], [DbFragId], [ObjectID], [IndexId], [PartitionId], 
					[AllocUnitId], [RidDbId], [RidPruId], [File], [Page], [Slot], [RefDbID], 
					[RefPruId], [RefFile], [RefPage], [RefSlot], [Allocation]) 
					EXEC ('DBCC CHECKDB(''' + @DBName + ''') WITH TABLERESULTS')
				END
				ELSE
				BEGIN
					SET @SQLStm = 'DBCC CHECKDB(''' + @DBName + ''') WITH TABLERESULTS'
					-- Printing output
					PRINT @SQLStm
				END			
			END
			ELSE IF @PrintOnly = 0
			BEGIN
					INSERT INTO CheckDBIntegrity_History 
					([Error], [Level], [State], [MessageText], [RepairLevel], 
					[Status], [DbId], [DbFragId], [ObjectID], [IndexId], [PartitionId], 
					[AllocUnitId], [RidDbId], [RidPruId], [File], [Page], [Slot], [RefDbID], 
					[RefPruId], [RefFile], [RefPage], [RefSlot], [Allocation]) 
				EXEC ('DBCC CHECKDB(''' + @DBName + ''') WITH PHYSICAL_ONLY, TABLERESULTS')
			END
			ELSE
			BEGIN
				SET @SQLStm = 'DBCC CHECKDB(''' + @DBName + ''') WITH PHYSICAL_ONLY, TABLERESULTS'
				-- Printing output
				PRINT @SQLStm
			END

			FETCH NEXT FROM database_cursor	INTO @DBName
		END
		CLOSE database_cursor
		DEALLOCATE database_cursor
	END
	ELSE

	-- If @DBName parameter has a value, run against a single or a list of databases
	BEGIN

		DECLARE database_cursor CURSOR
		FOR
		SELECT NAME
		FROM master..sysdatabases
		WHERE
			-- Excluding offline mode databases
			(STATUS & 512) <> 512
			-- Excluding read only mode databases
			AND (STATUS & 1024) <> 1024 
			-- Excluding suspect mode databases
			AND (STATUS & 256) <> 256
			-- Including database or list of databases
			AND NAME in (SELECT value from  STRING_SPLIT(@DBName, ','))
		ORDER BY NAME ASC

		OPEN database_cursor

		FETCH NEXT FROM database_cursor INTO @DBName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @PhysicalOnly = 0
			BEGIN
				IF @PrintOnly = 0
				BEGIN
					INSERT INTO CheckDBIntegrity_History 
					([Error], [Level], [State], [MessageText], [RepairLevel], 
					[Status], [DbId], [DbFragId], [ObjectID], [IndexId], [PartitionId], 
					[AllocUnitId], [RidDbId], [RidPruId], [File], [Page], [Slot], [RefDbID], 
					[RefPruId], [RefFile], [RefPage], [RefSlot], [Allocation]) 
					EXEC ('DBCC CHECKDB(''' + @DBName + ''') WITH TABLERESULTS')
				END
				ELSE
				BEGIN
					SET @SQLStm = 'DBCC CHECKDB(''' + @DBName + ''') WITH TABLERESULTS'
					PRINT @SQLStm
				END			
			END
			ELSE IF @PrintOnly = 0
			BEGIN
					INSERT INTO CheckDBIntegrity_History 
					([Error], [Level], [State], [MessageText], [RepairLevel], 
					[Status], [DbId], [DbFragId], [ObjectID], [IndexId], [PartitionId], 
					[AllocUnitId], [RidDbId], [RidPruId], [File], [Page], [Slot], [RefDbID], 
					[RefPruId], [RefFile], [RefPage], [RefSlot], [Allocation]) 
				EXEC ('DBCC CHECKDB(''' + @DBName + ''') WITH PHYSICAL_ONLY, TABLERESULTS')
			END
			ELSE
			BEGIN
				SET @SQLStm = 'DBCC CHECKDB(''' + @DBName + ''') WITH PHYSICAL_ONLY, TABLERESULTS'
				PRINT @SQLStm
			END

			FETCH NEXT FROM database_cursor	INTO @DBName
		END
		CLOSE database_cursor
		DEALLOCATE database_cursor
	END
GO