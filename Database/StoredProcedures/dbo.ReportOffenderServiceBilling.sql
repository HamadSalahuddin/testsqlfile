USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[ReportOffenderServiceBilling]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReportOffenderServiceBilling]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   ReportOffenderServiceBilling.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:           
 * Purpose:    Returns Billing information for importing in
 *             to the Billing database.
 *
 * Modified By: R.Cole - 02/28/2011: Revised to cover the 
 *                new service offerings.
 * ******************************************************** */
CREATE PROCEDURE [ReportOffenderServiceBilling]
    @StartDate DATETIME,
    @EndDate DATETIME
AS

DECLARE @Timezoneoffset INT
SET @Timezoneoffset = dbo.fnGetMSTOffset(8)

-- // Main Query // --
SELECT 
    Agency.Agencyid,
    Agency.Agency,
    Officer.FirstName + ' ' + Officer.LastName AS OfficerName,
    Offender.Firstname + ' ' + Offender.Lastname AS OffenderName,
    gwDeviceProperties.PropertyValue AS 'Device Serial',
    DATEADD(mi,@Timezoneoffset, osb.StartDate) As 'Active Date',
    DATEADD(mi,@Timezoneoffset, osb.EndDate) As 'Deactive Date',
    [dbo].[fn_TotalDays](@StartDate,@EndDate,DATEADD(mi,@Timezoneoffset,osb.StartDate),DATEADD(mi,@Timezoneoffset,osb.EndDate),osb.Offenderid) AS ActiveDays,
    (CASE Services.ServiceName 
        WHEN 'Active' THEN 'Intervention Active'
        WHEN 'Passive' THEN 'Passive'
        WHEN 'Passive Plus' THEN 'Standard Active'
        WHEN 'EArrest' THEN 'eArrest'
        ELSE Services.ServiceName
     END) AS ServiceName,
    osb.ReportingInterval,
    osb.Cost,
    tbs.StatusDescription AS 'Billable',
    (CASE WHEN osb.IsDemo = 1 THEN 'Demo' ELSE 'Non-Demo' END) AS 'Demo'
FROM OffenderServiceBilling osb
  JOIN Offender ON Offender.OffenderID = osb.OffenderID
  JOIN Offender_Officer ON Offender_Officer.OffenderID = Offender.OffenderID
  JOIN Officer ON Officer.OfficerID = Offender_Officer.OfficerID
  JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  JOIN Services ON Services.ServiceID = osb.ServiceID
  JOIN Gateway.dbo.DeviceProperties gwDeviceProperties ON gwDeviceProperties.DeviceID = osb.TrackerID
                                                      AND gwDeviceProperties.PropertyID = '8012'  
  JOIN TrackerBillable tb ON tb.TrackerBillableID = osb.BillableID
  JOIN dbo.TrackerBillableStatus tbs ON tbs.StatusID = tb.Status
WHERE DATEADD(mi,@Timezoneoffset,osb.StartDate) < @EndDate AND (DATEADD(mi,@Timezoneoffset,osb.EndDate) > @StartDate OR osb.EndDate IS NULL)
ORDER BY 
    Agency.Agency,
    Offender.Firstname+ ' ' + offender.Lastname,
    osb.StartDate
GO

GRANT EXECUTE ON [ReportOffenderServiceBilling] TO [db_dml]
GO
