USE [TrackerPal]															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GeoRuleUpdateFileID2]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GeoRuleUpdateFileID2]
GO

/* **********************************************************
 * FileName:   [GeoRuleUpdateFileID2].sql
 * Created On: <DateTime>         
 * Created By: <Developer>  
 * Task #:		 <Redmine #>      
 * Purpose:                   
 *
 * Modified By: <Name> - <DateTime>
 * ******************************************************** */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GeoRuleUpdateFileID2] (
	@GeoRuleID					INT,
	@FileID						INT
)
AS
UPDATE GeoRule
SET FileID = @FileID,
    UpdateInProgress = 0
WHERE	GeoRuleID = @GeoRuleID
GO

GRANT EXECUTE ON [dbo].[GeoRuleUpdateFileID2] TO db_dml;
GO
