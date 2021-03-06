USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[GetExistingERuleFromAddDaylightProcess]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetExistingERuleFromAddDaylightProcess]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
-- =============================================
-- Author:		<Sajid Abbasi>
-- Create date: <12-Mar-2010>
-- Description:	<Procedure that gets list of all EArrest rules that have not
-- yet been uploaded for DaylightSave adjustment>
-- =============================================
CREATE PROCEDURE [dbo].[GetExistingERuleFromAddDaylightProcess]
	
AS

BEGIN
	SELECT DaylightUpdateProgressEArrestID,  
       TrackerID,  
       OffenderID  
FROM DaylightUpdateProgressEArrest  
WHERE FileID IS NULL  
ORDER BY DaylightUpdateProgressEArrestID  
END
GO

GRANT EXECUTE ON [dbo].[GetExistingERuleFromAddDaylightProcess] TO db_dml;
GO 
