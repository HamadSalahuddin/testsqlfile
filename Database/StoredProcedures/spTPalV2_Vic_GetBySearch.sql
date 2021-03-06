USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Vic_GetBySearch]    Script Date: 9/2/2020 10:44:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPalV2_Vic_GetBySearch.sql
 * Created On: 27 Dec 2013
 * Created By: S.Khaliq
 * Task #:     Unknown
 * Purpose:    Populate the VictimInfo screen in TrackerPal by search Criteria              
 * Modified BY:    Added First Name and Last Name Filters in the WHERE clause.
 *			  : SABBASI; 2/8/2014 - Added RoleID = 15, Supervision officer in the list of roles which can see
 *        the information about Victim.
 *        R.Cole 4/30/2014 - Removed all single letter aliases,
 *          brought up to standard, added join to active offender view
 *          to address requirement in ticket #5910
 *		  SABBASI; Task #5910; Return only those offender names has associated offender id which have active devices.
 *		  H.Salahuddin. Task# 5532 added v.Deleted =0 for RoleID 2,3 & 15
 *        H.Salahuddin. Task #13609 Added RegistrationId,DeviceIMEI fields to be returned from DB in Case of getting Victims of a given Agency, else null is returned.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Vic_GetBySearch] (
  @FirstName	NVARCHAR(50),
  @LastName	NVARCHAR(50),  
  @AgencyID INT,
  @OfficerID INT,
  @RoleID INT, 
  @DistributorID INT
) 
AS
SET NOCOUNT ON;
   
IF OBJECT_ID('tempdb..#tempVictim') IS NOT NULL DROP TABLE #tempVictim
CREATE TABLE #tempVictim(
OffenderID INT,
VictimID INT,
FirstName VARCHAR(MAX),
LastName VARCHAR(MAX),
BirthDate DATETIME,
AssociatedOffender VARCHAR(MAX),
RegistrationID Nvarchar(2000),
DeviceIMEI Varchar(32),
AssociatedOfficer VARCHAR(MAX) ) 
-- // Main Query // --
IF (@RoleID IN (4,8,9,10,19))
  -- // Get Resultset for SecureAlert Users // --
  BEGIN
;With Victim_CTE(OffenderID, VictimID, FirstName, LastName, BirthDate,AssociatedOffender,RegistraionID,DeviceIMEI,AssociatedOfficer) 
AS
(
    SELECT o.OffenderID,v.VictimID,
           v.FirstName, 
           v.LastName,
           v.BirthDate,
           ISNULL(o.LastName , '') + ', ' +	ISNULL(o.FirstName , '') + ISNULL(' ' + o.MiddleName , '')  AS 'AssociatedOffender',
		   Null,
		   Null,
		   ISNULL(ofc.LastName,'')+', '+ISNULL(ofc.FirstName,'')+ISNULL(' '+ofc.MiddleName,'') As 'AssociatedOfficer'
	FROM Victim v  inner join Offender o on o.OffenderID=v.AssociatedOffenderID		            
    Inner Join Trackerpal.dbo.Offender_Officer ofo on ofo.OffenderID = o.OffenderID
    Inner Join Trackerpal.dbo.Officer ofc on ofc.OfficerID = ofo.OfficerID

    WHERE v.FirstName LIKE '%'+@FirstName+'%' AND v.LastName LIKE '%'+@LastName+'%' AND v.Deleted = 0 and (( @AgencyID = -1) or(o.AgencyID = @AgencyID))
)INSERT INTO #tempVictim SELECT * FROM Victim_CTE
  END
ELSE
  IF (@DistributorID > 0)
    -- // Get Resultset for all Agencies belonging to Distributor // --
    BEGIN
