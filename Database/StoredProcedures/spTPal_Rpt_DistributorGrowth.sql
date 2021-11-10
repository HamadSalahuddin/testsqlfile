USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DistributorGrowth]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DistributorGrowth]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DistributorGrowth.sql
 * Created On: 10/19/2012
 * Created By: R.Cole
 * Task #:     #3711
 * Purpose:    Return distributor level growth details               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DistributorGrowth] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate SMALLDATETIME,
        @UTCOffset INT,
        @RunDate CHAR(10)

SET @StartDate = GETDATE()
SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)  -- Set report run date (MT)

-- // Get Agency Detail Data  // --
SELECT CASE WHEN st.StateID IN (3,4,6,13,27,29,38,48,51) THEN 'West'
            WHEN st.StateID IN (7,17,28,32,37,44,45) THEN 'Southwest'
            WHEN st.StateID IN (2,5,14,15,16,18,19,23,24,25,26,35,36,42,43,50) THEN 'Midwest'
            WHEN st.StateID IN (8,9,10,20,32,22,30,31,33,34,39,40,41,46,47,49) THEN 'East'
            WHEN st.StateID IN (11) THEN 'Midwest/East'
            ELSE 'Unassigned'
       END AS 'Territory',
       Agency.AgencyID,
       Agency.DistributorID,
       REPLACE(Agency.Agency, ',', ';') AS 'Agency',
       st.Abbreviation AS 'State',        
	     assigned.TotalAssigned AS 'TotalAssignedDevices',
	     ISNULL(active.TotalActive,0) AS 'ActiveDevices',
	     ISNULL(rma.TotalRMA, 0) AS 'RMADevices',
	     (assigned.TotalAssigned - ISNULL(active.TotalActive,0) - ISNULL(rma.TotalRMA,0)) AS 'InactiveDevices',
		   @RunDate AS RunDate,
		   CONVERT(CHAR(10),@StartDate,101) AS StartDate
INTO #tmpAgencyGrowth
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

-- // Put together Final Summarized Results // --
SELECT CASE WHEN st.StateID IN (3,4,6,13,27,29,38,48,51) THEN 'West'
            WHEN st.StateID IN (7,17,28,32,37,44,45) THEN 'Southwest'
            WHEN st.StateID IN (2,5,14,15,16,18,19,23,24,25,26,35,36,42,43,50) THEN 'Midwest'
            WHEN st.StateID IN (8,9,10,20,32,22,30,31,33,34,39,40,41,46,47,49) THEN 'East'
            WHEN st.StateID IN (11) THEN 'Midwest/East'
            ELSE 'Unassigned'
       END AS 'Territory',
       Distributor.DistributorName,
       st.Abbreviation AS 'State',
       SUM(ag.TotalAssignedDevices) AS TotalAssignedDevices,
       SUM(ag.ActiveDevices) AS ActiveDevices,
       SUM(ag.RMADevices) AS RMADevices,
       SUM(InactiveDevices) AS InactiveDevices,
       ag.RunDate,
       ag.StartDate        
FROM Distributor
  INNER JOIN [State] st ON Distributor.StateID = st.StateID
  INNER JOIN #tmpAgencyGrowth ag ON Distributor.DistributorID = ag.DistributorID
GROUP BY Distributor.DistributorName,
         st.StateID,
         st.Abbreviation,
         ag.RunDate,
         ag.StartDate
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_DistributorGrowth] TO db_dml;
GO