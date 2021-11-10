USE TrackerPal
GO

IF NOT EXISTS (SELECT * FROM dbo.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[Accounting]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  BEGIN
    CREATE TABLE dbo.Accounting ( 
	    AccountID        	int IDENTITY(1,1) NOT NULL,
	    ID               	int NOT NULL,
	    CustomerName     	nvarchar(50) NULL,
	    CustomerAccountId	nvarchar(50) NULL,
	    CustomerType     	int NOT NULL,
	    BillingRate      	money NULL,
	    BillingPer       	int NULL,
	    DiscountRate     	decimal(18,2) NULL,
	    TaxRate          	decimal(18,2) NULL,
	    CreateDate       	datetime NOT NULL,
	    ModifiedDate     	datetime NULL,
	    ModifiedBy       	int NOT NULL,
	    Deleted          	bit NOT NULL,
	    CONSTRAINT PK_Accounting PRIMARY KEY(AccountID)
    )
  END
GO
