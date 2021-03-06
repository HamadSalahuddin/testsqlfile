USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_GetReportParam]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_GetReportParam]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_GetReportParam.sql
 * Created On: 21-Nov-2011         
 * Created By: Sajid Abbasi  
 * Task #:     2965     
 * Purpose:    Get the parameters for a report               
 *
 * Modified By: R.Cole - 11/30/2011: Removed aliases per standard,
 *                added DROP IF EXISTS and GRANT Stmts needed
 *                for SVN version
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_GetReportParam] (
	@ReportName VARCHAR(MAX)
	--@ReportID INT
)
AS
BEGIN
	SELECT Reports.ReportName,
	       ReportParameter.ParamName, 
	       ReportParameter.ParamValue, 
	       ReportParameter.Display
	FROM ReportParameter 
	INNER JOIN Report_Param ON Report_Param.ParamID = ReportParameter.ParamID
	INNER JOIN  Reports ON Reports.ReportID = Report_Param.ReportID
	WHERE Reports.ReportName LIKE @ReportName
	  -- Reports.ReportID = @ReportID
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Rpt_GetReportParam] TO db_dml;
GO
