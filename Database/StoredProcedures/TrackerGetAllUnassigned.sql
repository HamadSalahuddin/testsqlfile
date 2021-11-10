USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[TrackerGetAllUnassigned]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrackerGetAllUnassigned]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ************************************************************
 * FileName:   TrackerGetAllUnassigned.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc
 * Task #:		 <Redmine #>      
 * Purpose:    Get a list of all unassigned OTD's               
 *
 * Modified By: S.Abassi - 02/11/2010: Added TrackerName Field
 *              R.Cole - 02/11/2010: Remove Deprecated Code 
 *              R.Cole - 05/14/2010: #910 Modified TrackerName to 
 *                pull from the Gateway DeviceProperties table.
 *                Reversed the concatenation of S/N and UniqueID
 *              R.Cole - 05/24/2010: #972 Added condition to 
 *                ensure we do not return duplicate SN's due
 *                modem swaps. 
 *              R.Cole - 10/07/2010: #964 Added condition to
 *                exclude all devices except those with 
 *                A0xxxxx S/N's.
 * *********************************************************** */  

CREATE PROCEDURE [dbo].[TrackerGetAllUnassigned] (
  @GatewayPort VARCHAR(10),  
  @GatewayIP   VARCHAR(20)
)
AS

-- // Create a tmp table to hold our list of DeviceID's // --  
SELECT DeviceID 
INTO #tmpDevices  
FROM Gateway.dbo.DeviceProperties  
WHERE PropertyValue IN (@GatewayIP, @GatewayPort) 
  AND PropertyID IN ('8410', '8411')  
GROUP BY DeviceID  
HAVING MAX(CASE WHEN PropertyID = '8410' THEN PropertyValue ELSE '' END) <> '';  

-- // Index the tmp table // --
DECLARE @sql VARCHAR(MAX)  
SET @sql = 'CREATE UNIQUE CLUSTERED INDEX IX_' + REPLACE(CONVERT(VARCHAR(100),(RAND() * 1000000)),'.','0') + ' ON #tmpDevices(DeviceID)'  
EXEC(@sql)  

-- // Main Query // --  
SELECT gwDevices.DeviceID AS 'TrackerID',
       dp.PropertyValue + ' - ' + CAST(UniqueID AS VARCHAR(50)) AS 'TrackerName',
       UniqueID AS 'TrackerNumber'  
FROM Gateway.dbo.Devices gwDevices 
  INNER JOIN #tmpDevices tDevices ON tDevices.DeviceID = gwDevices.DeviceID 
  INNER JOIN Gateway.dbo.DeviceProperties dp ON gwDevices.DeviceID = dp.DeviceID  
WHERE gwDevices.DeviceID NOT IN (SELECT TrackerID FROM Tracker WHERE Deleted = 0)  
  AND gwDevices.Deleted = 0
  AND dp.PropertyID = '8012'
  AND dp.PropertyValue LIKE 'A0%'  
  AND gwDevices.LastEventTime = (SELECT MAX(LastEventTime) 
                                 FROM Gateway.dbo.Devices iDevices 
                                   INNER JOIN Gateway.dbo.DeviceProperties dp1 ON iDevices.DeviceID = dp1.DeviceID
                                 WHERE dp.PropertyValue = dp1.PropertyValue     -- Tie inner and outer queries together by SerialNumber
                                   and dp1.PropertyID = '8012') 
ORDER BY dp.PropertyValue
  
DROP TABLE #tmpDevices
GO

GRANT EXECUTE ON [dbo].[TrackerGetAllUnassigned] TO db_dml;
GO