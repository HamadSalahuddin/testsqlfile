set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


/* **********************************************************
 FileName:   spTPal_Bcn_InsertBeaconsList.sql
 * Created On: 07/02/2014         
 * Created By: H.Salahuddin
 * Task #:     #6425 Need a way to enter beacons
 * Purpose:    Inserts comma separated Beacon's Serial numbers 
 *			   into DB with AgencyID and other required parameters                 
 *
 * Modified By: H.Salahuddin 07/03/2014. Added duplicated beacons into failedIds.
 *				H.Salahuddin 07/04/2014 Task #4913 added empty string for BeaconName 
 ************************************************************/

ALTER PROCEDURE [dbo].[spTPal_Bcn_InsertBeaconsList] 
 
	@SerialNumber varchar(max), 
	@AgencyID int,
	@CreatedByID int,
	@FailedIds varchar(max) output
AS
BEGIN
	
	SET NOCOUNT ON;
	Set @FailedIds ='';
	Declare @SNo varchar(100)
    
	DECLARE LoopBeaconSerialNos CURSOR FAST_FORWARD
	FOR 
	--select statemet
	SELECT Number FROM  [Trackerpal].[dbo].[GetTableStringFromListId](@SerialNumber)
	-- Open Cursor and Fetching the first row.
	
Begin TRAN -- Begining the Transaction

	OPEN LoopBeaconSerialNos
	FETCH NEXT FROM LoopBeaconSerialNos INTO @SNo
	--PRINTING 
	WHILE @@FETCH_STATUS =0
	BEGIN		
	 BEGIN TRY
		IF EXISTS(Select 1 From Beacons Where SerialNum=@SNo AND Deleted = 0)
			BEGIN
				IF @FailedIds =''
				begin
					Set @FailedIds = @SNo;
				end
				ELSE			
				begin
					set @FailedIds = @FailedIds+','+@SNo;
				end
			END
		ELSE
			BEGIN			
			INSERT INTO Beacons(SerialNum, BeaconName, AgencyID, CreatedDate, CreatedByID)
			VALUES(@SNo, '', @AgencyID, GetUTCDate(), @CreatedByID)
			END
	 END TRY
	 BEGIN CATCH
		set @FailedIds = @FailedIds+','+@SNo
	 END CATCH
		FETCH NEXT FROM LoopBeaconSerialNos INTO @SNo	
	END
	--Closing and Deallocating Cursor
	CLOSE LoopBeaconSerialNos	
	DEALLOCATE LoopBeaconSerialNos
	----------------------------------------------------------	
IF @@ERROR <> 0    
BEGIN    
ROLLBACK Tran    
END    
COMMIT TRAN 
END

