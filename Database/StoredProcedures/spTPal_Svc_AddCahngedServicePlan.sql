-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 17-Jan-2011
-- Description:	Add changed service plan reference that has cahnged; Task #1827
-- =============================================
CREATE PROCEDURE spTPal_Svc_AddCahngedServicePlan
	@AgencyID int,
	@ServiceID int,
	@IntervalIDs varchar(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO ChangedServicePlan(AgencyId,ServiceID,IntervalIDs)
	VALUES (@AgencyID,@ServiceID, @IntervalIDs)
END
GO
