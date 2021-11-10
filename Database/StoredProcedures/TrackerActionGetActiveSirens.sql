USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[TrackerActionAddActiveSiren]    Script Date: 7/1/2013 10:44:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TrackerActionAddActiveSiren] (
  @TrackerActionID bigint, 
  @TrackerID int, 
  @OffenderID int
)
AS
BEGIN
	SET NOCOUNT ON;
IF EXISTS (SELECT 1 FROM ActiveSirens WHERE TrackerID = @TrackerID)
BEGIN
	UPDATE ActiveSirens
	SET TrackerActionID = @TrackerActionID, OffenderID = @OffenderID
	WHERE TrackerID = @TrackerID
END

ELSE

BEGIN
	INSERT INTO ActiveSirens 
	(TrackerActionID, TrackerID, OffenderID)
	VALUES
	(@TrackerActionID, @TrackerID, @OffenderID)
END

END
GO

-- // Grant Permissions - This statement MUST be present, do not remove // --
GRANT EXECUTE ON [dbo].[TrackerActionAddActiveSiren] TO db_dml;
GO