;With Victim_CTE(OffenderID, VictimID, FirstName, LastName, BirthDate,AssociatedOffender,RegistraionID,DeviceIMEI,AssociatedOfficer) 
AS
(
       SELECT o.OffenderID,v.VictimID,
           v.FirstName, 
           v.LastName,
           v.BirthDate,
           ISNULL(o.LastName , '') + ', ' +	ISNULL(o.FirstName , '') + ISNULL(' ' + o.MiddleName , '')  AS 'AssociatedOffender',
		   Null,
		   Null,
		   ISNULL(ofc.LastName,'')+', '+ISNULL(ofc.FirstName,'')+ISNULL(' '+ofc.MiddleName,'') As 'AssociatedOfficer'
     FROM Victim v  inner join Offender o on o.OffenderID=v.AssociatedOffenderID
	 INNER JOIN Agency a ON o.AgencyID = a.AgencyID
     Inner Join Trackerpal.dbo.Offender_Officer ofo on ofo.OffenderID = o.OffenderID
     Inner Join Trackerpal.dbo.Officer ofc on ofc.OfficerID = ofo.OfficerID

      WHERE v.FirstName LIKE '%'+@FirstName+'%' AND v.LastName LIKE '%'+@LastName+'%' AND (( @AgencyID = -1) or(o.AgencyID = @AgencyID))
		AND a.DistributorID = @DistributorID 
        AND v.Deleted = 0
)INSERT INTO #tempVictim SELECT * FROM Victim_CTE
    END
ELSE IF @RoleID IN (2,3)
    -- // Get Resultset for Single Agency, All Officers // --
    BEGIN
;With Victim_CTE(OffenderID, VictimID, FirstName, LastName, BirthDate,AssociatedOffender,RegistraionID,DeviceIMEI,AssociatedOfficer) 
AS
(
      SELECT o.OffenderID,v.VictimID,
           v.FirstName, 
           v.LastName,
           v.BirthDate,
           ISNULL(o.LastName , '') + ', ' +	ISNULL(o.FirstName , '') + ISNULL(' ' + o.MiddleName , '')  AS 'AssociatedOffender',
		   vd.RegistrationID,
		   vd.DeviceIMEI,
		   ISNULL(ofc.LastName,'')+', '+ISNULL(ofc.FirstName,'')+ISNULL(' '+ofc.MiddleName,'') As 'AssociatedOfficer'           
     FROM Victim v  
	 Inner Join VictimDevice as vd on v.VictimDeviceID = vd.VictimDeviceID
	 inner join Offender o on o.OffenderID = v.AssociatedOffenderID
	 Inner Join Trackerpal.dbo.Offender_Officer ofo on ofo.OffenderID = o.OffenderID
     Inner Join Trackerpal.dbo.Officer ofc on ofc.OfficerID = ofo.OfficerID
      WHERE v.FirstName LIKE '%'+@FirstName+'%' AND v.LastName LIKE '%'+@LastName+'%' AND (( @AgencyID = -1) or(o.AgencyID = @AgencyID))
        AND o.Deleted = 0
        AND v.Deleted = 0
		And vd.Deleted = 0
)INSERT INTO #tempVictim SELECT * FROM Victim_CTE
END
ELSE IF @RoleID = 15
  BEGIN
;With Victim_CTE(OffenderID, VictimID, FirstName, LastName, BirthDate,AssociatedOffender,RegistraionID,DeviceIMEI,AssociatedOfficer) 
AS
(
    SELECT o.OffenderID,v.VictimID,
       v.FirstName, 
       v.LastName,
       v.BirthDate,
       ISNULL(o.LastName , '') + ', ' +	ISNULL(o.FirstName , '') + ISNULL(' ' + o.MiddleName , '')  AS 'AssociatedOffender',
	   Null,
	   Null,
	   ISNULL(ofc.LastName,'')+', '+ISNULL(ofc.FirstName,'')+ISNULL(' '+ofc.MiddleName,'') As 'AssociatedOfficer'
      FROM Victim v  INNER JOIN Offender o on o.OffenderID = v.AssociatedOffenderID
					 INNER JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
					 INNER JOIN Officer ofc ON oo.OfficerID = ofc.OfficerID
      WHERE v.FirstName LIKE '%'+@FirstName+'%' AND v.LastName LIKE '%'+@LastName+'%' AND (( @AgencyID = -1) or(o.AgencyID = @AgencyID)) 
		AND ofc.OfficerID = @OfficerID
        AND o.Deleted = 0
        AND v.Deleted = 0
)INSERT INTO #tempVictim SELECT * FROM Victim_CTE
END

UPDATE V
SET  V.AssociatedOffender = '',
V.AssociatedOfficer = ''
FROM #tempVictim V
WHERE V.OffenderID NOT IN
(SELECT V.OffenderID
FROM #tempVictim V
INNER JOIN OffenderTrackerActivation ota ON V.OffenderID = ota.OffenderID  AND ota.DeactivateDate IS NULL)

SELECT VictimID,FirstName,LastName,BirthDate,AssociatedOffender,RegistrationID,DeviceIMEI,AssociatedOfficer FROM #tempVictim

