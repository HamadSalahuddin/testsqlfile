/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mOffenderContactUpdate]
	@ID int,
	@FirstName nvarchar(35),
	@LastName nvarchar(40),
	@RelationShip nvarchar(50) = null,
	@HomePhone nvarchar(15) = null,
	@MobilePhone nvarchar(15) = null,
	@WorkPhone nvarchar(15) = null,
	@AltPhone1 nvarchar(15) = null,
	@AltPhone2 nvarchar(15) = null,
	@Email1 nvarchar(15) = null,
	@Email2 nvarchar(15) = null

AS
BEGIN
	
	SET NOCOUNT ON;
    	UPDATE Contacts SET
		FirstName = @FirstName,
		LastName = @LastName,
		RelationShip = @RelationShip,
		HomePhone = @HomePhone,
		MobilePhone = @MobilePhone,
		WorkPhone= @WorkPhone,
		AltPhone1=@AltPhone1,
		AltPhone2=@AltPhone2,
		Email1=@Email1,
		Email2=@Email2
where ID = @ID
END

GO
GRANT EXECUTE ON [mOffenderContactUpdate] TO [db_dml]
GO
