USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spSvc_Ofn_GetPhoneContact]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spSvc_Ofn_GetPhoneContact]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spSvc_Ofn_GetPhoneContact.sql
 * Created On: 11-Apr-2012         
 * Created By: SABBASI  
 * Task #:     3241      
 * Purpose:     Retrieves Offender PhoneContact information.               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spSvc_Ofn_GetPhoneContact] (	
	@OffenderID INT
)
AS
SET NOCOUNT ON;
BEGIN
  SELECT CASE ISNULL((CASE Offender.HomePhone1 WHEN '' THEN NULL ELSE pt1.PhoneType + ': ' + Offender.HomePhone1 + ' ' END), '') + 
              ISNULL((CASE Offender.HomePhone2 WHEN '' THEN NULL ELSE pt2.PhoneType + ': ' + Offender.HomePhone2 + ' ' END), '') +
              ISNULL((CASE Offender.HomePhone3 WHEN '' THEN NULL ELSE pt3.PhoneType + ': ' + Offender.HomePhone3 + ' ' END), '') 
              WHEN '' THEN 'N/A'
              ELSE ISNULL((CASE Offender.HomePhone1 WHEN '' THEN NULL ELSE pt1.PhoneType + ': ' + Offender.HomePhone1 + ' ' END), '') + 
                   ISNULL((CASE Offender.HomePhone2 WHEN '' THEN NULL ELSE pt2.PhoneType + ': ' + Offender.HomePhone2 + ' ' END), '') +
                   ISNULL((CASE Offender.HomePhone3 WHEN '' THEN NULL ELSE pt3.PhoneType + ': ' + Offender.HomePhone3 + ' ' END), '') 
         END AS PhoneContact
  FROM Offender
    LEFT OUTER JOIN PhoneType pt1 ON Offender.HomePhone1TypeID = pt1.PhoneTypeID 
    LEFT OUTER JOIN PhoneType pt2 ON Offender.HomePhone2TypeID = pt2.PhoneTypeID
    LEFT OUTER JOIN PhoneType pt3 ON Offender.HomePhone3TypeID = pt3.PhoneTypeID
  WHERE Offender.OffenderID = @OffenderID
END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spSvc_Ofn_GetPhoneContact] TO db_dml;
GO