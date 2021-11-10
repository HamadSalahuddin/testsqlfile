USE TrackerPal
GO

IF NOT EXISTS (SELECT * FROM dbo.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[AccountingBillingPerType]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  BEGIN
    CREATE TABLE dbo.AccountingBillingPerType ( 
	    BillingPerTypeID  	tinyint NOT NULL,
	    BillingPerTypeName	nchar(10) NOT NULL,
	    CONSTRAINT PK_AccountingBillingPeriodType PRIMARY KEY(BillingPerTypeID)
    )
  END
GO
