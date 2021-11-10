/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:24:57 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: TRIGGER
*/
CREATE TRIGGER [dbo].[GeoRuleActiveTrigger] 
   ON  dbo.[GeoRule] 
   AFTER INSERT, UPDATE, DELETE
AS 
BEGIN

	If @@ROWCOUNT = 0
		Return
    -- Delete old GeoRules that are no longer active...
	Delete dbo.GeoRuleActive WHERE GeoRuleID IN (SELECT GeoRuleID FROM Inserted WHERE StatusID = 3)


	BEGIN
		     Insert into GeoRuleActive( GeoRuleID, GeoRuleName, GeoRuleShapeID,
                              GeoRuleTypeID, GeoRuleReferencePointID, GeoRuleScheduleID,
                              Longitude, Latitude, Radius, Width, Height, Longitudes, Latitudes,
							  AlarmInstructions, CreatedDate, CreatedByID,ModifiedDate,ModifiedByID,
							  Deleted, StatusID, FileID, UpdateinProgress)
			    Select i.GeoRuleID, i.GeoRuleName, i.GeoRuleShapeID,
                              i.GeoRuleTypeID, i.GeoRuleReferencePointID, i.GeoRuleScheduleID,
                              i.Longitude, i.Latitude, i.Radius, i.Width, i.Height, i.Longitudes, i.Latitudes,
							  i.AlarmInstructions, i.CreatedDate, i.CreatedByID,i.ModifiedDate,i.ModifiedByID,
							  i.Deleted, i.StatusID, i.FileID, i.UpdateinProgress From inserted i
							  WHERE i.StatusID = 3
	END
END
GO
