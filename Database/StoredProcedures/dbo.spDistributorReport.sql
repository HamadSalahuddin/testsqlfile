/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spDistributorReport]
	@value1 as nvarchar(max),
	@value2 as nvarchar(max) 
AS
BEGIN
	
SET NOCOUNT ON;
declare @tempSql as nvarchar(max)
set @tempSql = 'Select DISTINCT ' + @value1 + ' from'

declare @sql nvarchar(max)

set @sql = ' (SELECT DISTINCT ag.Agency as AgencyName,ag.City as AgencyCity, ag.PostalCode as AgencyPostalCode,agState.Abbreviation as AgencyState,dbo.Distributor.DistributorName,dbo.Distributor.TamID,dbo.[User].UserName AS TAMUserName,'+
' ofcr.AgencyID,ofcr.FirstName + '' '' + ofcr.LastName AS OfficerName,	o.FirstName AS OffenderFirstName,o.LastName AS OffenderLastName,dbo.OffenderTrackerActivation.OffenderID,'+
' convert(varchar,DATEADD(mi,dbo.fnGetUtcOffset(ag.AgencyID),dbo.OffenderTrackerActivation.ActivateDate),101) + '' '' + convert(varchar,DATEADD(mi,dbo.fnGetUtcOffset(ag.AgencyID),dbo.OffenderTrackerActivation.ActivateDate),108) as ActivateDate,'+
' convert(varchar,DATEADD(mi,dbo.fnGetUtcOffset(ag.AgencyID),dbo.OffenderTrackerActivation.DeActivateDate),101) + '' '' + convert(varchar,DATEADD(mi,dbo.fnGetUtcOffset(ag.AgencyID),dbo.OffenderTrackerActivation.DeActivateDate),108) as DeActivateDate,'+
' dbo.Tracker.TrackerID,dbo.DevicePropertiesView.HardwareVersion,dbo.DevicePropertiesView.IMSI,dbo.DevicePropertiesView.SerialNo,dbo.DevicePropertiesView.Manufacturer,dbo.DistributorEmployee.UserID as DistributorEmployeeUserID'+
' FROM dbo.Agency ag WITH(NOLOCK) '+
' LEFT JOIN dbo.State agState WITH(NOLOCK) ON ag.StateID = agState.StateID'+
' LEFT JOIN dbo.Distributor WITH(NOLOCK) ON dbo.Distributor.DistributorID = ag.DistributorID'+
' LEFT JOIN dbo.DistributorEmployee WITH(NOLOCK) on 	dbo.DistributorEmployee.DistributorID = ag.DistributorID'+
' LEFT JOIN dbo.[User] WITH(NOLOCK) ON dbo.Distributor.TamID = dbo.[User].UserID'+
' LEFT JOIN dbo.Officer ofcr WITH(NOLOCK) ON ofcr.AgencyID = ag.AgencyID'+
' LEFT JOIN dbo.Offender_Officer WITH(NOLOCK) ON dbo.Offender_Officer.OfficerID = ofcr.OfficerID'+
' LEFT JOIN dbo.Offender o WITH(NOLOCK) ON dbo.Offender_Officer.OffenderID = o.OffenderID'+
' LEFT JOIN dbo.OffenderTrackerActivation'+ 
' WITH(NOLOCK) ON dbo.OffenderTrackerActivation.OffenderID = o.OffenderID'+
' AND dbo.OffenderTrackerActivation.ActivateDate = (SELECT MAX(ActivateDate) FROM OffenderTrackerActivation OTA WITH(NOLOCK) WHERE OTA.OffenderID = o.OffenderID)'+
' LEFT JOIN dbo.Tracker WITH(NOLOCK) ON dbo.OffenderTrackerActivation.TrackerID = dbo.Tracker.TrackerID'+
' LEFT JOIN dbo.DevicePropertiesView WITH(NOLOCK) ON dbo.Tracker.TrackerID = dbo.DevicePropertiesView.DeviceID'

if(@value2 <> '')
begin
set @sql = @sql + ' where ' + @value2
end

set @sql = @sql + ') as temp'
set @tempSql = @tempSql + @sql

exec (@tempSql)
	
END

 
GO
GRANT VIEW DEFINITION ON [spDistributorReport] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [spDistributorReport] TO [db_dml]
GO
