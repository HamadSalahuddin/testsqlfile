/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [BillingServiceOptionAdd] 
@IsRequired BIT, 
@IsOptional BIT, 
@BillingServiceID INT, 
@ReportingIntervalID INT,
@Cost FLOAT,
@NewID INT OUTPUT
AS
--Saves new billing service option record.
SET NOCOUNT ON;

--Check for outstanding transactions
IF @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION
	END;

BEGIN TRANSACTION;
BEGIN TRY
	INSERT INTO dbo.BillingServiceOption(IsRequired, IsOptional, BillingServiceID)
VALUES	(@IsRequired,@IsOptional, @BillingServiceID);
	--VALUES	(0,1,95);
	SET @NewID = @@IDENTITY
	INSERT INTO dbo.BillingServiceOptionReportingInterval(BillingServiceOptionID, ReportingIntervalID, Cost)
VALUES	(@NewID,@ReportingIntervalID,@Cost)
	--VALUES	(101,2,5.00)
END TRY
BEGIN CATCH
	--Catch and return error.
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() as ErrorState,
        ERROR_PROCEDURE() as ErrorProcedure,
        ERROR_LINE() as ErrorLine,
        ERROR_MESSAGE() as ErrorMessage;
	--Rollback outstanding transactions.
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END;
END CATCH;

IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION
	END;





GO
GRANT EXECUTE ON [BillingServiceOptionAdd] TO [db_dml]
GO
