/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleGetAllByAgencyID]

	@AgencyID					INT,
	@AgencyGeoRuleCategoryID	INT

AS

	IF @AgencyID = 0
	BEGIN
		SELECT	GeoRuleID, GeoRuleName
		FROM	GeoRule
		WHERE	GeoRuleTypeID = @AgencyGeoRuleCategoryID
		ORDER BY GeoRuleName
	END
	ELSE
	BEGIN
		SELECT	g.GeoRuleID, g.GeoRuleName
		FROM	GeoRule g
		INNER JOIN GeoRule_Agency a ON g.GeoRuleID = a.GeoRuleID
		WHERE	a.AgencyID = @AgencyID AND
				g.GeoRuleTypeID = @AgencyGeoRuleCategoryID
		ORDER BY g.GeoRuleName
	END
GO
GRANT VIEW DEFINITION ON [GeoRuleGetAllByAgencyID] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRuleGetAllByAgencyID] TO [db_dml]
GO
