USE TrackerPal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_DBA_TableSpaceUsed]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].spTPal_DBA_TableSpaceUsed
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_DBA_TableSpaceUsed.sql
 * Created On: 07/28/2011         
 * Created By: R.Cole  
 * Task #:     
 * Purpose:    Return the size of each table in the database               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE spTPal_DBA_TableSpaceUsed
AS

-- // Create the temporary table // --
CREATE TABLE #tblResults (
   [name] NVARCHAR(50),
   [rows] INT,
   [reserved] VARCHAR(18),
   [reserved_int] INT DEFAULT(0),
   [data] VARCHAR(18),
   [data_int] INT DEFAULT(0),
   [index_size] VARCHAR(18),
   [index_size_int] INT DEFAULT(0),
   [unused] VARCHAR(18),
   [unused_int] INT DEFAULT(0)
)

--  // Populate the temp table via an undocumented system sproc // --
EXEC sp_MSforeachtable @command1= "INSERT INTO #tblResults ([name],[rows],[reserved],[data],[index_size],[unused]) EXEC sp_spaceused '?'"
   
-- // Strip out the " KB" portion from the fields // --
UPDATE #tblResults 
  SET [reserved_int] = CAST(SUBSTRING([reserved], 1, CHARINDEX(' ', [reserved])) AS INT),
      [data_int] = CAST(SUBSTRING([data], 1, CHARINDEX(' ', [data])) AS INT),
      [index_size_int] = CAST(SUBSTRING([index_size], 1, CHARINDEX(' ', [index_size])) AS INT),
      [unused_int] = CAST(SUBSTRING([unused], 1, CHARINDEX(' ', [unused])) AS INT)
   
-- // Return the results // --
SELECT * FROM #tblResults ORDER BY [name]
GO

GRANT EXECUTE ON [dbo].spTPal_DBA_TableSpaceUsed TO db_dml;
GO