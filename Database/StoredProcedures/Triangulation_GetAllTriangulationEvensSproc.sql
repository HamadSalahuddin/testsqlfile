USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[Triangulation_GetAllTriangulationEvensSproc]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[Triangulation_GetAllTriangulationEvensSproc]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   Triangulation_GetAllTriangulationEvensSproc.sql
 * Created On: Unknown
 * Created By: Asif
 * Task #:     
 * Purpose:    Get Triangulation events               
 *
 * Modified By: R.Cole - 02/18/2011: Changed the EventID to 219,
 *                Reformatted to meet code standard.
 *  NOTE: This sproc will be renamed to meet standard before it 
 *        gets moved to production.  spTPal_Evt_GetTriangulation
 *              
 *              Asif - 03/11/2011: Added EventID 220 to the 
 *                WHERE clause, removed text compare on 'Triangulation'
 * ******************************************************** */
CREATE PROCEDURE [dbo].[Triangulation_GetAllTriangulationEvensSproc] 	--spTPal_Evt_GetTriangulation
AS
BEGIN
	SET NOCOUNT ON;
	SELECT [EventPrimaryID],
	       [DeviceID],
	       [EventTime],
	       [EventDateTime],
	       [ReceivedTime],
	       [TrackerNumber],
		     [EventID],
		     [EventParameter],
		     [AlarmType],
		     [AlarmAssignmentStatusID],
		     [AlarmAssignmentStatusName],
		     [EventName],
		     [Longitude],
		     [Latitude],
		     [Address],
		     [OffenderID],
		     [NoteCount],
		     [AlarmID],
		     [GpsValid],
		     [GpsValidSatellites],
		     [GeoRule],
		     [SO],
		     [OPR],
		     [EventTypeGroupID],
		     [OfficerID],
		     [AgencyID],
		     [AcceptedDate],
		     [AcceptedBy],
		     [ActivateDate],
		     [DeactivateDate],
		     [EventQueueID],
		     [OffenderName],
		     [OffenderDeleted]
	FROM [rprtEventsBucket1]
	WHERE EventID IN (219,220) 
	  AND [Longitude] = 0 
	  AND [Latitude] = 0 
	  AND [GpsValidSatellites] = 0
END
GO

GRANT EXECUTE ON [dbo].[Triangulation_GetAllTriangulationEvensSproc] TO db_dml;
GO
