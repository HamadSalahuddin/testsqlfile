USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AgencyGrowth]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AgencyGrowth]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AgencyGrowth.sql
 * Created On: 11/14/2011         
 * Created By: Scott Fieber
 * Purpose:    Daily Agency Growth Report for Account Managers
 
 * Modified By: R.Cole - 11/22/2011: Added DROP IF EXISTS and 
 *                GRANT stmts. Set isolation level and slightly 
 *                revised formatting and aliases per standard.
 *                Added report dates to dataset.
 *              R.Cole - 12/6/2011: #2964 Added code to 
 *                determine territory based on the State.
 *              R.Cole - 05/22/2012: Scott rewrote the query
 *                to run strictly off the TrackerPal DB.
 *              R.Cole - 10/23/2012: Added Hawaii to "West"
 *              R.Cole - 01/22/2013: Per #3878, revised state assignments
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AgencyGrowth] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate SMALLDATETIME,
        @UTCOffset INT,
        @RunDate CHAR(10)

SET @StartDate = GETDATE()
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)  -- Set report run date (MT)

SELECT CASE WHEN st.StateID IN (7,44,45) THEN 'Corporate'
            WHEN st.StateID IN (3,4,6,12,13,27,29,38,48,51) THEN 'West'
            WHEN st.StateID IN (2,5,11,14,15,18,19,23,25,26,34,41,43,50) THEN 'Midwest'
            WHEN st.StateID IN (8,9,20,21,22,30,31,33,36,39,40,46,47,49) THEN 'East'
            WHEN st.StateID IN (16,17,28,32,35,37,42) THEN 'No Sales Rep'
            WHEN st.StateID IN (10) THEN 'Florida'
            WHEN st.StateID IN (24) THEN 'MMS'
            ELSE 'Undefined'
       END AS 'Territory',
       REPLACE(Agency.Agency, ',', ';') AS 'Agency',
       st.Abbreviation AS 'State',        
	     assigned.TotalAssigned AS 'TotalAssignedDevices',
	     ISNULL(active.TotalActive,0) AS 'ActiveDevices',
	     ISNULL(rma.TotalRMA, 0) AS 'RMADevices',
	     (assigned.TotalAssigned - ISNULL(active.TotalActive,0) - ISNULL(rma.TotalRMA,0)) AS 'InactiveDevices',
		   @RunDate AS RunDate,
		   CONVERT(CHAR(10),@StartDate,101) AS StartDate
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
	                         COUNT(ota.TrackerID) AS 'TotalActive'	
	                  FROM OffenderTrackerActivation ota
		                  INNER JOIN Offender ON Offender.OffenderID = ota.offenderid
		                  INNER JOIN Agency b ON b.AgencyID = Offender.AgencyID
	                  WHERE b.Deleted = 0 
	                    AND DATEADD(mi,@UTCOffset,ota.ActivateDate) <= @StartDate 
	                    AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
	                  GROUP BY b.AgencyID
                  ) active ON Agency.AgencyID = active.AgencyID
  LEFT OUTER JOIN ( SELECT DISTINCT c.AgencyID,
	                         COUNT(tr.TrackerID) AS 'TotalRMA'
	                  FROM Tracker tr
	                    INNER JOIN Agency c ON tr.AgencyID = c.AgencyID
	                  WHERE tr.RMAID IS NOT NULL
                      AND tr.Deleted = 0
                    GROUP BY c.AgencyID
                  ) rma ON Agency.AgencyID = rma.AgencyID
  INNER JOIN State st ON Agency.StateID = St.StateID
WHERE Agency.Deleted = 0  
  AND agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
ORDER BY agency.Agency
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AgencyGrowth] TO db_dml;
GO