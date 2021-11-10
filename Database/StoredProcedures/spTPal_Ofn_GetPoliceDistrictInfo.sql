USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_GetPoliceDistrictInfo]    Script Date: 11/09/2013 15:08:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_GetPoliceDistrictInfo.sql
 * Created On: 9 Nov 2013
 * Created By: SOHAIL KHALIQ
 * Task #:     #3994
 * Purpose:    Get all the police districts and add them into drop down lookup.
 *
 * ******************************************************** */

ALTER PROCEDURE [dbo].[spTPal_Ofn_GetPoliceDistrictInfo]  
 @AgencyID     INT   
AS
SELECT PoliceDistrictID,[Description] FROM PoliceDistricts
WHERE AgencyID=@AgencyID