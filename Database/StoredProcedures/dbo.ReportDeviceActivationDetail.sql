/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportDeviceActivationDetail]
        @Date           DateTime,
        @TimezoneOffset int

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
DECLARE
        @DayBegin DateTime, @DayEnd DateTime, @DaylightOffset int

SET @TimezoneOffset=-@TimezoneOffset
SET @DayBegin = DATEADD( minute, @TimezoneOffset, @Date )
SET @DayEnd = DATEADD( day, 1, @DayBegin )

--IF @Date >= (SELECT [Start] FROM DaylightSaving WHERE [Year] = YEAR(@Date))
--AND @Date < (SELECT [End] FROM DaylightSaving WHERE [Year] = YEAR(@Date))
--BEGIN
--        SET @DaylightOffset = 60
--        SET @DayBegin = @DayBegin + @DaylightOffset
--END
--
--IF DATEPART(dayofyear, @DayBegin) = DATEPART( dayofyear, (SELECT [Start] FROM DaylightSaving WHERE [Year] = YEAR(@DayBegin)) )
--BEGIN
--        SET @DaylightOffset = @DaylightOffset + 60
--        SET @DayEnd = @DayEnd + @DaylightOffset
--END
--
--IF DATEPART(dayofyear, @DayBegin) = DATEPART( dayofyear, (SELECT [End] FROM DaylightSaving WHERE [Year] = YEAR(@DayBegin)) )
--BEGIN
--        SET @DaylightOffset = @DaylightOffset - 60
--        SET @DayEnd = @DayEnd + @DaylightOffset
--END

SELECT ota.TrackerID
          ,d.[Name] 
      ,a.SFDCAccount AS 'SFDCACCT#'
		,REPLACE( a.Agency, ',', ';' ) AS 'Agency'
      ,DATEADD( minute, -@TimezoneOffset, ota.ActivateDate ) AS 'ActivateDate'
          ,o.FirstName + ' ' + o.LastName AS 'Offender'
      ,u.UserName
      ,Convert(varchar(20),dp4.Propertyvalue) AS 'ICCID'
      ,nop.[name] AS 'SimProvider'
  FROM OffenderTrackerActivation ota
LEFT JOIN Offender o ON ota.OffenderID = o.OffenderID
LEFT JOIN Agency a ON a.AgencyID = o.AgencyID
LEFT JOIN [User] u ON u.UserID = ota.ModifiedByID
LEFT JOIN Gateway.dbo.Devices d ON d.DeviceID = ota.TrackerID
JOIN Gateway.dbo.DeviceProperties dp3 ON d.DeviceID = dp3.DeviceID AND dp3.PropertyID = '8202'
LEFT JOIN Gateway.dbo.NetworkOperators nop ON nop.MCC+nop.MNC = LEFT(dp3.Propertyvalue,6)
JOIN Gateway.dbo.DeviceProperties dp4 ON d.DeviceID = dp4.DeviceID AND dp4.PropertyID = '8204'


-- Change date range to reflect day before current.

WHERE ota.ActivateDate >= @DayBegin AND ota.ActivateDate < @DayEnd
ORDER BY a.Agency, ota.TrackerID


GO
GRANT EXECUTE ON [ReportDeviceActivationDetail] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportDeviceActivationDetail] TO [db_object_def_viewers]
GO