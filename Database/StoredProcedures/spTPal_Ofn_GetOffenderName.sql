USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Ofn_GetOffenderName]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Ofn_GetOffenderName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetOffenderName.sql
 * Created On: 01-Feb-2011         
 * Created By: Sajid Abbasi  
 * Task #:     Redmine #      
 * Purpose:    Get Offender name to address Task #1891
 *
 * Modified By: R.Cole - 01-Feb-2011:  Added proper template
 *                for SVN commit
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_GetOffenderName] (
    @OffenderID INT
) 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT LastName + ', ' + FirstName AS 'OffenderName'
FROM Offender 
WHERE OffenderID = @OffenderID

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Ofn_GetOffenderName] TO db_dml;
GO