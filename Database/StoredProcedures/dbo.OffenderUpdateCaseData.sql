/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [OffenderUpdateCaseData]
	@iOffenderID int,
	@sCaseCourtName nvarchar(50) = null,
	@sCaseJudgeName nvarchar(50) = null,
	@sCaseDistrictAttorney nvarchar(50) = null,
	@sCaseAssignedAgency nvarchar(50) = null,
	@sCaseNcicNumber nvarchar(max) = null,
	@sCaseBailBondAgent nvarchar(50) = null,
	@sCaseBailBondPhone nvarchar(50) = null,
	@sCaseBailBondAmount nvarchar(50) = null,
	@sCaseCriminalHistoryNotes nvarchar(2000) = null

AS
BEGIN

	SET NOCOUNT ON;

	UPDATE Offender SET
	
	CaseCourtName = @sCaseCourtName,
	CaseJudgeName = @sCaseJudgeName,
	CaseDistrictAttorney = @sCaseDistrictAttorney,
	CaseAssignedAgency = @sCaseAssignedAgency,
	CaseNcicNumber = @sCaseNcicNumber,
	CaseBailBondAgent =@sCaseBailBondAgent,
	CaseBailBondPhone = @sCaseBailBondPhone,
	CaseBailBondAmount = @sCaseBailBondAmount,
	CaseCriminalHistoryNotes = @sCaseCriminalHistoryNotes

	WHERE OffenderID = @iOffenderID

END

GO
GRANT EXECUTE ON [OffenderUpdateCaseData] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [OffenderUpdateCaseData] TO [db_object_def_viewers]
GO
