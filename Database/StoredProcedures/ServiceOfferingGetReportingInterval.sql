USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ServiceOfferingGetReportingInterval]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ServiceOfferingGetReportingInterval]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   ServiceOfferingGetReportingInterval.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:           
 * Purpose:    Get Service Offering Reporting Interval data.               
 *
 * Modified By: R.Cole - 02/28/2011: Removed Select *
 * ******************************************************** */
CREATE PROCEDURE [ServiceOfferingGetReportingInterval]
AS  
SELECT ID,
       Name,
       TimeSeconds,
       DisplayOrder  
FROM refServiceOptionReportingInterval 
ORDER BY DisplayOrder 
GO

GRANT EXECUTE ON [ServiceOfferingGetReportingInterval] TO [db_dml]
GO
