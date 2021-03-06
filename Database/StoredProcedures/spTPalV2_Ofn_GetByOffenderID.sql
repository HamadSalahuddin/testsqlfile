USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPalV2_Ofn_GetByOffenderID]    Script Date: 11/01/2014 10:22:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPalV2_Ofn_GetByOffenderID.sql
 * Created On: 04/02/2012
 * Created By: K. Griffiths
 * Task #:     3045
 * Purpose:    Get the offender based on an OffenderID               
 *
 * Modified By: R.Cole - 4/4/2012: Revised to include service
 *                offering and protocol data.
 *              R.Cole - 4/6/2012: Fixed an issue where no
 *                service offering data would be returned in
 *                some cases also added SerialNumber to set.
 *              R.Cole - 4/11/2012: Fixed an issue where the
 *                incorrect ID value was being returned for 
 *                ServiceOffering and ReportingInterval.
 *              R.Cole - 4/13/2012: Fixed an issue where 
 *                multiple tracker records could be returned
 *              R.Cole - 4/13/2012: Fixed an issue where
 *                multiple protocol records could be returned.
 *              R.Cole - 4/13/2012: Fixed an issue where the
 *                HasTracker check was failing.
 *              R.Cole - 4/13/2012: Added logic to handle the
 *               condition where an offender had protocols but 
 *               no tracker.
				Sohail - 24 April 2014: Added Middle Name field task #6070
 * SABBASI; 05/16/2014; EArrest related information was not correct in the result set. Corrected relaionships and pulled the 
 * fields BeaconLimit, EArrest and EArrestID from correct sources. Task #6241
 * SABBASI; 05/17/2014; Removed CASE statement for EArrestStatus and used isnull condition there.
 * HSalahuddin 09/30/2014 added OffenderNumber field task# 6978 
 * HSalahuddin 10/01/2014 added PoliceDistrictID field task 6751
 * HSalahuddin 11/01/2014 added GenderID,SSN,CaseNumber,FBINumber,SentencingDurationStartDate,SentencingDurationEndDate,
 *								TrackingDurationStartDate,TrackingDurationEndDate,HomePhone1TypeID,HomePhone1,HomePhone2TypeID,HomePhone2,
 *							    HomePhone3TypeID,HomePhone3,HomePhone4TypeID,HomePhone4 fields task# 7182
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPalV2_Ofn_GetByOffenderID] (
  @OffenderID INT
) 
AS
SET NOCOUNT ON;

DECLARE @HasTracker INT
DECLARE @HasProtocols INT
DECLARE @EArrestID INT, @EArrest INT
SET @EArrest = 0
SET @EArrestID = 0
SELECT @EArrestID = ISNULL(offs.BillingServiceID,0),         
@EArrest = ISNULL(es.ID,0) 
from billingservice b  
inner join offender o on o.agencyid = b.agencyid  
left join dbo.billingserviceoption bso on bso.BillingServiceID = b.ID  
left  JOIN dbo.OffenderOptionalBillingService offs ON offs.OffenderID = o.OffenderID and b.id=offs.billingserviceid  
left join dbo.OptionalBillingServiceOptionOffender obsoo ON obsoo.OffenderID = o.OffenderID and obsoo.BillingServiceOptionID = bso.ID  
left JOIN dbo.ClassicBillingService cs ON b.ID = cs.BillingServiceID  
LEFT JOIN dbo.EArrestService es ON cs.ID = es.ClassicBillingServiceID         
left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID=o.OffenderID  
LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid  
where o.offenderid = @OffenderID
and   (offs.BillingServiceID is not null or obsoo.BillingServiceOptionID is not null)  
AND (not(obsoo.BillingServiceOptionID is null and cs.ServiceID!=4 ))
AND es.ID IS NOT NULL

SET @HasTracker = ISNULL((SELECT TrackerID FROM TrackerAssignment WHERE TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = @OffenderID)),-1)
--SET @HasTracker = (SELECT TrackerID FROM Offender WHERE OffenderID = @OffenderID)

  SET @HasProtocols = ISNULL((SELECT AlarmProtocolSetID FROM Offender_AlarmProtocolSet WHERE OffenderID = @OffenderID and Deleted = 0),-1)

