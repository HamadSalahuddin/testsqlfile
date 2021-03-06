USE [Trackerpal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[OffenderOptionalBillingServiceOptionAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[OffenderOptionalBillingServiceOptionAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   OffenderOptionalBillingServiceOptionAdd.sql
 * Created On: Unknown
 * Created By: Aculis, Inc. 
 * Task #:     
 * Purpose:    
 *
 * Modified By: R.Cole - 01/14/2011: Updated for readability 
 *                brought up to coding std.
 *              R.Cole - 04/06/2012: Added check for an existing
 *                record prior to insert.
 * ******************************************************** */
CREATE PROCEDURE [dbo].[OffenderOptionalBillingServiceOptionAdd] (
	  @UserID	INT,
	  @BillingServiceOptionID	INT,
	  @OffenderID INT,
    @NumberOfBeacon INT = NULL
) 
AS

-- // Check for the existance of a record before inserting // --
IF NOT EXISTS (SELECT 1 FROM OptionalBillingServiceOptionOffender WHERE BillingServiceOptionID = @BillingServiceOptionID AND OffenderID = @OffenderID)
  BEGIN  
    INSERT INTO OptionalBillingServiceOptionOffender (
      BillingServiceOptionID,
      OffenderID,
      CreatedByID,
      BeaconCount
    )
    VALUES (
      @BillingServiceOptionID,
      @OffenderID,
      @UserID,
      @NumberOfBeacon
    ) 
  END

IF @BillingServiceOptionID NOT IN (SELECT BillingServiceOptionID 
                                   FROM OffenderserviceBilling WITH (NOLOCK) 
                                   WHERE OffenderID = @OffenderID 
                                      AND Active = 1) AND @OffenderID IN (SELECT OffenderID 
                                                                          FROM OffenderTrackerActivation WITH (NOLOCK) 
                                                                          WHERE DeactivateDate IS NULL)
  BEGIN
    UPDATE OffenderserviceBilling 
      SET EndDate = GETDATE(),
          Active = 0 
      WHERE OffenderID = @OffenderID 
        AND Active = 1
        
	    INSERT INTO [trackerpal].[dbo].[OffenderServiceBilling] (
	        [OffenderID],
          [StartDate],
          [EndDate],
          [BillingServiceOptionID],
          [ServiceID],
          [ReportingInterval],
          [Cost],
          [Active],
          [TrackerID],
          [IsDemo],
			    [BillableID]
			)
	    SELECT @OffenderID,
				     GETDATE(),
				     NULL,
				     @BillingServiceOptionID,
				     ISNULL(cbs.ServiceID,1),
             sori.[Name],
				     bsori.Cost,
				     1,
             ota.TrackerID,
             ota.IsDemo,
             ota.BillableID
	    FROM Offender o WITH (NOLOCK)
        LEFT JOIN dbo.OptionalBillingServiceOptionOffender obsoo WITH (NOLOCK) ON obsoo.OffenderID = o.OffenderID
	      LEFT JOIN BillingServiceOption bso WITH (NOLOCK) ON bso.id = obsoo.BillingServiceOptionID
	      LEFT JOIN dbo.BillingServiceOptionReportingInterval bsori WITH (NOLOCK) ON bsori.BillingServiceOptionID = bso.ID
	      LEFT JOIN dbo.refServiceOptionReportingInterval sori WITH (NOLOCK) ON sori.id = bsori.ReportingIntervalID
	      LEFT JOIN ClassicBillingService cbs WITH (NOLOCK) ON cbs.BillingServiceID = bso.BillingServiceID
        INNER JOIN OffenderTrackerActivation ota WITH (NOLOCK) ON ota.OffenderID = o.OffenderID AND ota.DeactivateDate IS NULL
	    WHERE o.OffenderID = @OffenderID 
	      AND cbs.ServiceID NOT IN (SELECT ServiceID
                                  FROM OffenderServiceBilling 
                                  WHERE OffenderID = @OffenderID 
                                    AND ServiceID = cbs.ServiceID 
                                    AND Active = 1) 
   END
GO

GRANT EXECUTE ON [dbo].[OffenderOptionalBillingServiceOptionAdd] TO db_dml;
GO