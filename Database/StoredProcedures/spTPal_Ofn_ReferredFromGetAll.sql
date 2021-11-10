USE [TrackerPal]
GO

/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_ReferredFromGetAll]    Script Date: 08/04/2016 11:42:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* **********************************************************
 * FileName:   spTPal_Ofn_ReferredFromGetAll.sql
 * Created On: 08/02/2016
 * Created By: H.Salahuddin
 * Task #:     New Philly Project. Number is Not Yet Defined
 * Purpose:    Lists up avaialble values from ReferredFrom table lookup table to shown in the dropdown list
 *			   for PrivillegedAgency with DefaultCulture. on OffenderAddScreen.
 *
 * Modified By: 
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Ofn_ReferredFromGetAll] 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select ReferredFromID, ReferredFrom
	From Trackerpal.dbo.ReferredFrom
	Order by ReferredFrom 
END

GO