--select @HasTracker, @HasProtocols

IF (@HasTracker > 0 AND @HasProtocols > 0)
  BEGIN
     -- // Offender has a Tracker // --
    SELECT DISTINCT Offender.OffenderID,
           Offender.FirstName, 
           Offender.LastName,
           Offender.MiddleName, 
           Offender.BirthDate, 
           Offender.PrimaryLanguageID, 
           Offender.HomeStreet1, 
           Offender.HomeStreet2, 
           Offender.HomePhone1, 
           Offender.HomeCity, 
           Offender.HomeStateOrProvinceID, 
           Offender.HomePostalCode, 
           Offender.HomeCountryID, 
           Offender.OffenseTypeID, 
           Offender.AgencyID, 
           Offender_Officer.OfficerID,
           Offender.ReferralProgramID, 
           Offender.ReferralProgramSubTypeID,
           ISNULL(ClassicBillingService.BillingServiceID,0) AS ServiceID,
--           ISNULL(ClassicBillingService.ServiceID, 0) AS ServiceID,                  -- *** Check ID value on Production  ---billingserviceid
           ISNULL(bsori.BillingServiceOptionID, 0) AS ReportingIntervalID,
--           ISNULL(bsori.ReportingIntervalID, 0) AS ReportingIntervalID_test,              -- *** Check ID value on Production --billingserviceoptionid
--           ISNULL(sori.ID,0) AS ReportingIntervalID,
           ISNULL(AlarmProtocolSet.AlarmProtocolSetID, -1) AS AlarmProtocolSetID,    -- *** Check ID value on Production
           @EArrest AS EArrest,
           @EArrestID AS EArrestID, 
             ISNULL(obsoo.BeaconCount, 0) AS BeaconLimit,                     -- *** Check value on Production
           CASE	WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN TrackerAssignment.TrackerID ELSE -1	END AS TrackerID,
--           ISNULL(Tracker.TrackerID, -1) AS TrackerID,                                -- *** Verified -1 is OK on Production
           CASE WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN ISNULL(LEFT(Tracker.TrackerName,8),'')  ELSE '' END AS SerialNumber ,
--           ISNULL(LEFT(Tracker.TrackerName,8),'') AS SerialNumber           
		   ISNULL(OffenderNumber,'') AS OffenderNumber,
		   ISNULL(Offender.PoliceDistrictID,-1) As PoliceDistrictID,
		   ISNULL(Offender.GenderID,-1) As GenderID,
		   ISNULL(Offender.SSN,'') As SSN,
		   ISNULL(Offender.CaseNumber,'') As CaseNumber,
		   ISNULL(Offender.FBINumber,'') As FBINumber,
		   ISNULL(Offender.SentencingDurationStartDate,'') As SentencingDurationStartDate,
		   ISNULL(Offender.SentencingDurationEndDate,'') As SentencingDurationEndDate,
		   ISNULL(Offender.TrackingDurationStartDate,'') As TrackingDurationStartDate,
		   ISNULL(Offender.TrackingDurationEndDate,'') As TrackingDurationEndDate,
		   ISNULL(Offender.HomePhone1TypeID,-1) As HomePhone1TypeID,
		   ISNULL(Offender.HomePhone1,'') As HomePhone1,
		   ISNULL(Offender.HomePhone2TypeID,-1) As HomePhone2TypeID,
		   ISNULL(Offender.HomePhone2,'') As HomePhone2,
		   ISNULL(Offender.HomePhone3TypeID,-1) As HomePhone3TypeID,
		   ISNULL(Offender.HomePhone3,'') As HomePhone3,
		   ISNULL(Offender.HomePhone4TypeID,-1) As HomePhone4TypeID,
		   ISNULL(Offender.HomePhone4,'') As HomePhone4
		   
		   
    FROM Offender
      LEFT OUTER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
      LEFT JOIN OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.Offenderid = Offender.Offenderid
      LEFT JOIN Billingserviceoption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
      LEFT JOIN BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
--      LEFT JOIN refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
      LEFT JOIN ClassicBillingservice WITH (NOLOCK) ON ClassicBillingservice.Billingserviceid = bso.billingserviceid    
      LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID 
