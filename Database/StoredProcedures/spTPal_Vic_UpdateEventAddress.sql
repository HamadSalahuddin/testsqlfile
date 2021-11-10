USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Vic_UpdateEventAddress]    Script Date: 11/12/2020 10:56:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Vic_UpdateEventAddress.sql
 * Created On: 05/31/2014
 * Created By: SABBASI
 * Task #:  6343   
 * Purpose: Update Victim events after reverse geo coding.
* ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Vic_UpdateEventAddress]
	@VictimEventID INT,
	@Address nVARCHAR(1000)
AS
UPDATE dbo.VictimEvents 
  SET [Address] = @Address 
	WHERE VictimEventID = @VictimEventID
