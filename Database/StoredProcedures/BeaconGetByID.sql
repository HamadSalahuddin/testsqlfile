USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BeaconGetByID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BeaconGetByID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   BeaconGetByID.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:                   
 *
 * Modified By: R.Cole - 11/16/2010 - #1613 Brought up to 
 *                standard, added CountryID.
 * ******************************************************** */
CREATE PROCEDURE [BeaconGetByID] (
  @BeaconID INT
)
AS
SET NOCOUNT ON;
SELECT Beacon.BeaconName,
       Beacon.Identifier,
       Beacon.AddressID,
       bo.OffenderID,
       obt.BeaconThresholdID,
       adr.Street1,
       adr.Street2,
       adr.ZipCode,
       adr.City,
       adr.StateID,
       adr.CountryID,
       gps.Longitude,
       gps.Latitude       
FROM Beacon 
  INNER JOIN BeaconOffender bo ON Beacon.ID = bo.BeaconID 
	LEFT OUTER JOIN OffenderBeaconThreshold obt ON bo.OffenderID = obt.offenderID 
	INNER JOIN [Address] adr ON adr.ID = Beacon.AddressID 	
  INNER JOIN GPSLocation gps ON gps.AddressID = adr.ID
WHERE Beacon.ID = @BeaconID
GO

GRANT EXECUTE ON [BeaconGetByID] TO [db_dml]
GO
