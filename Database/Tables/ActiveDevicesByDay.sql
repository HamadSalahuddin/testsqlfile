USE TrackerPal
GO

IF NOT EXISTS (SELECT * FROM dbo.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[ActiveDevicesByDay]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  BEGIN
    CREATE TABLE dbo.ActiveDevicesByDay ( 
	    [Date] 	datetime NULL,
	    Total	int NULL 
	)
  END
GO
