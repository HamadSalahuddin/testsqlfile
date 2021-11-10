USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_GetReportsList]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_GetReportsList]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_GetReportsList.sql
 * Created On: 25-Aug-2011         
 * Created By: Sajid Abbasi  
 * Task #:     2627     
 * Purpose:    Populate the Reports dropdown in TrackerPal               
 *
 * Modified By: SABBASI - 02-Feb-2012: Added AllowedRoles field to 
 *                set access by roles configureable.
 *              SABBASI - 27-Feb-2012: Added ReportTpeID field to 
 *                configure Reports with EndDate =null.
 *              SABBASI - 6/14/2012: Added Description field.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_GetReportsList] 
AS
SELECT ReportName, 
       RelativePath,
	     AllowedRoles,
	     ReportTypeID,
       [Description]        
FROM Reports   
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_GetReportsList] TO db_dml;
GO