-- SABBSI condition being added here
left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID = Offender.OffenderID  
LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid 
-- SABBASI condition end 
      LEFT OUTER JOIN TrackerAssignment ON Offender.OffenderID = TrackerAssignment.OffenderID
                  AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = Offender.OffenderID)
      LEFT OUTER JOIN Tracker ON TrackerAssignment.TrackerID = Tracker.TrackerID
      LEFT OUTER JOIN Offender_AlarmProtocolSet ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID
      LEFT OUTER JOIN AlarmProtocolSet ON Offender_AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolSet.AlarmProtocolSetID
    WHERE Offender.OffenderID = @OffenderID 
      AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker T WHERE t.TrackerID = Tracker.TrackerID)
      AND Offender_AlarmProtocolSet.Deleted = 0
  END
ELSE
  IF (@HasTracker <= 0 AND @HasProtocols > 0)
    BEGIN
       -- // Offender does not have a Tracker but has protocols // --
      SELECT DISTINCT Offender.OffenderID,
             Offender.FirstName, 
             Offender.LastName, 
             Offender.MiddleName,
             Offender.BirthDate, 
             Offender.PrimaryLanguageID, 
             Offender.HomeStreet1, 
             Offender.HomeStreet2, 
             Offender.HomePhone1, 
             Offender.HomeCity, 
             Offender.HomeStateOrProvinceID, 
             Offender.HomePostalCode, 
             Offender.HomeCountryID, 
             Offender.OffenseTypeID, 
             Offender.AgencyID, 
             Offender_Officer.OfficerID,
             Offender.ReferralProgramID, 
             Offender.ReferralProgramSubTypeID,
             ISNULL(ClassicBillingService.BillingServiceID,0) AS ServiceID,
  --           ISNULL(ClassicBillingService.ServiceID, 0) AS ServiceID,                  -- *** Check ID value on Production  ---billingserviceid
             ISNULL(bsori.BillingServiceOptionID, 0) AS ReportingIntervalID,
  --           ISNULL(bsori.ReportingIntervalID, 0) AS ReportingIntervalID_test,              -- *** Check ID value on Production --billingserviceoptionid
  --           ISNULL(sori.ID,0) AS ReportingIntervalID,
             ISNULL(AlarmProtocolSet.AlarmProtocolSetID, -1) AS AlarmProtocolSetID,    -- *** Check ID value on Production
             @EArrest AS EArrest,
             @EArrestID AS EArrestID,   -- NEW Field
             ISNULL(obsoo.BeaconCount, 0) AS BeaconLimit,                     -- *** Check value on Production
             CASE	WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN TrackerAssignment.TrackerID ELSE -1	END AS TrackerID,
  --           ISNULL(Tracker.TrackerID, -1) AS TrackerID,                                -- *** Verified -1 is OK on Production
             CASE WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN ISNULL(LEFT(Tracker.TrackerName,8),'')  ELSE '' END AS SerialNumber ,
  --           ISNULL(LEFT(Tracker.TrackerName,8),'') AS SerialNumber
			 ISNULL(OffenderNumber,'') AS OffenderNumber,
		   ISNULL(Offender.PoliceDistrictID,-1) As PoliceDistrictID,
		   ISNULL(Offender.GenderID,-1) As GenderID,
		   ISNULL(Offender.SSN,'') As SSN,
		   ISNULL(Offender.CaseNumber,'') As CaseNumber,
		   ISNULL(Offender.FBINumber,'') As FBINumber,
		   ISNULL(Offender.SentencingDurationStartDate,'') As SentencingDurationStartDate,
		   ISNULL(Offender.SentencingDurationEndDate,'') As SentencingDurationEndDate,
		   ISNULL(Offender.TrackingDurationStartDate,'') As TrackingDurationStartDate,
		   ISNULL(Offender.TrackingDurationEndDate,'') As TrackingDurationEndDate,
		   ISNULL(Offender.HomePhone1TypeID,-1) As HomePhone1TypeID,
		   ISNULL(Offender.HomePhone1,'') As HomePhone1,
		   ISNULL(Offender.HomePhone2TypeID,-1) As HomePhone2TypeID,
		   ISNULL(Offender.HomePhone2,'') As HomePhone2,
		   ISNULL(Offender.HomePhone3TypeID,-1) As HomePhone3TypeID,
		   ISNULL(Offender.HomePhone3,'') As HomePhone3,
		   ISNULL(Offender.HomePhone4TypeID,-1) As HomePhone4TypeID,
		   ISNULL(Offender.HomePhone4,'') As HomePhone4	        
      FROM Offender
        LEFT OUTER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        LEFT JOIN OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.Offenderid = Offender.Offenderid
        LEFT JOIN Billingserviceoption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
        LEFT JOIN BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
  --      LEFT JOIN refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
        LEFT JOIN ClassicBillingservice WITH (NOLOCK) ON ClassicBillingservice.Billingserviceid = bso.billingserviceid    
        LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID  
