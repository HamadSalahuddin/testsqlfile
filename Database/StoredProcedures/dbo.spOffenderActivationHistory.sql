USE [TrackerPal]
GO

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spOffenderActivationHistory]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spOffenderActivationHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spOffenderActivationHistory.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc  
 * Task #:     N/A      
 * Purpose:    Return data to the Offender Activation Report             
 *
 * Modified By: R.Alvarado - 9/25/2013:  Updated for readability
 *              Added code to ensure Officers and Dist. Employees
 *              properly show as deactivators. Per #3310.
 *              R.Cole - 09/25/2013: Fixed legacy time conversion
 *              bug.
 * ******************************************************** */
CREATE PROCEDURE [spOffenderActivationHistory] (
  @AgencyName NVARCHAR(32) = NULL,
  @FirstName NVARCHAR(32) = NULL,
  @LastName NVARCHAR(32) = NULL
)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- // Declare Var's // --
DECLARE @AgencyID INT,
        @OffenderID INT,
        @UTCOffset INT

-- // Get ID's from strings // --
SET @AgencyID = (SELECT ISNULL(AgencyID, 0) FROM Agency WHERE Agency LIKE '%' + ISNULL(@AgencyName,'') + '%')
SET @OffenderID = (SELECT ISNULL(OffenderID, 0) FROM Offender WHERE (FirstName LIKE '%' + ISNULL(@FirstName,'')) AND (LastName LIKE '%' + ISNULL(@LastName,'') + '%'))

-- // Get UTC Offset for time conversions // --
IF ((@AgencyID IS NOT NULL) AND (@AgencyID > 0))
  SET @UTCOffset = [dbo].[fnGetUtcOffset] (@AgencyID)
        

SELECT Agency.Agency,
       Officer.FirstName + ' ' + Officer.LastName AS 'Officer Name',
       Offender.FirstName + ' ' + Offender.LastName AS 'Offender Name',
       OffenderTrackerActivation.TrackerID,
       dp.PropertyValue AS 'Serial Number',
       CONVERT(VARCHAR(25), DATEADD(MI, @UTCOffset, OffenderTrackerActivation.ActivateDate)) AS 'Activated Date',
       (CASE WHEN OffenderTrackerActivation.DeActivateDate IS NULL THEN 'ACTIVE' ELSE CONVERT(VARCHAR(25), DATEADD(MI, @UTCOffset, OffenderTrackerActivation.DeActivateDate)) END) AS 'Deactivated Date',
       (CASE WHEN OffenderTrackerActivation.DeActivateDate IS NULL THEN 'ACTIVE' ELSE COALESCE (Officer.FirstName + ' ' + Officer.LastName, DistributorEmployee.FirstName + ' ' + DistributorEmployee.LastName, Operator.FirstName + ' ' + Operator.LastName) END) AS 'Deactivated By'
FROM OffenderTrackerActivation 
  INNER JOIN Offender ON Offender.OffenderID = OffenderTrackerActivation.OffenderID
  INNER JOIN Officer ON Officer.OfficerID = OffenderTrackerActivation.OfficerID
  INNER JOIN Agency ON Agency.AgencyID = Offender.AgencyID
  INNER JOIN TimeZone ON TimeZone.TimeZoneID = Agency.TimeZoneID
  INNER JOIN Gateway.dbo.DeviceProperties dp ON dp.DeviceID = OffenderTrackerActivation.TrackerID AND dp.PropertyID = '8012'
  LEFT OUTER JOIN Operator ON Operator.UserID = OffenderTrackerActivation.ModifiedByID
  LEFT OUTER JOIN Officer Officer2 ON Officer2.UserID = OffenderTrackerActivation.ModifiedByID
  LEFT OUTER JOIN DistributorEmployee ON DistributorEmployee.UserID = OffenderTrackerActivation.ModifiedByID
WHERE Offender.OffenderID = @OffenderID 
  AND Agency.AgencyID = @AgencyID
--WHERE (Offender.FirstName LIKE '%' + ISNULL (@FirstName,'') + '%') AND (Offender.LastName LIKE '%' + ISNULL (@LastName,'') + '%') AND (Agency.Agency LIKE '%' + ISNULL (@AgencyName,'') + '%')
ORDER BY Agency.Agency,
         'Offender Name',
         'Activated Date'
GO

GRANT EXECUTE ON [spOffenderActivationHistory] TO [db_dml]
GO
