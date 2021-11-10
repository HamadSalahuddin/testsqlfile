USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Agn_GetByDistributorID]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Agn_GetByDistributorID]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Agn_GetByDistributorID.sql
 * Created On: 02/13/2012         
 * Created By: R.Cole 
 * Task #:     
 * Purpose:    Return the agencies under a distributor               
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Agn_GetByDistributorID] (
  @DistributorID INT
) 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;     

--DECLARE @DistributorID INT
--SET @DistributorID = 1

-- // Main Query // --
SELECT AgencyID,
       Agency
FROM Agency
WHERE DistributorID = @DistributorID
  AND Agency.Deleted = 0

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Agn_GetByDistributorID] TO db_dml;
GO