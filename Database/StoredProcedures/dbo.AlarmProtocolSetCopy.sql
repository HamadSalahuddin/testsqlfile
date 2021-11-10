/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AlarmProtocolSetCopy]

	@AlarmProtocolSetID			INT OUTPUT,
	@AlarmProtocolSetIDSource	INT,
	@AlarmProtocolSetName		NVARCHAR(50),
	@AlarmProtocolSetTypeID		INT,
	@AgencyID					INT,
	@OfficerID					INT,
	@OffenderID					INT,
	@CreatedByID				INT

AS
	
	-- Add New AlarmProtocolSet
	INSERT INTO AlarmProtocolSet
	(AlarmProtocolSetName, AlarmProtocolSetTypeID,AgencyID, OfficerID, OffenderID, 
	 CreatedByID)
	VALUES
	(@AlarmProtocolSetName, @AlarmProtocolSetTypeID, @AgencyID, @OfficerID, @OffenderID, 
	 @CreatedByID)

	SET @AlarmProtocolSetID = @@IDENTITY

	-- Copy AlarmProtocolAction records (if any) from source
	INSERT INTO AlarmProtocolAction
	(AlarmProtocolSetID, AlarmProtocolEventID, [Type], Priority,
	 [From], [To], [Action], Recipient, ContactInfo, Retry, Note,
	 CreatedByID)
	(SELECT	@AlarmProtocolSetID, AlarmProtocolEventID, [Type], Priority,
	 [From], [To], [Action], Recipient, ContactInfo, Retry, Note,
	 @CreatedByID
	 FROM	AlarmProtocolAction
	 WHERE	AlarmProtocolSetID = @AlarmProtocolSetIDSource)
GO
GRANT EXECUTE ON [AlarmProtocolSetCopy] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [AlarmProtocolSetCopy] TO [db_object_def_viewers]
GO