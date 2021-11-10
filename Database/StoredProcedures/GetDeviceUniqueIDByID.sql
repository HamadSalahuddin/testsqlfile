USE TrackerPal
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GetDeviceUniqueIDByID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetDeviceUniqueIDByID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------        
-- Author: SABBASI         
-- Dated: 10-Feb-2010        
-- Summary: Task #550        
-- ---------------------------------------------        
CREATE PROCEDURE GetDeviceUniqueIDByID (
  @deviceID bigint,
  @uniqueID bigint output
)        
AS 
BEGIN         
  SELECT @uniqueID = [UniqueID] 
  FROM Gateway.dbo.Devices        
  WHERE DeviceID = @deviceID             
END
GO

GRANT EXECUTE ON [dbo].[GetDeviceUniqueIDByID] TO db_dml;
GO