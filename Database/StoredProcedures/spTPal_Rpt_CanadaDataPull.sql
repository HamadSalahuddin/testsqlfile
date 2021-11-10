USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_CanadaDataPull]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_CanadaDataPull]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_CanadaDataPull.sql
 * Created On: 12/12/2011         
 * Created By: R.Cole  
 * Task #:     2976
 * Purpose:    Populate a weekly data pull for a Canadian
 *             Federal Study.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_CanadaDataPull] 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartDate DATETIME

SET @StartDate = DATEADD(DAY, -1, GETDATE())

   
-- // Main Query // --
SELECT DISTINCT rprtEventsBucket1.EventPrimaryID,
       Agency.Agency,
       LEFT(TrackerName,8) AS Device,       
       rprtEventsBucket1.EventDateTime,
       CONVERT(NVARCHAR(20),ISNULL(ROUND(rprtEventsBucket1.Latitude,5), 0)) + ', ' + CONVERT(NVARCHAR(20),ISNULL(ROUND(rprtEventsBucket1.Longitude,5), 0)) AS 'Lat/Long'  
FROM rprtEventsBucket1
  INNER JOIN Agency ON rprtEventsBucket1.AgencyID = Agency.AgencyID
  INNER JOIN Tracker ON rprtEventsBucket1.DeviceID = Tracker.TrackerID
WHERE rprtEventsBucket1.AgencyID IN (5,6)
  AND rprtEventsBucket1.EventDateTime >= @StartDate 
ORDER BY Agency.Agency ASC,
         LEFT(TrackerName,8) ASC,
         EventDateTime ASC
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_CanadaDataPull] TO db_dml;
GO