USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Sha_SaveGeoruleFromRedis]    Script Date: 10/14/2020 5:00:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Sha_SaveGeoruleFromRedis.sql
 * Created On: 13-Oct-2020
 * Created By: Hamad Salahuddin
 * Task #:	   12936
 * Purpose:    Ruby script will make use of the sproc to save georule from redis into DB table i.e.
 *			   GeorulesFromRedis  that would further be used for Analysis.               
 *
 * Modified By: H.Salahuddin 10/14/2020 Modified the sproc to use new Column BatchRunDateTime and
 *				insert record everytime the script runs
 * ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Sha_SaveGeoruleFromRedis]
	-- Add the parameters for the stored procedure here
	@GeoruleID			Int,
	@DeviceID			Int,
	@RuleCreatedDateTime	DateTime,
	@BatchRunDateTime   DateTime

AS
BEGIN
	
	Insert Into TrackerPal.dbo.GeorulesFromRedis(
		GeoruleID,
		DeviceID,
		RuleCreatedDateTime,
		BatchRunDateTime)
	Values(@GeoruleID,
			@DeviceID,
			@RuleCreatedDateTime,
			@BatchRunDateTime
			)

END
