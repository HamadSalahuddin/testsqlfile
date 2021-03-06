USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mEventInsertBucket1]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[mEventInsertBucket1]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   mEventInsertBucket1.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:    Populate the rprtEventsBucket1 Table
 * Called By:  TrackerPal\RemotingModules\DAL.Event.cs               
 *
 * Modified By: R.Cole - 12/23/2009 - Task #481
 *              R.Cole - 11/05/2010 - Task #1337: Cleaned up
 *                Code, brought up to standard. Removed 
 *                deprecated code.
 *              R.Cole - 09/30/2011 - Task #2723: 
 *                
 * ******************************************************** */
CREATE PROCEDURE [dbo].[mEventInsertBucket1] (
        @EventPrimaryID	BIGINT OUTPUT,
        @EventID BIGINT,
        @EventTypeGroupID BIGINT = NULL,
        @AlarmTypeID INT = NULL,
        @AlarmID BIGINT = NULL,
        @DeviceID BIGINT,
        @TrackerNumber VARCHAR(32)= NULL,
        @EventName VARCHAR(50) = NULL,
        @EventTime BIGINT,
        @EventDateTime DATETIME = NULL,
        @EventParameter BIGINT = NULL,
        @AgencyID INT = NULL,
        @OffenderID BIGINT = NULL,
        @OfficerID BIGINT = NULL,
        @ReceivedTime DATETIME = NULL,
        @Latitude FLOAT = NULL,
        @Longitude FLOAT = NULL,
        @SO BIT = NULL,
        @OPR BIT = NULL,
        @NoteCount INT = NULL,
        @GeoRuleName NVARCHAR(50) = NULL,
        @AlarmAssignmentStatusID INT = NULL,
        @AcceptedBy INT = NULL,
        @ActivateDate DATETIME = NULL,
        @DeActivateDate DATETIME = NULL,
        @GpsValid BIT = NULL,
        @GpsValidSatellites INT = NULL,
        @AcceptedDate DATETIME = NULL,
        @AlarmAssignmentStatus NVARCHAR(50) = NULL,
        @EventQueueID INT = NULL,
        @OffenderName NVARCHAR(100),
        @OffenderDeleted BIT = 0,
        @BeaconSerialNumber VARCHAR(100) = NULL,
		    @Address VARCHAR(100) = NULL,
		    @RadiusOfConfidence INT = NULL        
)
AS

-- // Get the GeoRule Name // --
IF (@EventID IN (32,33,36,37,40,41,44,45))
  BEGIN
    EXEC GeoruleGetNewName @Offenderid, @EventParameter, @GeoruleName OUTPUT
	END

-- // Get the Beacon Address // --
IF (@EventID IN (176,177,178,179,180,181,182,184,185,192,193,194,195))
	BEGIN
		EXEC mBeaconGetAddressBySerialNumber @BeaconSerialNumber, @OffenderID, @Address OUTPUT, @Latitude OUTPUT, @Longitude OUTPUT
	END

/* =============== Ensure Valid Data ================== */
-- // Fix Offender Name // --
IF ((@OffenderName IS NULL) OR (@OffenderName = ''))
  BEGIN
    SET @OffenderName = (SELECT Offender.FirstName + ' ' + Offender.LastName
                         FROM Offender
                         WHERE Offender.OffenderID = @OffenderID)
  END

-- // Fix OfficerID // --
IF ((@OfficerID IS NULL) OR (@OfficerID = 0))
  BEGIN
    SET @OfficerID = ISNULL((SELECT OfficerID
                             FROM Offender
                               INNER JOIN Offender_Officer ON Offender_Officer.OffenderID = Offender.OffenderID
                             WHERE Offender.OffenderID = @OffenderID),0)
  END

-- // Fix AgencyID // --
IF ((@AgencyID IS NULL) OR (@AgencyID = 0))
  BEGIN
    SET @AgencyID = ISNULL((SELECT Agency.AgencyID
                            FROM Offender 
                              INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
                            WHERE Offender.OffenderID = @OffenderID),0)
  END
/* ===================== End Validity Checks =============== */

-- // Handle Triangulation Radius Of Confidence // --
IF (@EventID IN (152,153) AND @RadiusOfConfidence <> NULL ) -- Triangulation
  BEGIN
		SET @GeoRuleName = @RadiusOfConfidence
    SET	@GpsValid = 1
	END


-- // Insert Event Record // --
INSERT rprtEventsBucket1 (	
       EventID,
	     DeviceID,
	     EventTime,
	     EventDateTime,
	     TrackerNumber,
	     EventName,
	     EventParameter,
	     ReceivedTime,
	     OfficerID,
	     OffenderID,
	     AgencyID,
	     [Address],
	     Latitude,
	     Longitude,
	     OPR,
	     SO,
	     NoteCount,
	     AlarmType,
	     AlarmID,
	     GeoRule,
	     AlarmAssignmentStatusID,
	     AlarmAssignmentStatusName,
	     AcceptedBy,
	     ActivateDate,
	     DeActivateDate,
	     GpsValid,
	     GpsValidSatellites,
	     AcceptedDate,
	     EventTypeGroupID,
	     EventQueueID,
	     OffenderName,
	     OffenderDeleted			
)
VALUES (@EventID,
		    @DeviceID,
		    @EventTime,
		    @EventDateTime,
		    @TrackerNumber,
		    @EventName,
		    @EventParameter,
		    @ReceivedTime,	
		    @OfficerID,	
		    @OffenderID,
		    @AgencyID,
		    @Address,
		    @Latitude,
		    @Longitude,
		    @SO,
		    @OPR,
		    @NoteCount,
		    @AlarmTypeID,
		    @AlarmID,
		    @GeoRuleName,
		    @AlarmAssignmentStatusID,
		    @AlarmAssignmentStatus,
		    @AcceptedBy,
		    @ActivateDate,
		    @DeActivateDate,
		    @GpsValid,
		    @GpsValidSatellites,
		    @AcceptedDate,
		    @EventTypeGroupID,
		    @EventQueueID,
		    @OffenderName,
		    @OffenderDeleted
)

-- // Set the EventID // --
SET @EventPrimaryID = @@IDENTITY
GO

--// Grant Permissions - This statement MUST be present, do not alter // --
GRANT EXECUTE ON [dbo].[mEventInsertBucket1] TO db_dml;
GO