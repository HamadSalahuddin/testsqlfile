USE [TrackerPal]
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_Enrollment]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_Enrollment]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_Enrollment.sql
 * Created On: 10/10/2011
 * Created By: R.Cole
 * Task #:     #2798
 * Purpose:    Return data for the Enrollment Report               
 *
 * Modified By: R.Cole - 10/12/2011: Removed OfficerID as a
 *                parameter, added AgencyID
 *              R.Cole - 10/13/2011: Added time segment back
 *                to the DateTimes.  Added Offender's PostalCode
 *                and removed some deprecated code.
 *              R.Cole - 3/8/2012: Added code to handle Distributors,
 *                and Application Admins.  
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_Enrollment] (
  @AgencyID INT,
  @DistributorID INT = NULL,
  @RoleID INT = NULL,
  @StartDate DATETIME = NULL,
  @EndDate DATETIME = NULL
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


-- // Declare Var's // --
DECLARE @RunDate CHAR(10),
        @UTCOffset INT

-- // Handle UTCOffsets based on who is running the report // --
IF @DistributorID > 0 --IS NOT NULL                                       -- Distributor User
  SET @UTCOffset = dbo.fnGetDistributorUtcOffset(@DistributorID)
ELSE IF @RoleID = 4                                                       -- App Admin/SuperUser
  SET @UTCOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
ELSE                                                                      -- Agency User
  SET @UTCOffset = dbo.fnGetUtcOffset(@AgencyID)

-- // Set Report Dates // --
SET @RunDate = CONVERT(CHAR(10), DATEADD(mi,@UTCOffset,GETDATE()),110)

-- // Account for NULL StartDate // --
IF (@StartDate IS NULL)
  BEGIN
    SET @StartDate = DATEADD(HOUR, -24, DATEADD(mi,@UTCOffset,GETDATE()))
    SET @EndDate = DATEADD(mi,@UTCOffset,GETDATE())
  END
   
-- // Main Query // --
IF ((@DistributorID IS NOT NULL) AND (@AgencyID = -1))  
  BEGIN
    -- // Get Resultset for All Agencies belonging to Distributor // --
    SELECT DISTINCT Offender.OffenderID,
           Offender.FirstName + ' ' + Offender.LastName AS [Offender],
           Offender.CaseNumber,
           Agency.Agency,
           Officer.FirstName + ' ' + Officer.LastName AS [Officer],
           DATEADD(MI, @UTCOffset, Offender.CreatedDate) AS [EnrollmentDate],
           Offender.HomeStreet1 + ' ' + ISNULL(Offender.HomeStreet2,'') + ' ' + Offender.HomeCity + ', ' + st.[State] + ' ' + Offender.HomePostalCode AS [OffenderAddress],
           @RunDate AS [RunDate],
           CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
           CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]       
    FROM Offender
      INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
      INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
      INNER JOIN [State]st ON Offender.HomeStateOrProvinceID = st.StateID
    WHERE Agency.DistributorID = @DistributorID
      AND Agency.Deleted = 0
      AND ((Offender.TrackerID = -1) OR (Offender.TrackerID IS NULL))
      AND NOT EXISTS (SELECT TOP 1 * FROM OffenderTrackerActivation WHERE OffenderTrackerActivation.OffenderID = Offender.OffenderID)
      AND Offender.Deleted = 0
      AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset, Offender.CreatedDate) AS FLOAT)) AS DATETIME) BETWEEN (CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)) AND (CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME))
  END
ELSE 
  IF (@AgencyID > -1)
    -- // Get Resultset for Single Agency // --
    BEGIN
      SELECT DISTINCT Offender.OffenderID,
             Offender.FirstName + ' ' + Offender.LastName AS [Offender],
             Offender.CaseNumber,
             Agency.Agency,
             Officer.FirstName + ' ' + Officer.LastName AS [Officer],
             DATEADD(MI, @UTCOffset, Offender.CreatedDate) AS [EnrollmentDate],
             Offender.HomeStreet1 + ' ' + ISNULL(Offender.HomeStreet2,'') + ' ' + Offender.HomeCity + ', ' + st.[State] + ' ' + Offender.HomePostalCode AS [OffenderAddress],
             @RunDate AS [RunDate],
             CONVERT(CHAR(10), @StartDate, 110) AS [StartDate],
             CONVERT(CHAR(10), @EndDate, 110) AS [EndDate]       
      FROM Offender
        INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
        INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
        INNER JOIN [State]st ON Offender.HomeStateOrProvinceID = st.StateID
      WHERE Agency.AgencyID = @AgencyID
        AND ((Offender.TrackerID = -1) OR (Offender.TrackerID IS NULL))
        AND NOT EXISTS (SELECT TOP 1 * FROM OffenderTrackerActivation WHERE OffenderTrackerActivation.OffenderID = Offender.OffenderID)
        AND Offender.Deleted = 0
        AND CAST(FLOOR(CAST(DATEADD(MI,@UTCOffset, Offender.CreatedDate) AS FLOAT)) AS DATETIME) BETWEEN (CAST(FLOOR(CAST(@StartDate AS FLOAT)) AS DATETIME)) AND (CAST(FLOOR(CAST(@EndDate AS FLOAT)) AS DATETIME))        
    END               
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_Enrollment] TO db_dml;
GO