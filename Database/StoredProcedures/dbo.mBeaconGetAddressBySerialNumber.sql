USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mBeaconGetAddressBySerialNumber]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mBeaconGetAddressBySerialNumber]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   mBeaconGetAddressBySerialNumber.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:    Given Beacon information, return the address
 *             and Lat/Long of the Beacon.               
 *
 * Modified By: R.Cole - 11/05/2010: #1337 
 *                Checked and brought up to coding std.
 * ******************************************************** */
CREATE PROCEDURE [mBeaconGetAddressBySerialNumber] (
    @BeaconSerial NVARCHAR(50),
    @OffenderID INT,
    @Address VARCHAR(100) OUTPUT, 
    @Latitude FLOAT OUTPUT, 
    @Longitude FLOAT OUTPUT
)
AS 

SELECT @Address = addr.Street1 + ' ' + addr.City + ', ' + st.Abbreviation + ' ' + addr.ZipCode,
       @Longitude = gps.longitude,
       @Latitude = gps.latitude
FROM [Address] addr
  INNER JOIN Beacon ON Beacon.AddressID = addr.ID
  INNER JOIN GPSLocation gps ON gps.AddressID = addr.ID
  INNER JOIN [State] st ON st.StateID = addr.StateID
  INNER JOIN BeaconOffender bo ON bo.BeaconID = Beacon.ID
                               AND beacon.Identifier = @BeaconSerial 
                               AND bo.OffenderID = @OffenderID
GO

GRANT EXECUTE ON [mBeaconGetAddressBySerialNumber] TO [db_dml]
GO
