USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetAllByProtocolSetID]    Script Date: 11/09/2013 15:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPal_Ofn_GetAllByProtocolSetID.sql
 * Created On: 11/06/2013
 * Created By: Sohail Khaliq
 * Task #:     
 * Purpose:    Return results for the AlarmProtocolSet Associated with offenders 
 *
 * Modified By: Sohail Khaliq - 11/06/2013: Revised to meet standard
 *        added per #2993
  * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetAllByProtocolSetID]

	@AlarmProtocolSetID INT

AS

		SELECT	aps.AlarmProtocolSetID, aps.AlarmProtocolSetName,o.FirstName,o.LastName,o.OffenderID
		FROM	AlarmProtocolSet aps INNER JOIN Offender_AlarmProtocolSet oaps ON aps.AlarmProtocolSetID=oaps.AlarmProtocolSetID 
		INNER JOIN Offender o ON o.OffenderID=oaps.OffenderID
		WHERE	(oaps.Deleted=0 OR oaps.Deleted is null) AND (o.Deleted=0 OR o.Deleted is null) AND oaps.AlarmProtocolSetID=@AlarmProtocolSetID

		ORDER BY AlarmProtocolSetName
		