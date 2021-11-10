/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [GeoRuleSave]
	@AgencyID INT,
	@OffenderID INT,
	@GRGeoRuleID INT,
	@GRGeoRuleName VARCHAR(50),
	@GRGeoRuleTypeID INT,
	@GRGeoRuleReferencePointID INT,
	@GRGeoRuleScheduleID INT,
	@GRCreatedDate DATETIME,
	@GRCreatedByID INT,
	@GRModifiedDate DATETIME,
	@GRModifiedByID INT,
	@GRDeleted BIT,
	@GRStatusID INT,
	@GRUpdateInProgress BIT,
	@GRZoneID INT,
	@GRGeoRuleShapeID INT,
	@GRLatitude FLOAT,
	@GRLongitude FLOAT,
	@GRRadius INT,
	@GRWidth FLOAT,
	@GRHeight FLOAT,
	@GRRotation FLOAT,
	@GRLatitudes VARCHAR(5000),
	@GRLongitudes VARCHAR(5000),
	
	--Schedule
	@SCAlwaysOn BIT,
	@SCStartTime INT,
	@SCEndTime INT,
	@SCSunday BIT,
	@SCMonday BIT,
	@SCTuesday BIT,
	@SCWednesday BIT,
	@SCThursday BIT,
	@SCFriday BIT,
	@SCSaturday BIT,

	--Reference	
	@Street 	NVARCHAR(50),
	@City NVARCHAR(50),
	@StateID INT,
	@PostalCode NVARCHAR(25),
	@CountryID INT,
	@Longitude FLOAT,
	@Latitude FLOAT

AS
BEGIN
	--Add GeoRuleSchedule	
	DECLARE @GeoRuleScheduleID AS INT
	DECLARE @GeoRuleReferencePointID	INT
	DECLARE @GeoRuleID INT
	DECLARE @RowCount INT

	BEGIN TRAN
		--Test to see if we should update or insert
		SET NOCOUNT OFF;
		SELECT GeoRuleID FROM GeoRule WHERE GeoRuleID=@GRGeoRuleID

		IF (@@ROWCOUNT = 0) BEGIN 
			--INSERT
			INSERT INTO GeoRuleSchedule(AlwaysOn, StartTime, EndTime, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday)
			VALUES(@SCAlwaysOn, @SCStartTime, @SCEndTime, @SCSunday, @SCMonday, @SCTuesday, @SCWednesday,@SCThursday, @SCFriday, @SCSaturday)
			SET @GeoRuleScheduleID = @@IDENTITY

			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 1
			END
			
			--Add GeoRuleReferencePoint
			INSERT INTO GeoRuleReferencePoint	(Street, City, StateID, PostalCode, CountryID, Longitude, Latitude)
			VALUES(@Street, @City, @StateID, @PostalCode, @CountryID, @Longitude, @Latitude)
			SET @GeoRuleReferencePointID = @@IDENTITY
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 2
			END

			--Insert GeoRule
			INSERT INTO GeoRule(GeoRuleName, GeoRuleShapeID, GeoRuleTypeID, GeoRuleReferencePointID, GeoRuleScheduleID,
				 Longitude, Latitude, Radius, Width, Height, Longitudes, Latitudes, AlarmInstructions, 
				 CreatedByID, ModifiedByID, UpdateInProgress, CreatedDate, ModifiedDate, Deleted, StatusID, Rotation)
			VALUES(@GRGeoRuleName, @GRGeoRuleShapeID, @GRGeoRuleTypeID, @GeoRuleReferencePointID, @GeoRuleScheduleID,
				 @GRLongitude, @GRLatitude, @GRRadius, @GRWidth, @GRHeight, @GRLongitudes, @GRLatitudes, '', 
				 @GRCreatedByID, @GRModifiedByID, 1, @GRCreatedDate, @GRModifiedDate, 0,@GRStatusID, @GRRotation)
			SET @GeoRuleID = @@IDENTITY
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 3
			END

			--Add GeoRule_Agency
			INSERT INTO GeoRule_Agency(GeoRuleID, AgencyID)
			VALUES(@GeoRuleID, @AgencyID)
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 4
			END

			--Add GeoRule_Offender
			INSERT INTO GeoRule_Offender(GeoRuleID, OffenderID, ZoneID)
			VALUES(@GeoRuleID, @OffenderID, @GRZoneID)
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 5
			END
		END
		ELSE BEGIN
			--UPDATE GeoRule
			UPDATE GeoRule
			SET GeoRuleName=@GRGeoRuleName, GeoRuleShapeID=@GRGeoRuleShapeID, GeoRuleTypeID=@GRGeoRuleTypeID, 
				GeoRuleReferencePointID=@GRGeoRuleReferencePointID, GeoRuleScheduleID=@GRGeoRuleScheduleID, 
				Longitude =@GRLongitude, Latitude =@GRLatitude, Radius =@GRRadius, Width =@GRWidth, Height =@GRHeight, 
				Rotation =@GRRotation, Longitudes =@GRLongitudes, Latitudes =@GRLatitudes, AlarmInstructions ='', 
				CreatedDate =@GRCreatedDate, CreatedByID =@GRCreatedByID, ModifiedDate =@GRModifiedDate, 
				ModifiedByID =@GRModifiedByID, Deleted =0, StatusID =@GRStatusID, FileID =0, UpdateInProgress = @GRUpdateInProgress
			WHERE (GeoRuleID=@GRGeoRuleID)
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 6
			END

			UPDATE GeoRuleReferencePoint
			SET Street=@Street, City=@City, StateID=@StateID, PostalCode=@PostalCode, CountryID=@CountryID, Longitude=@Longitude, Latitude=@Latitude
			WHERE (GeoRuleReferencePointID = @GRGeoRuleReferencePointID)
			IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRAN
				return 7
			END
		END
	COMMIT TRAN
	RETURN 0
END

GO
GRANT EXECUTE ON [GeoRuleSave] TO [db_dml]
GO
