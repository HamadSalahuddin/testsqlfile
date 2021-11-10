USE TrackerPal
GO

IF NOT EXISTS (SELECT * FROM dbo.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[ActiveDeviceStatus]') AND OBJECTPROPERTY(ID, N'IsUserTable') = 1)
  BEGIN
    CREATE TABLE dbo.ActiveDeviceStatus ( 
	    DeviceId               	uniqueidentifier NOT NULL,
	    PendingScheduleId      	uniqueidentifier NULL,
	    ActiveScheduleId       	uniqueidentifier NULL,
	    DeviceXml              	nvarchar(max) NOT NULL,
	    InProgressGatewayAction	bigint NULL,
	    CONSTRAINT PK_ActiveDeviceStatus PRIMARY KEY(DeviceId)
    )
  END
GO
