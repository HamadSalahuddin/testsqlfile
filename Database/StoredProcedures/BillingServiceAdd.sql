USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[BillingServiceAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[BillingServiceAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   BillingServiceAdd.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     
 * Purpose:    Adds a Billing Service to an Agency               
 *
 * Modified By: S.Abbasi - 01/14/2011: Added Disabled Flag
 *              R.Cole - 01/14/2011: Added DROP IF EXISTS 
 *                and GRANT stmts.  General edits to bring up
 *                to coding standard.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[BillingServiceAdd] (
    @CreatedByID INT, 
    @CreatedDate DATETIME, 
    @AgencyID INT, 
    @StartDateTime DATETIME, 
    @BillingServiceTypeID INT, 
    @NumberOfBeacons INT,
    @Price FLOAT,
    @IsEArrest BIT,
    @ServiceID INT,
    @Rate FLOAT,
    @Disabled BIT = 0,
    @NewID INT OUTPUT
)
AS
SET NOCOUNT ON;
DECLARE @ClassicID INT;

-- // Check for latent transactions // --
IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION
	END;

-- // Begin Tran // --
BEGIN TRANSACTION;
  BEGIN TRY
	  INSERT INTO dbo.BillingService(
	                CreatedByID,
	                CreatedDate,
	                AgencyID,
	                StartDateTime, 
	                BillingServiceTypeID,
	                [Disabled]
	              )
	  VALUES(
	         @CreatedByID,
	         @CreatedDate,
	         @AgencyID,
	         @StartDateTime,
	         @BillingServiceTypeID,
	         @Disabled
	        )
  	      
	  SET @NewID = SCOPE_IDENTITY();

	  INSERT INTO dbo.ClassicBillingService(BillingServiceID, ServiceID)
	    VALUES(@NewID, @ServiceID)
  	
	  SET @ClassicID = SCOPE_IDENTITY();

	  IF (@IsEArrest = 1)
	    BEGIN
			    INSERT INTO dbo.EArrestService(ClassicBillingServiceID,
			                                   PricePerBeacon,
			                                   BeaconLimit,
			                                   Rate
			                                  )
			      VALUES(@ClassicID,
			             @Price,
			             @NumberOfBeacons,
			             @Rate
			            )
	    END
  END TRY
  
  -- // Catch and Return Error // --
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

GRANT EXECUTE ON [dbo].[BillingServiceAdd] TO db_dml;
GO

