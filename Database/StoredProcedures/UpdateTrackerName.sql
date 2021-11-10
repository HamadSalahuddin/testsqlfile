USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[UpdateTrackerName]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[UpdateTrackerName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   UpdateTrackerName.sql
 * Created On: 02/11/2010         
 * Created By: S.Abbasi
 * Task #:     #550
 * Purpose:    Populate the TrackerName Field               
 *
 * Modified By: R.Cole - 05/14/2010: #910
 *              Changed SP to get the Serial Number from the
 *              Gateway DeviceProperties table. We will update
 *              only the last record created for each device.
 * ********************************************************  */
CREATE PROCEDURE [dbo].[UpdateTrackerName]
AS
BEGIN
  UPDATE Tracker
    SET Tracker.TrackerName = dp.PropertyValue 
  FROM Tracker
    INNER JOIN Gateway.dbo.Devices Devices ON Devices.DeviceID = Tracker.TrackerID 
    INNER JOIN Gateway.dbo.DeviceProperties dp ON Devices.DeviceID = dp.DeviceID
  WHERE Tracker.TrackerID = Devices.DeviceID 
    AND dp.PropertyID = '8012'
    AND Tracker.CreatedDate = (SELECT MAX(CreatedDate) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID) 
END
GO

GRANT EXECUTE ON [dbo].[UpdateTrackerName] TO db_dml;
GO