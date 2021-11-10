SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Beacon_GetByID.sql
 * Created On: 22-July-2014
 * Created By: Hamad Salahuddin	
 * Task #:     6603
 * Purpose:    Returns Specific Beacon Detail By ID
 * **********************************************************/
CREATE PROCEDURE [dbo].[spTPal_Beacon_GetByID] 
	-- Add the parameters for the stored procedure here
	@BeaconID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT BeaconID,SerialNum,BeaconName,b.AgencyID,Agency,b.CreatedDate
	FROM [Trackerpal].[Dbo].[Agency]As a
	Left Outer Join [Trackerpal].[Dbo].[Beacons] As b on a.AgencyID=b.AgencyID
	Where BeaconID= @BeaconID
	And b.Deleted =0
END
GO
