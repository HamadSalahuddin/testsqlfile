USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Svc_AddChangedServicePlan]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Svc_AddChangedServicePlan]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Svc_AddChangedServicePlan.sql
 * Created On: 17-Jan-2011
 * Created By: Sajid Abbasi
 * Task #:     # 1827
 * Purpose:    Add changed service plan reference that has changed
 *
 * Modified By: R.Cole - 1/07/2011: Corrected typo in SP name,
 *                added DROP IF EXISTS and GRANT stmts.
 * ******************************************************** */
CREATE PROCEDURE spTPal_Svc_AddChangedServicePlan (
	@AgencyID INT,
	@ServiceID INT,
	@IntervalIDs VARCHAR(2000)
)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO ChangedServicePlan(AgencyID, ServiceID, IntervalIDs)
	VALUES (@AgencyID, @ServiceID, @IntervalIDs)
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Svc_AddChangedServicePlan] TO db_dml;
GO