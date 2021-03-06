USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[Triangulation_UpdateLatANDLog]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[Triangulation_UpdateLatANDLog]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   Triangulation_UpdateLatANDLog.sql
 * Created On: Unknown
 * Created By: Asif
 * Task #:     #1844
 * Purpose:    Updates the Lat/Long for Triangulation events              
 *
 * Modified By: R.Cole - 02/18/2011: slight reformat for std,
 *      NOTE: Sproc will be renamed before it goes to production
 *            spTPal_Evt_UpdateTriangulationLatLong
 * ******************************************************** */
CREATE PROCEDURE [dbo].[Triangulation_UpdateLatANDLog] (   --spTPal_Evt_UpdateTriangulationLatLong
	  @Longitude float,
    @Latitude float,   
    @DeviceID bigint,
    @EventTime bigint,
    @EventID bigint,
    @EventParameter bigint
)   
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE [rprtEventsBucket1]
    SET [Longitude] = @Longitude,
        [Latitude] = @Latitude
	  WHERE [DeviceID] = @DeviceID 
	    AND [EventTime] = @EventTime 
	    AND [EventID] =  @EventID 
	    AND [EventParameter] = @EventParameter
	    
    IF @@ERROR = 0 
      BEGIN
        UPDATE [Gateway].[dbo].[Events]
		      SET [StreetAddress] = ''
		      WHERE	[DeviceID] = @DeviceID 
		        AND [EventTime] = @EventTime 
		        AND [EventID] =  @EventID 
		        AND [EventParameter] = @EventParameter
      END
        
        
    IF @@ERROR = 0
		  SELECT 'SUCCESS'
	  ELSE
		  SELECT 'FAIL'
END
GO

GRANT EXECUTE ON [dbo].[Triangulation_UpdateLatANDLog] TO db_dml;
GO
