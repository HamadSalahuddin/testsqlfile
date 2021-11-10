USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_ReportingIntervalException]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_ReportingIntervalException]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_ReportingIntervalException.sql
 * Created On: 9/1/2011         
 * Created By: R.Cole
 * Task #:     2387
 * Purpose:    Return data for the ReportingIntervalException
 *             Report               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_ReportingIntervalException] 

AS   

-- // Main Query // --
SELECT DISTINCT Tracker.TrackerID,
       LEFT(Tracker.TrackerName, 8) AS SerialNumber,
       Agency.Agency,
	     Offender.FirstName + ' ' + Offender.LastName AS Offender,
	     Gateway.dbo.HexToSmallInt(DeviceProperties.PropertyValue) AS GW_ReportingInterval,
	     rs.TimeSeconds AS TP_ReportingInterval
FROM Tracker
  INNER JOIN TrackerAssignment ON Tracker.TrackerID = TrackerAssignment.TrackerID
  INNER JOIN OffenderTrackerActivation ON Tracker.TrackerID = OffenderTrackerActivation.TrackerID	
  INNER JOIN Offender ON OffenderTrackerActivation.OffenderID = Offender.OffenderID
	INNER JOIN Agency ON Tracker.AgencyID = Agency.AgencyID	
	INNER JOIN Gateway.dbo.DeviceProperties ON Tracker.trackerid = DeviceProperties.DeviceID AND DeviceProperties.PropertyID = '8020' 
  INNER JOIN OptionalBillingServiceOptionOffender ob ON Offender.OffenderID = ob.OffenderID
  INNER JOIN dbo.BillingServiceOptionReportingInterval bor ON ob.BillingServiceOptionID = bor.BillingServiceOptionID 
  INNER JOIN dbo.refServiceOptionReportingInterval rs ON bor.ReportingIntervalID = rs.ID 
WHERE Tracker.Deleted = 0
  AND OffenderTrackerActivation.DeactivateDate is NULL
  AND TrackerAssignment.CreatedDate = (SELECT MAX(CreatedDate) 
                                       FROM TrackerAssignment t
                                       WHERE t.TrackerID = Tracker.TrackerID)
  AND Offender.Deleted = 0
  AND (Gateway.dbo.HexToSmallInt(DeviceProperties.PropertyValue) <> rs.TimeSeconds)
  AND Agency.AgencyID NOT IN (21,263,993,1236,1292,1330)
ORDER BY Agency.Agency,
         Offender.FirstName + ' ' + Offender.LastName 
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_ReportingIntervalException] TO db_dml;
GO