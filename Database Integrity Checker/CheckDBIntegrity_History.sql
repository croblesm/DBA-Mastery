/*
-- +------------------------------------------------------------------------------------+
-- |                  					DBA Mastery                                		|
-- |                        		dbamastery@outlook.com                         		|
-- |                      		  http://www.dbamastery.com								|
-- |------------------------------------------------------------------------------------|
-- |                                                                            		|
-- |------------------------------------------------------------------------------------|
-- | DATABASE	: SQL Server                                                      		|
-- | FILE     	: CheckDBIntegrity_History.sql											|
-- | CLASS    	: Database Maintenance													|
-- | PURPOSE  	: This table is used by usp_CheckDBIntegrity stored procedure.			|
-- |                                                                            		|
-- | NOTE		: 	As with any code, ensure to test this script in a development		|
-- |            	environment before attempting to run it in production.				|
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

CREATE TABLE [dbo].[CheckDBIntegrity_History](
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [int] NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[DbFragId] [int] NULL,
	[ObjectID] [int] NULL,
	[IndexId] [int] NULL,
	[PartitionId] [int] NULL,
	[AllocUnitId] [int] NULL,
	[RidDbId] [int] NULL,
	[RidPruId] [int] NULL,
	[File] [int] NULL,
	[Page] [int] NULL,
	[Slot] [int] NULL,
	[RefDbID] [int] NULL,
	[RefPruId] [int] NULL,
	[RefFile] [int] NULL,
	[RefPage] [int] NULL,
	[RefSlot] [int] NULL,
	[Allocation] [int] NULL
) ON [PRIMARY]
GO

