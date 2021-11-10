USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[mAlarmProtocolSetUpdate]    Script Date: 11/09/2013 15:25:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   mAlarmProtocolSetUpdate.sql
 * Created On: UnKnown
 * Created By: UnKnown
 * Task #:     
 * Purpose:    Updates AlarmProtocolSet Information
 *
 * Modified By: Sohail Khaliq - 11/06/2013: Revised to meet standard
 *        added per #2993
  * ******************************************************** */

ALTER PROCEDURE [dbo].[mAlarmProtocolSetUpdate]

	@AlarmProtocolSetID		INT,
	@AlarmProtocolSetName	NVARCHAR(50),
	@ModifiedByID			INT,
	@Deleted				BIT=0
AS
IF(@Deleted=0)
BEGIN
	UPDATE	AlarmProtocolSet
	SET		AlarmProtocolSetName = @AlarmProtocolSetName,
			ModifiedByID = @ModifiedByID,
			ModifiedDate = GETUTCDATE()
	WHERE	AlarmProtocolSetID = @AlarmProtocolSetID
END
ELSE
BEGIN
	UPDATE	AlarmProtocolSet
	SET		Deleted = @Deleted,
			DeletedByID = @ModifiedByID,
			DeletedDate = GETUTCDATE()
			
	WHERE	AlarmProtocolSetID = @AlarmProtocolSetID
END