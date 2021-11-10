USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_NonCom]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_NonCom]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_NonCom.sql
 * Created On: 5/3/2012
 * Created By: Alan Harris, ported to SP by R.Cole
 * Task #:     1396
 * Purpose:    Populate a Device NonCom report for use during 
 *             cellular carrier service outages.
 *
 * Modified By: R.Cole - 8/9/2012: Per #3369 added some fields,
 *              revised order of results, added a check to 
 *              ensure we were dealing with most current Tracker
 *              R.Cole - 8/13/2012: Added DeactivationDate
 *              R.Cole - 05/28/2013: Added Offender City and State
 *              per #4084.
 *              R.Cole - 1/14/2014: Added LastValid time field.
 *              per #3632
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_NonCom] (
  @HoursBack INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* *** DEV *** */
--DECLARE @HoursBack INT
--SET @HoursBack = 12

DECLARE @UtcOffset INT
SET @UtcOffset = dbo.fnGetMSTOffset(8)  -- MountainTime
   
-- // Main Query // --
SELECT dp5.PropertyValue as [Device],
       d.DeviceID AS [DeviceID],
       (CASE WHEN nop.[name] LIKE 'T-Mobile' THEN LEFT(dp4.PropertyValue,19)
		         WHEN nop.[name] LIKE 'Union Telephone' THEN LEFT(dp4.PropertyValue,19)
			       ELSE dp4.PropertyValue 
       END) AS [ICCID],
       dp3.PropertyValue AS IMSI,
       RIGHT(d.MostLikelyPhoneNumber,10) as [Phone],
       (CASE WHEN d.LastEventTime !=0 THEN CONVERT(CHAR(25),DATEADD(MI,@UtcOffset,Trackerpal.dbo.ConvertLongToDate(d.LastEventTime)),121)
		         ELSE 'N/A' 
       END) AS [LastReported_MT],
       (CASE WHEN d.LastValidTime !=0 THEN CONVERT(CHAR(25),DATEADD(MI,@UtcOffset,TrackerPal.dbo.ConvertLongToDate(d.LastValidTime)),121)
             ELSE 'N/A'
        END) AS [LastValid_MT],
       (CASE WHEN nop.[name] IS NULL THEN nopintl.[name] 
             ELSE (CASE	WHEN nop.[name] = 'AT&T' THEN (CASE WHEN dp4.PropertyValue >= 89014104212400000000 THEN 'AT&T - EOD' ELSE 'AT&T - Premier' END)
		                    ELSE nop.[name] 
                  END) 
       END) AS [Carrier],
       State.[State] AS [State],
       Agency.Agency AS [Agency],
       Offender.FirstName + ' ' + Offender.LastName AS [Offender],
       Offender.HomeCity AS [OffenderCity],
       st.State AS [OffenderState],
       CONVERT(CHAR(25),DATEADD(MI, @UtcOffset, ota.ActivateDate),121) AS [ActivateDate_MT],
       CONVERT(CHAR(25),DATEADD(MI, @UtcOffset, ota.DeactivateDate),121) AS [DeactivateDate_MT],
       dp7.PropertyValue AS [IMEI],
       Gateway.dbo.HexToBigInt(CONVERT(NVARCHAR,dp9.PropertyValue)) AS [Tracking],
       dp2.PropertyValue AS [APN],
       dp6.PropertyValue AS [APN2],
       Gateway.dbo.HexToSmallInt(dp8.PropertyValue) AS [Firmware]
FROM Gateway.dbo.Devices d
	INNER JOIN TrackerPal.dbo.Tracker ON d.DeviceID = Tracker.TrackerID
	INNER JOIN Trackerpal.dbo.OffenderTrackerActivation ota ON Tracker.TrackerID = ota.TrackerID
	INNER JOIN Gateway.dbo.DeviceProperties dp2 ON d.DeviceID = dp2.DeviceID AND dp2.PropertyID = '8210'      -- APN
	INNER JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'      -- IMSI
	INNER JOIN Gateway.dbo.DeviceProperties dp4 ON d.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'      -- ICCID
	LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp5 ON d.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8012' -- S/N
  INNER JOIN Gateway.dbo.DeviceProperties dp6 ON d.DeviceID = dp6.DeviceID AND dp6.PropertyID = '8211'      -- Secondary APN
  INNER JOIN Gateway.dbo.DeviceProperties dp7 ON d.DeviceID = dp7.DeviceID AND dp7.PropertyID = '8205'      -- IMEI
  INNER JOIN Gateway.dbo.DeviceProperties dp8 ON d.DeviceID = dp8.DeviceID AND dp8.PropertyID = '8016'      -- Firmware Rev.
	INNER JOIN Gateway.dbo.DeviceProperties dp9 ON d.DeviceID = dp9.DeviceID AND dp9.PropertyID = '8020'      -- Tracking Interval
	LEFT OUTER JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC + nop.MNC = LEFT(dp3.PropertyValue,6)         -- Carriers
	LEFT OUTER JOIN Gateway.dbo.NetworkOperators nopintl ON nopintl.MCC + nopintl.MNC = LEFT(dp3.PropertyValue,5)
	INNER JOIN TrackerPal.dbo.Offender ON ota.OffenderID = Offender.OffenderID
	INNER JOIN TrackerPal.dbo.Agency ON Offender.AgencyID = Agency.AgencyID
	INNER JOIN TrackerPal.dbo.State ON Agency.StateID = State.StateID
  LEFT OUTER JOIN TrackerPal.dbo.State st ON Offender.HomeStateOrProvinceID = st.StateID
WHERE ota.DeactivateDate IS NULL
	AND d.TimeoutCount > 0
	AND Tracker.Deleted = 0
	AND Tracker.AgencyID <> 1
	AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)  -- // This is not applicable for Int'l servers // --
  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker WHERE TrackerID = ota.TrackerID)
	AND DATEDIFF(HOUR, (CASE WHEN d.LastEventTime !=0 THEN CONVERT(CHAR(25),Trackerpal.dbo.ConvertLongToDate(d.LastEventTime),121) ELSE 'N/A' END), GETDATE()) <= @HoursBack
ORDER BY (CASE WHEN d.LastEventTime !=0 THEN CONVERT(CHAR(25),Trackerpal.dbo.ConvertLongToDate(d.LastEventTime),121) ELSE 'N/A' END) DESC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_NonCom] TO db_dml;
GO