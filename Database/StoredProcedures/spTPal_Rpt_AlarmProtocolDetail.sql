USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_AlarmProtocolDetail]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_AlarmProtocolDetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_AlarmProtocolDetail.sql
 * Created On: 12/19/2012
 * Created By: R.Cole
 * Task #:     3116
 * Purpose:    Display alarm protocol instructions to easily
 *             assess all alarm instructions in one view.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_AlarmProtocolDetail] (
  @AgencyID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Dev Use Only // --
--DECLARE @AgencyID INT
--SET @AgencyID = 1333 -- Wayne Co Juv
   
-- // Main Query // --
SELECT Agency.Agency,
       AlarmProtocolSetName AS 'ProtocolSetName',
       AlarmProtocolEvent.AlarmName AS 'AlarmName',
       AlarmProtocolAction.[Type],
       AlarmProtocolAction.[From],
       AlarmProtocolAction.[To],
       AlarmProtocolAction.[Action],
       AlarmProtocolAction.Recipient,
       AlarmProtocolAction.ContactInfo,
       AlarmProtocolAction.Note
FROM Agency
  INNER JOIN AlarmProtocolSet ON Agency.AgencyID = AlarmProtocolSet.AgencyID
  INNER JOIN AlarmProtocolAction ON AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolAction.AlarmProtocolSetID
  INNER JOIN AlarmProtocolEvent ON AlarmProtocolAction.AlarmProtocolEventID = AlarmProtocolEvent.AlarmProtocolEventID
WHERE Agency.AgencyID = @AgencyID
  AND AlarmProtocolAction.Deleted = 0
GROUP BY Agency.Agency,
         AlarmProtocolSetName,
         AlarmProtocolEvent.AlarmName,
         AlarmProtocolAction.[Type],
         AlarmProtocolAction.[From],
         AlarmProtocolAction.[To],
         AlarmProtocolAction.[Action],
         AlarmProtocolAction.Recipient,
         AlarmProtocolAction.ContactInfo,
         AlarmProtocolAction.Note
ORDER BY AlarmProtocolSetName,
         AlarmProtocolEvent.AlarmName,
         AlarmProtocolAction.[Type]
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_AlarmProtocolDetail] TO db_dml;
GO

