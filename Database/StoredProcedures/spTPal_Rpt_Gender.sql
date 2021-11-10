USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Rpt_Gender]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Rpt_Gender]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
/* **********************************************************
 * FileName:   spTPal_Rpt_Gender.sql
 * Created On: 8/3/2012
 * Created By: C.Voros (Ported to sproc by R.Cole)
 * Task #:     N/A
 * Purpose:    Automate a report used by Accounting for OSAJ            
 *
 * Modified By: Name - DateTime
 * ******************************************************** */
CREATE PROCEDURE [dbo].[spTPal_Rpt_Gender] 
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
   
-- // Main Query // --
SELECT FirstName + ' ' + LastName AS Offender,
       ISNULL(GenderAbbreviation,'?') AS Gender
FROM Offender
  LEFT OUTER JOIN Gender ON Offender.GenderID = Gender.GenderID
WHERE AgencyID IN (985,1499,1535,1576,1577,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587)

GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[spTPal_Rpt_Gender] TO db_dml;
GO