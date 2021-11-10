/* **********************************************************
 * FileName:   spTPal_Beacon_GetByRole.sql
 * Created On: 19-July-2014
 * Created By: Hamad Salahuddin	
 * Task #:     6603
 * Purpose:    Returns Unassigned Beacons Role Wise
 * **********************************************************/
CREATE PROCEDURE spTPal_Beacon_GetByRole 
	-- Add the parameters for the stored procedure here	
	@RoleID int , 
	@UserID int
AS
BEGIN
	If @RoleID = 6 
Begin
	-- if role is distributor then  we should bring all unassigned beacons of agencies for that distributor.
	Declare 
	@DistributorID int 
	
	Select @DistributorID = DistributorID   From DistributorEmployee  Where UserID =@UserID  And Deleted = 0
	
	
	Select b.BeaconID, SerialNum,BeaconName,AgencyID,CreatedDate,CreatedByID,ModifiedDate,ModifiedByID,Deleted
	From [Trackerpal].[Dbo].[Beacons] As b	
	
	-- Agency filtering
	Where b.BeaconID Not In(Select BeaconID 
							From [Trackerpal].[Dbo].[BeaconOffender]														
							)
	And	AgencyID In (
						Select AgencyID
						From [Trackerpal].[Dbo].[Agency]
						Where Deleted =0 And DistributorID <> 0
						And DistributorID = @DistributorID
					   )
	And Deleted =0
End
Else
If @RoleID = 4
--if role is appliction Admin then all unassigned beacons regardless of agencies will be returned.
Begin
	Select b.BeaconID, SerialNum,BeaconName,AgencyID,CreatedDate,CreatedByID,ModifiedDate,ModifiedByID,Deleted
	From [Trackerpal].[Dbo].[Beacons] As b	
	
	-- Agency filtering
	Where b.BeaconID Not In(Select BeaconID 
							From [Trackerpal].[Dbo].[BeaconOffender]														
							)	
	And Deleted =0
End

END
GO
