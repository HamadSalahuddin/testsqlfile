USE [TrackerPal]
GO
/****** Object:  StoredProcedure [dbo].[spTPal_Ofn_ReportingIntervalGetByOffenderID]    Script Date: 08/11/2016 06:31:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Ofn_ReportingIntervalGetByOffenderID.sql
 * Created On: 05/06/2016         
 * Created By: H.Salahuddin 
 * Task #:     Task9802
 * Purpose:    To Get the Offender Device Reporting Interval             
 *
 * Modified By: 
* ******************************************************** */
ALTER PROCEDURE [dbo].[spTPal_Ofn_ReportingIntervalGetByOffenderID] 
	@TimeSeconds INT OUTPUT,
	@OffenderID INT   

AS  
  
--Procedure returns data about and Agencies billing services.  
  
SET NOCOUNT ON;  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  

set @TimeSeconds=(SELECT top 1 rs.TimeSeconds
FROM dbo.OptionalBillingServiceOptionOffender ob 
INNER JOIN dbo.BillingServiceOptionReportingInterval bor ON ob.BillingServiceOptionID = bor.BillingServiceOptionID 
INNER JOIN dbo.refServiceOptionReportingInterval rs ON bor.ReportingIntervalID = rs.ID 

WHERE ob.OffenderID = @OffenderID) 

if @TimeSeconds is NULL 

set @TimeSeconds=(SELECT top 1 rs.TimeSeconds
FROM dbo.BillingService b 
INNER JOIN dbo.BillingServiceOption o ON b.ID = o.BillingServiceID 
INNER JOIN dbo.BillingServiceOptionReportingInterval bor ON o.ID = bor.BillingServiceOptionID 
INNER JOIN dbo.refServiceOptionReportingInterval rs ON bor.ReportingIntervalID = rs.ID 
INNER JOIN dbo.OffenderOptionalBillingService offs ON b.ID = offs.BillingServiceID 
WHERE offs.OffenderID = @OffenderID) 
 
if @TimeSeconds is NULL 

set @TimeSeconds=(SELECT top 1 rs.TimeSeconds 
FROM dbo.BillingService b 
INNER JOIN dbo.BillingServiceOption o ON b.ID = o.BillingServiceID 
INNER JOIN dbo.BillingServiceOptionReportingInterval bor ON o.ID = bor.BillingServiceOptionID 
INNER JOIN dbo.refServiceOptionReportingInterval rs ON bor.ReportingIntervalID = rs.ID 
Inner join dbo.offender ofe on ofe.Agencyid= b.agencyid
WHERE ofe.offenderID = @OffenderID and b.BillingservicetypeID=1)

if @TimeSeconds is NULL
BEGIN
declare @temp2 table (val int)
insert @temp2 (val) exec OffenderServiceGetTimeInterval @offenderID
set @TimeSeconds = (select * from @temp2)
END

if @TimeSeconds is NULL 
set @TimeSeconds=-1

Select @TimeSeconds as ReportingInterval