USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DistributorAdd]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DistributorAdd]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   DistributorAdd.sql
 * Created On: Unknown
 * Created By: Aculis, Inc
 * Task #:     N/A
 * Purpose:    Add a distributor record               
 *
 * Modified By: R.Cole - 8/20/2012: Enforced Assign and 
 *              Activate are set to 1.
 * ******************************************************** */
CREATE PROCEDURE [DistributorAdd] (
	@DistributorID		INT OUTPUT,
	@TamID				INT,
	@DistributorName	NVARCHAR(50),
	@StreetLine1	NVARCHAR(50),
	@StreetLine2	NVARCHAR(50),
	@City			NVARCHAR(50),
	@StateID		INT,
	@PostalCode		NVARCHAR(25),
	@CountryID		INT,
	@Phone			NVARCHAR(25),
	@Fax			NVARCHAR(25),
	@URL			NVARCHAR(50),
	@EmailAddress	NVARCHAR(50),
	@CreatedByID	INT,
	@Assign bit,
  @Activate bit
)
AS
SET NOCOUNT ON;

INSERT INTO Distributor	(
  DistributorName, 
  StreetLine1, 
  StreetLine2, 
  City, 
  StateID, 
  PostalCode, 
	CountryID, 
  Phone, 
  Fax, 
  URL, 
  EmailAddress, 
  CreatedByID, 
  CreatedDate, 
  TamID,
  Assign,
  Activate
)
VALUES (
  @DistributorName, 
  @StreetLine1, 
  @StreetLine2, 
  @City, 
  @StateID, 
  @PostalCode, 
	@CountryID, 
  @Phone, 
  @Fax, 
  @URL, 
  @EmailAddress, 
  @CreatedByID, 
  GetDate(), 
  @TamID,
  1, --@Assign,
  1 --@Activate
)

SET @DistributorID = @@IDENTITY
GO

GRANT EXECUTE ON [DistributorAdd] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [DistributorAdd] TO [db_object_def_viewers]
GO
