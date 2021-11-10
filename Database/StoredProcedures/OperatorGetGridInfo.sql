USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OperatorGetGridInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OperatorGetGridInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   OperatorGetGridInfo.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Populate SA Users Datagrid            
 *
 * Modified By: R.Cole - 02/10/2012
 * ******************************************************** */
CREATE PROCEDURE [dbo].[OperatorGetGridInfo] 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT Operator.OperatorID, 
       Operator.FirstName, 
       Operator.LastName, 
       r.[Role]
FROM Operator 
  LEFT OUTER JOIN [User] u ON Operator.UserID = u.UserID
	LEFT OUTER JOIN User_Role ur ON u.UserID = ur.UserID
	LEFT OUTER JOIN [Role] r ON ur.RoleID = r.RoleID
WHERE Operator.Deleted = 0
  AND u.Deleted = 0
ORDER BY r.[Role], 
         Operator.LastName, 
         Operator.FirstName
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT VIEW DEFINITION ON [OperatorGetGridInfo] TO [db_object_def_viewers];
GO
GRANT EXECUTE ON [dbo].[OperatorGetGridInfo] TO db_dml;
GO