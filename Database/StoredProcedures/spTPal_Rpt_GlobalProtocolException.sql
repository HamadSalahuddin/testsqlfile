USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_GlobalProtocolException]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_GlobalProtocolException]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_GlobalProtocolException.sql
 * Created On: 10/11/2012
 * Created By: R.Cole
 * Task #:     #3665
 * Purpose:    Identify those offenders have no protocol set
 *             assigned but should be on a global protocol set.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_GlobalProtocolException] 
AS
SET NOCOUNT ON;
   
-- // Main Query // --
SELECT Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       Offender.OffenderID,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       svs.ServiceName,
       oaps.AlarmProtocolSetID AS CurrentProtocol,
       aps.AlarmProtocolSetName AS CurrentProtocolName,
       z.AlarmProtocolSetID AS CorrectProtocol,
       aps1.AlarmProtocolSetName AS CorrectProtocolName,
       oaps.CreatedDate AS RelationCreated,
       oaps.Deleted,
       Offender.CreatedDate AS OffenderCreated,
       ota.ActivateDate,
       ota.DeactivateDate,
       oaps.Offender_AlarmProtocolSetID
--INTO #tmpNoProtocols
FROM Offender
  INNER JOIN Offender_AlarmProtocolSet oaps ON Offender.OffenderID = oaps.OffenderID  
  INNER JOIN OffenderTrackerActivation ota ON Offender.OffenderID = ota.OffenderID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
  INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID
  LEFT OUTER JOIN AlarmProtocolSet aps ON oaps.AlarmProtocolSetID = aps.AlarmProtocolSetID
  LEFT OUTER JOIN (SELECT OffenderID, AlarmProtocolSetID, ModifiedDate
                   FROM Offender_AlarmProtocolSet t 
                   WHERE t.AlarmProtocolSetID > 0
                     AND t. ModifiedDate = (SELECT MAX(ModifiedDate) 
                                            FROM Offender_AlarmProtocolSet x 
                                            WHERE x.OffenderID = t.OffenderID
                                              AND x.Deleted = 1)) z ON z.OffenderID = Offender.OffenderID
  LEFT OUTER JOIN AlarmProtocolSet aps1 ON z.AlarmProtocolSetID = aps1.AlarmProtocolSetID
  INNER JOIN OffenderServiceBilling osb ON Offender.OffenderID = osb.OffenderID
  INNER JOIN Services svs ON osb.ServiceID = svs.ServiceID
WHERE oaps.AlarmProtocolSetID = 0 
  AND oaps.Deleted = 0 
  AND oaps.CreatedDate > '2012-01-01'
  AND Offender.Deleted = 0
  AND ota.DeactivateDate IS NULL
  AND Agency.AgencyID NOT IN (SELECT AgencyID FROM ReportHelper.dbo.AgencyExcl)
  AND osb.EndDate IS NULL
ORDER BY Agency.Agency,
         Offender.FirstName + ' ' + Offender.LastName
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_GlobalProtocolException] TO db_dml;
GO