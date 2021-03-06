USE TrackerPal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Evt_UpdateTriangulationLatLong]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Evt_UpdateTriangulationLatLong]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   Triangulation_UpdateLatANDLog.sql
 * Created On: 22nd March 2011
 * Created By: Asif
 * Task #:     #1844
 * Purpose:    Updates the Lat/Long for Triangulation events              
 *
 * Modified By: R.Cole - 02/18/2011: slight reformat for std.
 *      NOTE: Sproc will be renamed before it goes to production
 *            spTPal_Evt_UpdateTriangulationLatLong
 *              Asif - 03/22/2011: Renamed sproc.
 *              Asif - 5/17/2011: Added code to insert into
 *                TriangulationEvents table.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Evt_UpdateTriangulationLatLong] (   
	  @Longitude FLOAT,
    @Latitude FLOAT,   
    @RadiusOfConfidence NVARCHAR(50),
    @DeviceID BIGINT,
    @EventTime BIGINT,
    @EventID BIGINT,
    @EventParameter BIGINT
)   
AS
BEGIN
	UPDATE [rprtEventsBucket1]
    SET [Longitude] = @Longitude,
        [Latitude] = @Latitude,
        [GeoRule] = @RadiusOfConfidence,
        [GpsValid] = 1
        
	  WHERE [DeviceID] = @DeviceID 
	    AND [EventTime] = @EventTime 
	    AND [EventID] =  @EventID 
	    AND [EventParameter] = @EventParameter
	    
	IF @@ERROR = 0
	  BEGIN
	    INSERT INTO [Gateway].[dbo].[TriangulationEvents] (
        [DeviceID],
        [EventTime],
        [EventID],
        [EventParameter],
        [Latitude],
        [Longitude],
        [RadiusOfConfidence]
      )
      VALUES (
        @DeviceID,
        @EventTime,
        @EventID,
        @EventParameter,
        @Latitude,
        @Longitude,
        @RadiusOfConfidence
      )           
  
	    SELECT 'SUCCESS'
	  END
	ELSE
	  SELECT 'FAIL'
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Evt_UpdateTriangulationLatLong] TO db_dml;
GO

