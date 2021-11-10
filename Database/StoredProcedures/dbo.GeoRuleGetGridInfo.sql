/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [GeoRuleGetGridInfo]

	@AgencyID	INT,
	@OfficerID	INT

AS

	IF @AgencyID = 0 AND @OfficerID = 0
	BEGIN
		SELECT	g.GeoRuleID, g.GeoRuleName, t.GeoRuleType, c.GeoRuleCategory
		FROM	GeoRule g
		LEFT JOIN GeoRuleType t ON g.GeoRuleTypeID = t.GeoRuleTypeID
		LEFT JOIN GeoRuleCategory c ON g.GeoRuleCategoryID = c.GeoRuleCategoryID
		WHERE g.Deleted = 0
		ORDER BY c.GeoRuleCategory, t.GeoRuleType, g.GeoRuleName
	END
	ELSE
	BEGIN
		IF @AgencyID <> 0 AND @OfficerID = 0
		BEGIN
			SELECT	g.GeoRuleID, g.GeoRuleName, t.GeoRuleType, c.GeoRuleCategory
			FROM	GeoRule g
			LEFT JOIN GeoRuleType t ON g.GeoRuleTypeID = t.GeoRuleTypeID
			LEFT JOIN GeoRuleCategory c ON g.GeoRuleCategoryID = c.GeoRuleCategoryID
			INNER JOIN GeoRule_Agency a ON g.GeoRuleID = a.GeoRuleID
			WHERE a.AgencyID = @AgencyID
            AND g.Deleted = 0
			ORDER BY c.GeoRuleCategory, t.GeoRuleType, g.GeoRuleName
		END
		ELSE
		BEGIN
			IF @AgencyID = 0 AND @OfficerID <> 0
			BEGIN
				SELECT	g.GeoRuleID, g.GeoRuleName, t.GeoRuleType, c.GeoRuleCategory
				FROM	GeoRule g
				LEFT JOIN GeoRuleType t ON g.GeoRuleTypeID = t.GeoRuleTypeID
				LEFT JOIN GeoRuleCategory c ON g.GeoRuleCategoryID = c.GeoRuleCategoryID
				INNER JOIN GeoRule_Officer o ON g.GeoRuleID = o.GeoRuleID
				WHERE	o.OfficerID = @OfficerID
				AND g.Deleted = 0
				ORDER BY c.GeoRuleCategory, t.GeoRuleType, g.GeoRuleName
			END
		END
	END




GO
GRANT EXECUTE ON [GeoRuleGetGridInfo] TO [public]
GO
GRANT VIEW DEFINITION ON [GeoRuleGetGridInfo] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [GeoRuleGetGridInfo] TO [db_dml]
GO
