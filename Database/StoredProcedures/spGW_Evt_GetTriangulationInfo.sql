USE [Gateway]															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spGW_Evt_GetTriangulationInfo]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spGW_Evt_GetTriangulationInfo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spGW_Evt_GetTriangulationInfo.sql
 * Created On: 08-Sep-2011         
 * Created By: SABBASI  
 * Task #:          
 * Purpose:    Get Street Address and Device UniqueID for Triangulation process               
 *
 * Modified By: R.Cole - 9/9/2011: Added IF EXISTS DROP and
 *                GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spGW_Evt_GetTriangulationInfo] (
    @EventID INT,
	  @EventTime BIGINT,
	  @DeviceID INT,
	  @EventParameter INT
)
AS
BEGIN
	SET NOCOUNT ON;

  SELECT evt.StreetAddress,
         (SELECT UniqueID FROM gateway.dbo.Devices devices WHERE devices.DeviceID = @DeviceID AND devices.Deleted = 0) AS 'DeviceUniqueID'
   FROM gateway.dbo.Events evt
   WHERE evt.DeviceID = @DeviceID
     AND evt.EventTime = @EventTime	
     AND evt.EventID = @EventID 
     AND evt.EventParameter = @EventParameter
END
GO

GRANT EXECUTE ON [dbo].[spGW_Evt_GetTriangulationInfo] TO db_dml;
GO