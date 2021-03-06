USE TrackerPal															
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[DaylightProgressUpdateActionInstanceEArrest]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[DaylightProgressUpdateActionInstanceEArrest]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO
-- =============================================
-- Author:		Sajid Abbasi
-- Create date: 12-Mar-2010
-- Description:	This procedure updates Action Instance ID in 
-- DaylightUpdateProgressEArrest so that we have track of rules that are 
-- updated. 
-- =============================================
CREATE PROCEDURE [dbo].[DaylightProgressUpdateActionInstanceEArrest]
	@TrackerID int,
	@ActionInstanceID bigint
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	DaylightUpdateProgressEArrest
	SET		ActionInstanceID = @ActionInstanceID,
			ActionInstanceIDTime = GetDate()
	WHERE	TrackerID = @TrackerID
END

GRANT EXECUTE ON [dbo].[DaylightProgressUpdateActionInstanceEArrest] TO db_dml;
GO 