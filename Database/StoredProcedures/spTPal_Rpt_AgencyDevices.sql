USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AgencyDevices]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AgencyDevices]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AgencyDevices.sql
 * Created On: 8/25/2011         
 * Created By: R.Cole  
 * Task #:     2627      
 * Purpose:    Populate the old AgencyDevices report               
 *
 * Modified By: R.Cole - 5/21/2012: Fixed an issue where RMA
 *                Devices were not being properly counted.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AgencyDevices] (
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,         -- ??
  @StartDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
DECLARE @UTCOffset INT,
        @RunDate CHAR(10)

-- // Handle UTCOffsets based on who is running the report // --
IF @DistributorID > 0 --IS NOT NULL                                       -- Distributor User
  SET @UTCOffset = dbo.fnGetDistributorUtcOffset(@DistributorID)
ELSE IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
ELSE                                                                      -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Set Report RunDate // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)
--SET @RunDate = CONVERT(CHAR(10), GETDATE(),110)
  
-- // Account for NULL Date params // --
IF (@StartDate IS NULL) 
  SET @StartDate = DATEADD(DAY, -1, DATEADD(mi,@UTCOffset,GETDATE()))

IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))  
  -- // Get Resultset for All Agencies belonging to Distributor // --
  BEGIN   
    SELECT REPLACE(Agency.Agency, ',', ';') AS 'Agency',
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
                   WHERE a.DistributorID = @DistributorID
                     AND DATEADD(mi,@UTCOffset,t.CreatedDate) <= @StartDate 
                     AND (t.Deleted = 0) OR (t.Deleted = 1 AND DATEADD(mi,@UTCOffset,t.ModifiedDate) >= @StartDate)                   
		                 AND t.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = t.TrackerID)		                 
	                 GROUP BY a.AgencyID
                 ) assigned ON Agency.AgencyID = assigned.AgencyID
      LEFT OUTER JOIN ( SELECT DISTINCT b.AgencyID,
	                             COUNT(ota.TrackerID) AS 'TotalActive'	
	                      FROM OffenderTrackerActivation ota
		                      INNER JOIN Offender ON Offender.OffenderID = ota.offenderid
		                      INNER JOIN Agency b ON b.AgencyID = Offender.AgencyID		                      
	                      WHERE b.DistributorID = @DistributorID
	                        AND DATEADD(mi,@UTCOffset,ota.ActivateDate) <= @StartDate 
	                        AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)	                        
	                      GROUP BY b.AgencyID
                      ) active ON Agency.AgencyID = active.AgencyID
      LEFT OUTER JOIN ( SELECT DISTINCT c.AgencyID,
	                             COUNT(tr.TrackerID) AS 'TotalRMA'
	                      FROM Tracker tr
	                        INNER JOIN Agency c ON tr.AgencyID = c.AgencyID
	                      WHERE c.DistributorID = @DistributorID	                      
	                        AND tr.RMAID IS NOT NULL
--	                        AND DATEADD(mi,@UTCOffset,tr.ModifiedDate) <= @StartDate
	                        AND tr.Deleted = 0
	                      GROUP BY c.AgencyID
                      ) rma ON Agency.AgencyID = rma.AgencyID
    WHERE Agency.DistributorID = @DistributorID
      AND Agency.Deleted = 0    
    ORDER BY Agency.Agency
  END  
ELSE
  IF (@AgencyID > -1)
    -- // Get Resultset for Single Agency // --
    BEGIN
      SELECT REPLACE(Agency.Agency, ',', ';') AS 'Agency',
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
                     WHERE a.AgencyID = @AgencyID
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
	                        WHERE b.AgencyID = @AgencyID
	                          AND DATEADD(mi,@UTCOffset,ota.ActivateDate) <= @StartDate 
	                          AND (DATEADD(mi,@UTCOffset,ota.DeactivateDate) >= @StartDate OR ota.DeactivateDate IS NULL)
	                        GROUP BY b.AgencyID
                        ) active ON Agency.AgencyID = active.AgencyID
        LEFT OUTER JOIN ( SELECT DISTINCT c.AgencyID,
	                               COUNT(tr.TrackerID) AS 'TotalRMA'
	                        FROM Tracker tr
	                          INNER JOIN Agency c ON tr.AgencyID = c.AgencyID
	                        WHERE c.AgencyID = @AgencyID
	                          AND tr.RMAID IS NOT NULL
--	                          AND DATEADD(mi,@UTCOffset,tr.ModifiedDate) <= @StartDate	                          
	                          AND tr.Deleted = 0
	                        GROUP BY c.AgencyID
                        ) rma ON Agency.AgencyID = rma.AgencyID
      WHERE Agency.AgencyID = @AgencyID
        AND Agency.Deleted = 0    
      ORDER BY Agency.Agency
    END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AgencyDevices] TO db_dml;
GO