USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BillingServiceUpdate]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BillingServiceUpdate]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   BillingServiceUpdate.sql
 * Created On: Unknown
 * Created By: Aculis, Inc.
 * Task #:     
 * Purpose:    Updates a Billing Service record for an agency               
 *
 * Modified By: S.Abbasi - 01/14/2011: Added Disabled Flag
 *              R.Cole - 01/14/2011: Added DROP IF EXISTS and
 *                GRANT stmts, general edits to bring up to 
 *                coding standard.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[BillingServiceUpdate] (
    @BillingServiceID INT, 
    @StartDateTime DATETIME, 
    @BillingServiceTypeID INT,
    @NumberOfBeacons INT,
    @Rate FLOAT,
    @Price FLOAT,
    @IsEArrest BIT,
    @Disabled BIT = 0
)
AS
SET NOCOUNT ON;

-- // Check for latent transcation // --.
IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION
	END;

-- // Begin Tran // --
BEGIN TRANSACTION;
  BEGIN TRY
    UPDATE dbo.BillingService
      SET	StartDateTime = @StartDateTime,
		      BillingServiceTypeID = @BillingServiceTypeID,
		      [Disabled] = @Disabled
      WHERE	ID = @BillingServiceID
  	
    IF (@IsEArrest = 1)
      BEGIN
	      UPDATE dbo.EArrestService
	      SET	PricePerBeacon = @Price,
			      BeaconLimit = @NumberOfBeacons,
			      Rate = @Rate
	      WHERE	ClassicBillingServiceID = (SELECT ID FROM ClassicBillingService WHERE BillingServiceID = @BillingServiceID)
      END
  END TRY
  
  -- // Catch and Return Errors // --
  BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber,
           ERROR_SEVERITY() AS ErrorSeverity,
           ERROR_STATE() as ErrorState,
           ERROR_PROCEDURE() as ErrorProcedure,
           ERROR_LINE() as ErrorLine,
           ERROR_MESSAGE() as ErrorMessage;
           
    -- // Rollback outstanding transactions // --
    IF @@TRANCOUNT > 0
	    BEGIN
		    ROLLBACK TRANSACTION
	    END;
  END CATCH;

-- // Commit Tran // --
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION
	END;
GO

GRANT EXECUTE ON [dbo].[BillingServiceUpdate] TO db_dml;
GO