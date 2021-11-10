USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_MonthlyActiveDeviceTotals]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_MonthlyActiveDeviceTotals]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_MonthlyActiveDeviceTotals.sql
 * Created On: 01/04/2012        
 * Created By: Scott Fieber
 * Redmine:    2963
 * Purpose:    Monthly Report for SharLyn Hodson
 *
 * Modified By: R.Cole - 01/06/2012 - Converted Start and End
 *                date params to SMALLDATETIME
 *              R.Cole - 01/16/2012 - Added code to display
 *                sales territories
 *              R.Cole - 05/29/2012 - Revised to not use
 *                the ReportHelper db.
 *              R.Cole - 05/31/2012 - Fixed an issue where 
 *                Puerto Rico was falling into "Unassigned".
 *              R.Cole - 01/22/2013: Per 3878, revised state assignments
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_MonthlyActiveDeviceTotals] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate SMALLDATETIME,
        @UTCOffset INT

SET @StartDate = GETDATE()
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime

SELECT DISTINCT Agency.Agency,
       st.Abbreviation AS 'State',
       CASE WHEN st.StateID IN (7,44,45) THEN 'Corporate'
            WHEN st.StateID IN (3,4,6,12,13,27,29,38,48,51) THEN 'West'
            WHEN st.StateID IN (2,5,11,14,15,18,19,23,25,26,34,41,43,50) THEN 'Midwest'
            WHEN st.StateID IN (8,9,20,21,22,30,31,33,36,39,40,46,47,49) THEN 'East'
            WHEN st.StateID IN (16,17,28,32,35,37,42) THEN 'No Sales Rep'
            WHEN st.StateID IN (10) THEN 'Florida'
            WHEN st.StateID IN (24) THEN 'MMS'
            ELSE 'Undefined'
       END AS 'Territory',
       ISNULL(active.TotalActive,0) AS 'Active Devices'
FROM Agency 
  INNER JOIN ( SELECT a.AgencyID,
                      COUNT(DISTINCT t.TrackerID) AS 'TotalAssigned'
                FROM Tracker t
                  LEFT OUTER JOIN Agency a ON t.AgencyID = a.AgencyID
                WHERE a.Deleted = 0 
                 AND DATEADD(mi,@UTCOffset,t.CreatedDate) <= @StartDate 
                 AND (t.Deleted = 0) OR (t.Deleted = 1 AND DATEADD(mi,@UTCOffset,t.ModifiedDate) > @StartDate)
                 AND t.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = t.TrackerID)
                GROUP BY a.AgencyID
             ) assigned ON Agency.AgencyID = assigned.AgencyID
  LEFT OUTER JOIN ( SELECT DISTINCT b.AgencyID,
                           COUNT(DISTINCT ota.TrackerID) AS 'TotalActive' 
                    FROM OffenderTrackerActivation ota
                      INNER JOIN Offender ON Offender.OffenderID = ota.offenderid
                      INNER JOIN Agency b ON b.AgencyID = Offender.AgencyID
                      Inner Join Tracker t0 on ota.TrackerID = T0.TrackerID 
                      INNER JOIN TrackerBillable ON ota.TrackerID = TrackerBillable.TrackerID 
                    WHERE b.Deleted = 0 
                      AND DATEADD(mi,@UTCOffset,ota.ActivateDate) <= @StartDate 
                      AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
                      AND T0.Deleted = 0
                      AND T0.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t1 WHERE t1.TrackerID = T0.TrackerID)
                      AND TrackerBillable.[Status] = 1 
                      AND T0.IsDemo = 0  
                     GROUP BY b.AgencyID
                   ) active ON Agency.AgencyID = active.AgencyID
  INNER JOIN State st ON Agency.StateID = St.StateID       
WHERE Agency.Deleted = 0  
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)  
ORDER BY Agency.Agency
GO

GRANT EXECUTE ON [dbo].[spTPal_Rpt_MonthlyActiveDeviceTotals] TO db_dml;
GO