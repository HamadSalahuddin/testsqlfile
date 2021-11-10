USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[rprtGeoRuleUploadStatus]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[rprtGeoRuleUploadStatus]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   rprtGeoRuleUploadStatus.sql
 * Created On: 04/06/2010         
 * Created By: R.Cole
 * Task #:     SA 859
 * Purpose:    Return the Number of GeoRule uploads that have
 *             an In-Progress or Failed status.
 *
 * IMPORTANT NOTE: A single 'visible' GeoRule may be stored
 *                 as multiple GeoRules in the Database and
 *                 on the Gateway
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
CREATE PROCEDURE [dbo].[rprtGeoRuleUploadStatus] (
  @StartDate DATETIME,
  @EndDate DATETIME
) 
AS
SET NOCOUNT ON;

/* *** Dev Code Block*** */
DECLARE @StartDate DATETIME,
        @EndDate DATETIME
        
SET @StartDate = '03/31/2010 00:00:01'
SET @EndDate = '04/01/2010 00:00:01'
/* *** End Dev Code Block *** */
   
-- // Main Query // --
SELECT GeoRule.GeoRuleID,
       Offender.OffenderID,
       Offender.TrackerID,
       Offender.FirstName + ' ' + Offender.LastName AS Offender,
       Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS Officer,
       GeoRule.GeoRuleName,
       GeoRule.CreatedDate,
       GeoRule_Offender.AreaID,
       CASE GeoRule.StatusID WHEN 1 THEN 'New'
                             WHEN 2 THEN 'InActive'
                             WHEN 3 THEN 'In Progress'
                             WHEN 4 THEN 'Sucess'
                             WHEN 5 THEN 'Failed'
       END AS 'GeoRule Status',
       GeoRule.UpdateInProgress

FROM GeoRule
  INNER JOIN GeoRule_Offender ON GeoRule.GeoRuleID = GeoRule_Offender.GeoRuleID
  INNER JOIN Offender ON GeoRule_Offender.OffenderID = Offender.OffenderID
  INNER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
  INNER JOIN Officer ON Offender_Officer.OfficerID = Officer.OfficerID 
--         AND Offender.AgencyID = Officer.AgencyID
  INNER JOIN Agency ON Offender.AgencyID = Agency.AgencyID
WHERE GeoRule.CreatedDate BETWEEN @StartDate AND GETDATE() --@EndDate
--  AND GeoRule.StatusID <> 4 
--  AND GeoRule.StatusID IN (4, 5)  
--  AND GeoRule.CreatedByID = 55                                        -- used to detect failures during SecureAlert mass uploads
  AND Offender.TrackerID <> -1
  AND Offender.OffenderID IN (25122, 30002, 30286, 31860,32279,33243,33466,33620,33806,34263,34905,34942,35009,35114,35179,35302,35851,35965,36115,36138,36232,36367,36487,36653,36671,36741,36762,36835,36837,36880,36905,37024,37108,37305,37345,37388,37460,37487,37495,37548,37630,37727,37738,37764,37784,37832,37853,37872,37915,37939,37949,37989,38007,38098,38171,38174,38241,38243,38247,38260,38306,38350,38352,38363,38411,38414,38447,38488,38504,38536,38547,38556,38575)
ORDER BY Agency
GO

GRANT EXECUTE ON [dbo].[rprtGeoRuleUploadStatus] TO db_dml;
GO