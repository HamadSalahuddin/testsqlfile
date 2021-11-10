/* **********************************************************
 * FileName:   FixBeaconAddress.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc.  
 * Task #:     SA       
 * Purpose:                   
 *
 * Modified By: R.Cole - 05/26/2010 : SA #984
 *                Cleaned up the query and added a condition
 *                where the query will only check events that 
 *                occurred in the last 24hrs.
 * ******************************************************** */
UPDATE eb1
  SET eb1.Address = addr.Street1 + ' ' + addr.City + ', ' + st.Abbreviation + ' ' + addr.ZipCode, 
      eb1.Latitude = gps.Latitude, 
      eb1.Longitude = gps.Longitude
  FROM TrackerPal.dbo.rprtEventsBucket1 eb1 WITH (NOLOCK)
    INNER JOIN Gateway.dbo.Events evt WITH (NOLOCK) ON evt.DeviceID = eb1.DeviceID 
      AND evt.EventTime = eb1.EventTime 
      AND evt.EventID = eb1.EventID
    INNER JOIN BeaconOffender WITH (NOLOCK) ON BeaconOffender.OffenderID = eb1.OffenderID
    INNER JOIN Beacon WITH (NOLOCK) ON Beacon.ID = BeaconOffender.BeaconID 
      AND Beacon.Identifier = evt.BeaconSerialNumber
    INNER JOIN Address addr WITH (NOLOCK) ON addr.ID = Beacon.AddressID
    INNER JOIN State st WITH (NOLOCK) ON st.StateID = addr.StateID
    --INNER JOIN EventType WITH (NOLOCK) ON EventType.EventTypeID = eb1.EventID
    INNER JOIN GpsLocation gps WITH (NOLOCK) ON gps.AddressID = addr.ID
  WHERE eb1.EventDateTime >= DATEADD(hour,-24,GETDATE())
    AND eb1.EventID IN (176,177,178,179,180,181,182,184,185,192,193,194,195)
    AND eb1.Address != addr.Street1 + ' ' + addr.City + ', ' + st.Abbreviation + ' ' + addr.ZipCode    
    
    
