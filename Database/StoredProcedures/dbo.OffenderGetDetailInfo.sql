/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderGetDetailInfo]

	@OffenderID	INT

AS

	SELECT	ISNULL(o.FirstName + ' ', '') + 
			ISNULL(o.MiddleName + ' ', '') +
			ISNULL(o.LastName + ' ', '') AS 'OffenderName',
			ISNULL(f.FirstName + ' ', '') + 
			ISNULL(f.MiddleName + ' ', '') +
			ISNULL(f.LastName + ' ', '') AS 'OfficerName',
			ISNULL(o.HomeStreet1 + ' ', '') +
			ISNULL(o.HomeStreet2 + ' ', '') +
			ISNULL(o.HomeCity + ', ', '') +
			ISNULL(s.State + ' ', '') AS 'Address',
			ISNULL(r.RiskLevel, '') AS 'RiskLevel',
			ISNULL(o.BirthDate, '') AS 'BirthDate',
			ISNULL(o.CaseNumber,'') AS 'CaseNumber',
			ISNULL(ta.TrackerID, '') AS 'TrackerID'
	FROM	Offender o
	LEFT JOIN Offender_Officer oo ON o.OffenderID = oo.OffenderID
	LEFT JOIN Officer f ON oo.OfficerID = f.OfficerID
	LEFT JOIN State s ON o.HomeStateOrProvinceID = s.StateID
	LEFT JOIN OffenderRiskLevel r ON o.RiskLevelID = r.RiskLevelID
	LEFT JOIN TrackerAssignment ta ON o.OffenderID = ta.OffenderID
	WHERE	o.OffenderID = @OffenderID
GO
GRANT VIEW DEFINITION ON [OffenderGetDetailInfo] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [OffenderGetDetailInfo] TO [db_dml]
GO