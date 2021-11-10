USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[AlarmProtocolSetGetByAgencyIDOfficerIDOffenderID]    Script Date: 11/09/2013 15:14:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   AlarmProtocolSetGetByAgencyIDOfficerIDOffenderID.sql
 * Created On: Unknown
 * Created By: Unknown
 * Task #:     
 * Purpose:    Return results for the offender search function               
 *
 * Modified By: Sohail Khaliq - 11/06/2013: Revised to meet standard
 *        added per #2993
  * ******************************************************** */
ALTER PROCEDURE [dbo].[AlarmProtocolSetGetByAgencyIDOfficerIDOffenderID]

	@AgencyID	INT,
	@OfficerID	INT,
	@OffenderID INT

AS


IF (@OfficerID > 0)

	BEGIN
		SELECT	AlarmProtocolSetID, AlarmProtocolSetName
		FROM	AlarmProtocolSet
		WHERE	Deleted=0 OR Deleted is NULL AND ((OfficerID = @OfficerID)
				OR
				(OfficerID = 0 AND AgencyID = @AgencyID AND @AgencyID > 0 and OffenderID=0) 
				OR	(OffenderID = @OffenderID AND @OffenderID > 0 and OfficerID = 0 ))

		ORDER BY AlarmProtocolSetName
	END
ELSE
	BEGIN
		SELECT	AlarmProtocolSetID, AlarmProtocolSetName,deleted
		FROM	AlarmProtocolSet
		WHERE	Deleted=0 OR Deleted is NULL AND ((AgencyID = @AgencyID AND @AgencyID > 0 and OfficerId= 0 and OffenderID=0)OR
                (OffenderID=@OffenderID and OfficerID= 0 and AgencyID = @AgencyID)OR
				(OfficerID=@OfficerID and OffenderID = 0 and AgencyID = @AgencyID))

		ORDER BY AlarmProtocolSetName

END