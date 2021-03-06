USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DistributorEmployeeGetBySearch]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DistributorEmployeeGetBySearch]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   [DistributorEmployeeGetBySearch].sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Returns Distributors                
 *
 * Modified By: S.Abassi - 02/2010 - SA 567
 *              R.Cole - 04/09/2010 - Added IF Exists and Grant
 * ******************************************************** */

CREATE PROCEDURE [dbo].[DistributorEmployeeGetBySearch] (
  @FirstName NVARCHAR(50),
	@LastName	NVARCHAR(50),
	@DistributorID INT,
	@UserID INT = -1,
  @RoleID INT = -1
)
AS
IF (@RoleID <> 19)
	BEGIN
	  SELECT d.DistributorEmployeeID,
	         de.DistributorName, 
	         d.FirstName, 
	         d.LastName, 
	         r.Role
    FROM DistributorEmployee AS d 
      LEFT OUTER JOIN User_Role AS ur ON d.UserID = ur.UserID 
      LEFT OUTER JOIN Role AS r ON ur.RoleID = r.RoleID 
      RIGHT OUTER JOIN Distributor AS de ON de.DistributorID = d.DistributorID
    WHERE	( (LEN(@FirstName) <= 0 ) OR (d.FirstName LIKE '%' + @FirstName + '%') )	
			AND	( (LEN(@LastName) <= 0) OR (d.LastName Like '%' + @LastName + '%') )	
			AND (	(@DistributorID =0)	OR (d.DistributorID = @DistributorID)	)
			AND d.Deleted = 0
		ORDER BY d.LastName, 
		         d.FirstName
  END
ELSE
  BEGIN
    SELECT d.DistributorEmployeeID, 
           de.DistributorName, 
           d.FirstName, 
           d.LastName
	  FROM (SELECT dis.DistributorID, 
	               dis.DistributorName
	        FROM Distributor dis	
	          LEFT JOIN User_Role ur ON dis.TamID = ur.UserID	
          WHERE	deleted = 0 
            AND ur.RoleID = 19 
            AND ur.UserID = @UserID)de  
      LEFT OUTER JOIN DistributorEmployee d ON d.DistributorID = de.DistributorID
    WHERE ( (LEN(@FirstName) <= 0 ) OR (d.FirstName LIKE '%' + @FirstName + '%') )	
			AND ( (LEN(@LastName) <= 0) OR (d.LastName Like '%' + @LastName + '%') )	
			AND ( (@DistributorID =0)	OR (d.DistributorID = @DistributorID)	)	
			AND d.Deleted = 0
		ORDER BY d.LastName, 
		         d.FirstName
	END
GO

GRANT EXECUTE ON [dbo].[DistributorEmployeeGetBySearch] TO db_dml;
GO


