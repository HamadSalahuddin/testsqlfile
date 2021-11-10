/* **********************************************************
 * FileName:   spTPal_Beacon_UpdateByID.sql
 * Created On: 12-July-2014
 * Created By: Hamad Salahuddin	
 * Task #:     6603
 * Purpose:    Updates AgencyID by BeaconID
 * **********************************************************/
ALTER PROCEDURE spTPal_Beacon_UpdateByID 
	-- Add the parameters for the stored procedure here
	@AgencyID int,
	@BeaconID int,
	@UserID	  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update [Trackerpal].[dbo].[Beacons]
	Set AgencyID = @AgencyID,
		ModifiedDate =getutcdate(),
		ModifiedByID = @UserID
	Where BeaconID = @BeaconID
END
GO
