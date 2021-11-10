USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_DomesticViolenceOffenders]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_DomesticViolenceOffenders]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_DomesticViolenceOffenders.sql
 * Created On: 09/22/2010
 * Created By: R.Cole
 * Task #:     #1303
 * Purpose:    Automated report query, returns a daily list
 *             of Domestic Violence Offenders which is sent
 *             to the MC Superviors               
 *             (Original query written by A.Harris)
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_DomesticViolenceOffenders] 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT Agency.Agency AS 'Agency',
       Officer.FirstName + ' ' + Officer.LastName AS 'Officer',
       Offender.FirstName + ' ' + Offender.LastName as 'Offender',
       dp.PropertyValue AS 'Device',
       (CASE WHEN Offender.HomeStreet1 NOT LIKE '' THEN Offender.HomeStreet1 + ' ' + Offender.HomeStreet2 + ' - ' + Offender.HomeCity + ', ' + [State].Abbreviation
			       ELSE [State].[State] 
			  END) AS 'Home Address'
FROM Offender
  INNER JOIN Agency on Agency.AgencyID = Offender.AgencyID
  INNER JOIN [State] on Agency.StateID = [State].StateID
  INNER JOIN OffenderServiceBilling osb ON Offender.OffenderID = osb.OffenderID
  INNER JOIN Offender_Officer OO ON Offender.OffenderID = OO.OffenderID
  INNER JOIN Officer ON OO.OfficerID = Officer.OfficerID
  LEFT OUTER JOIN Gateway.dbo.DeviceProperties dp ON osb.TrackerID = dp.DeviceID AND dp.PropertyID = '8012'
WHERE osb.Active = 1
  AND (Offender.FirstName LIKE '%***%' OR Offender.LastName LIKE '%***%')
ORDER BY Agency.Agency,
         Officer.FirstName + ' ' + Officer.LastName,
         Offender.FirstName + ' ' + Offender.LastName
GO

GRANT EXECUTE ON [dbo].[spTPal_Rpt_DomesticViolenceOffenders] TO db_dml;
GO