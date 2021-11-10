USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_TMobileSims]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_TMobileSims]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **************************************************************
 * FileName:   spTPal_Rpt_TMobileSims.sql
 * Created On: Unknown
 * Created By: S.Fieber
 * Task #:     3654
 * Purpose:    Display TMobile devices
 *
 * Modified By: R.Cole - 09/12/2012: Rewritten to improve 
 *              performance, meets std's and converted to sproc.
 * ************************************************************ */
CREATE PROCEDURE [dbo].[spTPal_Rpt_TMobileSims] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Main Query // --
SELECT DISTINCT (CASE WHEN Agency.Agency LIKE 'CPI%' OR st.StateID IN (8,9,20,21,22,30,31,33,39,40,46,47,49) THEN 'Travis'
                      WHEN Agency.Agency LIKE 'JCS%' OR st.StateID IN (2,5,8,9,10,11,14,15,16,18,19,23,24,25,26,34,35,36,41,42,43,50) THEN 'Kelly'
                      WHEN Agency.Agency LIKE 'MMS%' OR st.StateID IN (3,4,6,7,12,13,17,27,28,29,32,37,38,44,45,48,51) THEN 'Scott'
                      ELSE 'Chris Voros'
                END) AS 'ADM',
       Agency.Agency AS 'Agency',
       st.Abbreviation AS 'State',
       (CASE WHEN osb.Active = 1 THEN Offender.FirstName + ' ' + Offender.LastName ELSE 'Unassigned' END) AS 'Offender',
       (CASE WHEN dp5.PropertyValue LIKE '0%'		    THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE '2%'		    THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE '31%'		  THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE '34[A-Z]%' THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE '343%'		  THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE 'PR3%'		  THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE '344%'		  THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE 'A001%'		THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE 'A000%'		THEN 'ReliAlert'
		         WHEN dp5.PropertyValue LIKE 'P100%'		THEN 'XC'
		         WHEN dp5.PropertyValue LIKE 'A002%'		THEN 'XC'
		         WHEN dp5.PropertyValue LIKE 'A003%'		THEN 'XC'
		         ELSE 'ReliAlert' 
       END) AS Model,
       (CASE WHEN dp5.PropertyValue LIKE '0%' THEN Devices.Name
			       WHEN dp5.PropertyValue LIKE '' THEN Tracker.TrackerName
			       ELSE dp5.propertyValue 
       END) AS 'Device',
       (CASE WHEN osb.Active = 1 THEN 'Active'
			       WHEN tra.RmaID IS NOT NULL THEN 'RMA'
			       ELSE 'Idle' 
       END) AS 'Status',
       (CASE WHEN nop.[name] IS NULL THEN nopintl.[name] 
             ELSE (CASE	WHEN nop.[name] = 'AT&T' THEN (CASE WHEN dp4.PropertyValue >= 89014104212400000000 THEN 'AT&T - EOD' ELSE 'AT&T - Premier' END)
		                    ELSE nop.[name] 
                   END) 
       END) AS 'Carrier',
       (CASE WHEN nop.[name] LIKE 'T-Mobile' THEN LEFT(dp4.PropertyValue,19)
			       WHEN nop.[name] LIKE 'Union Telephone' THEN LEFT(dp4.PropertyValue,19)
			       ELSE dp4.PropertyValue 
       END) AS 'ICCID',
       dp3.PropertyValue AS 'IMSI',
       dp1.PropertyValue AS 'IMEI'
FROM Gateway.dbo.Devices Devices
  LEFT OUTER JOIN TrackerPal.dbo.Tracker ON Devices.DeviceID = Tracker.TrackerID
  LEFT OUTER JOIN (SELECT TrackerID, MAX(OffenderServiceID) AS ActivationID FROM Trackerpal.dbo.OffenderServiceBilling GROUP BY TrackerID) AS osb1 ON osb1.TrackerID = Devices.DeviceID
  LEFT OUTER JOIN Trackerpal.dbo.Agency ON Tracker.AgencyID = Agency.AgencyID
  LEFT OUTER JOIN Trackerpal.dbo.TrackerRMA tra ON tra.TrackerID = Tracker.TrackerID AND tra.RemovedDate IS NULL
  LEFT OUTER JOIN Trackerpal.dbo.State st ON st.StateID = Agency.StateID
  LEFT OUTER JOIN Trackerpal.dbo.OffenderServiceBilling osb ON osb.offenderServiceID = osb1.ActivationID  
  LEFT OUTER JOIN Trackerpal.dbo.Offender ON osb.Offenderid = Offender.OffenderID
  INNER JOIN Gateway.dbo.DeviceProperties dp1 ON Devices.DeviceID = dp1.DeviceID AND dp1.PropertyID = '8205'            -- IMEI
  INNER JOIN Gateway.dbo.DeviceProperties dp3 ON Devices.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'            -- IMSI
  INNER JOIN Gateway.dbo.DeviceProperties dp4 ON Devices.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'            -- ICCID
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp5 ON Devices.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8012'       -- S/N
  LEFT OUTER JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC + nop.MNC = LEFT(dp3.PropertyValue,6)
  LEFT OUTER JOIN Gateway.dbo.NetworkOperators nopintl ON nopintl.MCC + nopintl.MNC = LEFT(dp3.PropertyValue,5)
WHERE Tracker.Deleted = 0
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)                                         -- Excludes '1 SA%' agencies as well
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker t WHERE t.TrackerID = Tracker.TrackerID)
  AND nop.[name] LIKE 'T-Mobile'
ORDER BY Agency.agency
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_TMobileSims] TO db_dml;
GO