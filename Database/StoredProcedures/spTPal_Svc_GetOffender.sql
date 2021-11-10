USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Svc_GetOffender]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Svc_GetOffender]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Svc_GetOffender.sql
 * Created On: 01/13/2011
 * Created By: R.Cole  
 * Task #:     #1676 / #1827
 * Purpose:    Return a list of an agency's offenders that
 *             are on a given service plan. 
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Svc_GetOffender] (
    @AgencyID INT,
    @ServiceID INT
) 
AS
SET NOCOUNT ON;
  
/* *** Dev Use Only ****
 * This is a work in progress, this code block will be removed prior to release
 
-- // Modified Aculis Code // --
-- Returns the exact same results as 'Main Query' logic

SELECT DISTINCT Offender.OffenderID
FROM Agency
  INNER JOIN Offender WITH (NOLOCK) ON Agency.AgencyID = Offender.AgencyID  
  LEFT OUTER JOIN dbo.OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.OffenderID = Offender.OffenderID
	LEFT OUTER JOIN BillingServiceOption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
	LEFT OUTER JOIN dbo.BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
	LEFT OUTER JOIN dbo.refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
	LEFT OUTER JOIN ClassicBillingService cbs WITH (NOLOCK) ON cbs.BillingServiceID = bso.BillingServiceID
  INNER JOIN OffenderTrackerActivation ota WITH (NOLOCK) ON ota.OffenderID = Offender.OffenderID AND ota.DeactivateDate IS NULL
WHERE Agency.AgencyID = @AgencyID
  AND cbs.ServiceID = (SELECT ServiceID
                       FROM OffenderServiceBilling WITH (NOLOCK)
                       WHERE OffenderID = Offender.OffenderID 
                         AND ServiceID = @ServiceID
                         AND Active = 1)
 * ****** End Dev Use *** */
   
-- // Main Query // --
SELECT DISTINCT Offender.OffenderID
FROM Offender WITH (NOLOCK)
  INNER JOIN OffenderServiceBilling osb WITH (NOLOCK) ON osb.OffenderID = Offender.OffenderID
  INNER JOIN OffenderTrackerActivation ota WITH (NOLOCK) ON Offender.OffenderID = ota.OffenderID AND ota.DeactivateDate IS NULL
WHERE Offender.AgencyID = @AgencyID
  AND osb.ServiceID = @ServiceID
  AND Offender.Deleted = 0
GO

-- // Grant Permissions // --
GRANT EXECUTE ON [dbo].[spTPal_Svc_GetOffender] TO db_dml;
GO