-- SABBSI condition being added here
left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID = Offender.OffenderID  
LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid 
-- SABBASI condition end         
LEFT OUTER JOIN TrackerAssignment ON Offender.OffenderID = TrackerAssignment.OffenderID
                    AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = Offender.OffenderID)
        LEFT OUTER JOIN Tracker ON TrackerAssignment.TrackerID = Tracker.TrackerID
        LEFT OUTER JOIN Offender_AlarmProtocolSet ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID
        LEFT OUTER JOIN AlarmProtocolSet ON Offender_AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolSet.AlarmProtocolSetID
      WHERE Offender.OffenderID = @OffenderID 
   --     AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker T WHERE t.TrackerID = Tracker.TrackerID)
        AND Offender_AlarmProtocolSet.Deleted = 0
      END
ELSE
  IF (@HasTracker <= 0 AND @HasProtocols <= 0)
    BEGIN
      -- // Offender does not have a Tracker or protocols // --
      SELECT DISTINCT Offender.OffenderID,
             Offender.FirstName, 
             Offender.LastName, 
             Offender.MiddleName,
             Offender.BirthDate, 
             Offender.PrimaryLanguageID, 
             Offender.HomeStreet1, 
             Offender.HomeStreet2, 
             Offender.HomePhone1, 
             Offender.HomeCity, 
             Offender.HomeStateOrProvinceID, 
             Offender.HomePostalCode, 
             Offender.HomeCountryID, 
             Offender.OffenseTypeID, 
             Offender.AgencyID, 
             Offender_Officer.OfficerID,
             Offender.ReferralProgramID, 
             Offender.ReferralProgramSubTypeID,
             ISNULL(ClassicBillingService.BillingServiceID,0) AS ServiceID,
  --           ISNULL(ClassicBillingService.ServiceID, 0) AS ServiceID,                  -- *** Check ID value on Production  ---billingserviceid
             ISNULL(bsori.BillingServiceOptionID, 0) AS ReportingIntervalID,
  --           ISNULL(bsori.ReportingIntervalID, 0) AS ReportingIntervalID_test,              -- *** Check ID value on Production --billingserviceoptionid
  --           ISNULL(sori.ID,0) AS ReportingIntervalID,
             ISNULL(AlarmProtocolSet.AlarmProtocolSetID, -1) AS AlarmProtocolSetID,    -- *** Check ID value on Production
			 @EArrest AS EArrest,
			 @EArrestID AS EArrestID,   -- NEW Field
             ISNULL(obsoo.BeaconCount, 0) AS BeaconLimit,                    -- *** Check value on Production
             CASE	WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN TrackerAssignment.TrackerID ELSE -1	END AS TrackerID,
  --           ISNULL(Tracker.TrackerID, -1) AS TrackerID,                                -- *** Verified -1 is OK on Production
             CASE WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN ISNULL(LEFT(Tracker.TrackerName,8),'')  ELSE '' END AS SerialNumber, 
  --           ISNULL(LEFT(Tracker.TrackerName,8),'') AS SerialNumber           
			 ISNULL(OffenderNumber,'') AS OffenderNumber,
		   ISNULL(Offender.PoliceDistrictID,-1) As PoliceDistrictID,
		   ISNULL(Offender.GenderID,-1) As GenderID,
		   ISNULL(Offender.SSN,'') As SSN,
		   ISNULL(Offender.CaseNumber,'') As CaseNumber,
		   ISNULL(Offender.FBINumber,'') As FBINumber,
		   ISNULL(Offender.SentencingDurationStartDate,'') As SentencingDurationStartDate,
		   ISNULL(Offender.SentencingDurationEndDate,'') As SentencingDurationEndDate,
		   ISNULL(Offender.TrackingDurationStartDate,'') As TrackingDurationStartDate,
		   ISNULL(Offender.TrackingDurationEndDate,'') As TrackingDurationEndDate,
		   ISNULL(Offender.HomePhone1TypeID,-1) As HomePhone1TypeID,
		   ISNULL(Offender.HomePhone1,'') As HomePhone1,
		   ISNULL(Offender.HomePhone2TypeID,-1) As HomePhone2TypeID,
		   ISNULL(Offender.HomePhone2,'') As HomePhone2,
		   ISNULL(Offender.HomePhone3TypeID,-1) As HomePhone3TypeID,
		   ISNULL(Offender.HomePhone3,'') As HomePhone3,
		   ISNULL(Offender.HomePhone4TypeID,-1) As HomePhone4TypeID,
		   ISNULL(Offender.HomePhone4,'') As HomePhone4
      FROM Offender
        LEFT OUTER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
        LEFT JOIN OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.Offenderid = Offender.Offenderid
        LEFT JOIN Billingserviceoption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
        LEFT JOIN BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
  --      LEFT JOIN refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
        LEFT JOIN ClassicBillingservice WITH (NOLOCK) ON ClassicBillingservice.Billingserviceid = bso.billingserviceid    
        LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID  
		-- SABBSI condition being added here
		left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID = Offender.OffenderID  
		LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid 
		-- SABBASI condition end         
		LEFT OUTER JOIN TrackerAssignment ON Offender.OffenderID = TrackerAssignment.OffenderID
							AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = Offender.OffenderID)
        LEFT OUTER JOIN Tracker ON TrackerAssignment.TrackerID = Tracker.TrackerID
        LEFT OUTER JOIN Offender_AlarmProtocolSet ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID
        LEFT OUTER JOIN AlarmProtocolSet ON Offender_AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolSet.AlarmProtocolSetID
      WHERE Offender.OffenderID = @OffenderID 
   --     AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker T WHERE t.TrackerID = Tracker.TrackerID)
  --      AND Offender_AlarmProtocolSet.Deleted = 0
    END
