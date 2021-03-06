/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [ReportUpdate]

	@ReportID		INT,
	@ReportName		NVARCHAR(50),
	@FilterSet		XML,
	@FieldSet		XML

AS

	UPDATE	Reports
	SET		ReportName = @ReportName,
			FilterSet = @FilterSet,
			FieldSet = @FieldSet
			
	WHERE	ReportID = @ReportID
GO
GRANT EXECUTE ON [ReportUpdate] TO [db_dml]
GO
GRANT VIEW DEFINITION ON [ReportUpdate] TO [db_object_def_viewers]
GO
