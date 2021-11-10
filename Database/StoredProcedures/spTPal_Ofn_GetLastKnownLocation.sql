USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetLastKnownLocation]    Script Date: 11/09/2013 14:58:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetLastKnownLocation.sql
 * Created On: 08/21/2013
 * Created By: SABBASI
 * Task #:     #4348
 * Purpose:    Return last known location of an offender               
 * Modified By: Name - DateTime
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_GetLastKnownLocation] 
	@OffenderID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  evt1.EventDateTime, ISNULL(evt1.[Address],'') "Address",  evt1.Latitude, evt1.Longitude
		  FROM rprtEventsBucket1 evt1
	INNER JOIN ( SELECT OffenderID, max(EventDateTime) AS "EventDateTime" FROM rprtEventsBucket1 
				WHERE ( Latitude <> 0 AND Longitude <> 0 ) Group BY OffenderID )evt2
	ON evt1.OffenderID = evt2.OffenderID AND evt1.EventDateTime = evt2.EventDateTime
	AND evt1.OffenderID = @OffenderID

END