ELSE
	IF (@HasTracker > 0 AND @HasProtocols <= 0)
	  BEGIN
		 -- // Offender has a Tracker // --
		SELECT DISTINCT Offender.OffenderID,
			   Offender.FirstName, 
			   Offender.LastName,
			   Offender.MiddleName, 
			   Offender.BirthDate, 
			   Offender.PrimaryLanguageID, 
			   Offender.HomeStreet1, 
			   Offender.HomeStreet2, 
			   Offender.HomePhone1, 
			   Offender.HomeCity, 
			   Offender.HomeStateOrProvinceID, 
			   Offender.HomePostalCode, 
			   Offender.HomeCountryID, 
			   Offender.OffenseTypeID, 
			   Offender.AgencyID, 
			   Offender_Officer.OfficerID,
			   Offender.ReferralProgramID, 
			   Offender.ReferralProgramSubTypeID,
			   ISNULL(ClassicBillingService.BillingServiceID,0) AS ServiceID,
	--           ISNULL(ClassicBillingService.ServiceID, 0) AS ServiceID,                  -- *** Check ID value on Production  ---billingserviceid
			   ISNULL(bsori.BillingServiceOptionID, 0) AS ReportingIntervalID,
	--           ISNULL(bsori.ReportingIntervalID, 0) AS ReportingIntervalID_test,              -- *** Check ID value on Production --billingserviceoptionid
	--           ISNULL(sori.ID,0) AS ReportingIntervalID,
			   ISNULL(AlarmProtocolSet.AlarmProtocolSetID, -1) AS AlarmProtocolSetID,    -- *** Check ID value on Production
				@EArrest AS EArrest,
				@EArrestID AS EArrestID,  -- NEW Field
             ISNULL(obsoo.BeaconCount, 0) AS BeaconLimit,                     -- *** Check value on Production
			   CASE	WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN TrackerAssignment.TrackerID ELSE -1	END AS TrackerID,
	--           ISNULL(Tracker.TrackerID, -1) AS TrackerID,                                -- *** Verified -1 is OK on Production
			   CASE WHEN TrackerAssignment.TrackerAssignmentTypeID = 1 THEN ISNULL(LEFT(Tracker.TrackerName,8),'')  ELSE '' END AS SerialNumber, 
	--           ISNULL(LEFT(Tracker.TrackerName,8),'') AS SerialNumber           
			   ISNULL(OffenderNumber,'') AS OffenderNumber,
		   ISNULL(Offender.PoliceDistrictID,-1) As PoliceDistrictID,
		   ISNULL(Offender.GenderID,-1) As GenderID,
		   ISNULL(Offender.SSN,'') As SSN,
		   ISNULL(Offender.CaseNumber,'') As CaseNumber,
		   ISNULL(Offender.FBINumber,'') As FBINumber,
		   ISNULL(Offender.SentencingDurationStartDate,'') As SentencingDurationStartDate,
		   ISNULL(Offender.SentencingDurationEndDate,'') As SentencingDurationEndDate,
		   ISNULL(Offender.TrackingDurationStartDate,'') As TrackingDurationStartDate,
		   ISNULL(Offender.TrackingDurationEndDate,'') As TrackingDurationEndDate,
		   ISNULL(Offender.HomePhone1TypeID,-1) As HomePhone1TypeID,
		   ISNULL(Offender.HomePhone1,'') As HomePhone1,
		   ISNULL(Offender.HomePhone2TypeID,-1) As HomePhone2TypeID,
		   ISNULL(Offender.HomePhone2,'') As HomePhone2,
		   ISNULL(Offender.HomePhone3TypeID,-1) As HomePhone3TypeID,
		   ISNULL(Offender.HomePhone3,'') As HomePhone3,
		   ISNULL(Offender.HomePhone4TypeID,-1) As HomePhone4TypeID,
		   ISNULL(Offender.HomePhone4,'') As HomePhone4
		FROM Offender
		  LEFT OUTER JOIN Offender_Officer ON Offender.OffenderID = Offender_Officer.OffenderID
		  LEFT JOIN OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.Offenderid = Offender.Offenderid
		  LEFT JOIN Billingserviceoption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
		  LEFT JOIN BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
	--      LEFT JOIN refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
		  LEFT JOIN ClassicBillingservice WITH (NOLOCK) ON ClassicBillingservice.Billingserviceid = bso.billingserviceid    
		  LEFT OUTER JOIN EArrestService ON ClassicBillingService.ID = EArrestService.ClassicBillingServiceID  
		-- SABBSI condition being added here
		left join (Select OffenderID, MAX(ID) As lastid From EArrestBillingStatus Group BY Offenderid) ebs1 ON ebs1.OffenderID = Offender.OffenderID  
		LEFT JOIN EarrestBillingStatus ebs ON ebs.id = ebs1.lastid 
		-- SABBASI condition end 		 
		 LEFT OUTER JOIN TrackerAssignment ON Offender.OffenderID = TrackerAssignment.OffenderID
							  AND TrackerAssignmentID = (SELECT MAX(TrackerAssignmentID) FROM TrackerAssignment ta WHERE ta.OffenderID = Offender.OffenderID)
		  LEFT OUTER JOIN Tracker ON TrackerAssignment.TrackerID = Tracker.TrackerID
		  LEFT OUTER JOIN Offender_AlarmProtocolSet ON Offender.OffenderID = Offender_AlarmProtocolSet.OffenderID
		  LEFT OUTER JOIN AlarmProtocolSet ON Offender_AlarmProtocolSet.AlarmProtocolSetID = AlarmProtocolSet.AlarmProtocolSetID
		WHERE Offender.OffenderID = @OffenderID 
		  AND Tracker.TrackerUniqueID = (SELECT MAX(TrackerUniqueID) FROM Tracker T WHERE t.TrackerID = Tracker.TrackerID)
		  AND Offender_AlarmProtocolSet.Deleted = 0
	  END
