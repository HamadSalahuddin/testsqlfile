USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DaylightSavingsOtdUpdateListEArrest]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DaylightSavingsOtdUpdateListEArrest]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* //////////////////////////////////////////////
// FileName: DaylightSavingsOtdUpdateListEArrest
// Purpose:  Get a list of OTD's that need to
//           have GeoRules adjusted for 
//           Daylight Savings.
// Created By:  Aculis
// Modified By: R.Cole
// Modified Date: 10/31/2009
// Changes:  Added new condition to the WHERE
//           clause so that we exclude OTD's
//           in Arizona since AZ doesn't use
//           Daylight Savings.
// Modified by SABBASI on 12-Mar-2010
// /////////////////////////////////////////// */
CREATE PROCEDURE [dbo].[DaylightSavingsOtdUpdateListEArrest]
AS
BEGIN
	SET NOCOUNT ON;

	select distinct
		a.Agency,
        a.AgencyID,
		so.FirstName + ' ' + so.LastName as 'S.O.',
		o.FirstName + ' ' + o.LastName AS 'Offender',
		s.State,
		ota.TrackerID,
		o.OffenderID
	from Offender o (nolock)
	inner join Offender_Officer oo (nolock) on o.OffenderID = oo.OffenderID
	inner join Officer so (nolock) on oo.OfficerID = so.OfficerID
	inner join Agency a (nolock) on o.AgencyID = a.AgencyID
	inner join State s (nolock) on o.HomeStateOrProvinceID = s.StateID
	inner join OffenderTrackerActivation ota (nolock) on ota.OffenderID = o.OffenderID
--	inner join ERule er on er.AssignedETrackerID = ota.TrackerID
	inner join BeaconOffender bo (nolock) on o.offenderid = bo.offenderid
	inner join ERule er (nolock) on er.beaconid = bo.beaconid
	inner join [Rule] r (nolock) on r.ID = er.RuleID
	inner join Schedule sch (nolock) on r.ID = sch.RuleID
	inner join TrackerAssignment ta (nolock) on ta.offenderID = o.offenderid and ta.trackerid = ota.Trackerid
	where  ota.DeActivateDate is null 
		and o.Deleted = 0 
		and sch.AlwaysOn = 0
		and s.StateID <> 4      -- Exclude Arizona
END
GO

GRANT EXECUTE ON [dbo].[DaylightSavingsOtdUpdateListEArrest] TO db_dml;
GO 
