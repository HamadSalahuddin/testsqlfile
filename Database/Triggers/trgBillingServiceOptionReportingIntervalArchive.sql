/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:24:57 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: TRIGGER
*/
CREATE TRIGGER [dbo].[trgBillingServiceOptionReportingIntervalArchive]
ON dbo.BillingServiceOptionReportingInterval
FOR UPDATE,DELETE
NOT FOR REPLICATION
AS
BEGIN TRAN;
INSERT INTO dbo.BillingServiceOptionReportingInterval_Historical(BillingServiceOptionID,ReportingIntervalID,Cost)
SELECT BillingServiceOptionID,ReportingIntervalID,Cost
FROM deleted;
COMMIT TRAN;
GO
