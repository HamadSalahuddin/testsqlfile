USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[mTrackerAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[mTrackerAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   mTrackerAdd.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:		 N/A
 * Purpose:                   
 *
 * Modified By: S.Abassi - 02/11/2010: Added TrackerName Field
 *              R.Cole - 02/11/2010: Removed Deprecated Code,
 *              Added IF EXISTS and GRANT
 *              R.Cole - 01/04/2011: #1790 Added Part Number Field
 * ******************************************************** */
CREATE PROCEDURE [dbo].[mTrackerAdd] (
  @TrackerID       INT,
  @TrackerNumber   VARCHAR(32),
  @TrackerName     VARCHAR(32),
  @AgencyID        INT,
  @CreatedByID     INT,
  @IsDemo          BIT,
  @FirmwareVersion INT,
  @TrackerUniqueID INT = NULL OUTPUT
)
AS

DECLARE @PartNumber VARCHAR(24)
SET @PartNumber = (SELECT dp1.PropertyValue + '.' + dp2.PropertyValue
                   FROM Gateway.dbo.Devices gwDevices
                     INNER JOIN Gateway.dbo.DeviceProperties dp1 ON gwDevices.DeviceID = dp1.DeviceID
                     INNER JOIN Gateway.dbo.DeviceProperties dp2 on gwDevices.DeviceID = dp2.DeviceID
                   WHERE gwDevices.DeviceID = @TrackerID
                     AND dp1.PropertyID = '801A'
                     AND dp2.PropertyID = '801B'
                  )

INSERT INTO Tracker (
    TrackerID, 
    TrackerNumber, 
    AgencyID, 
    CreatedByID, 
    RmaID, 
    isDemo, 
    TrackerVersion, 
    TrackerName,
    PartNumber
  )
  VALUES (
    @TrackerID, 
    @TrackerNumber,
    @AgencyID, 
    @CreatedByID, 
    NULL, 
    @IsDemo, 
    @FirmwareVersion, 
    @TrackerName,
    @PartNumber
  )

SET @TrackerUniqueID = @@IDENTITY
GO

GRANT EXECUTE ON [dbo].[mTrackerAdd] TO db_dml;
GO