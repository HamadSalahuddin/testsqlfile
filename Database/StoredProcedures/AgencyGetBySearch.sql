/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:26 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [AgencyGetBySearch]

	@Agency		NVARCHAR(50),
	@City		NVARCHAR(50),
	@StateID	INT,
	@RoleID		INT = -1,
	@UserID		INT = -1

AS
    IF (@RoleID <> 6 AND @RoleID <> 19)

        BEGIN

                                SELECT  a.AgencyID, a.Agency, a.City, s.State

                                FROM    Agency a

                                LEFT JOIN State s ON a.StateID = s.StateID



                                WHERE   (

                                                        (LEN(@Agency) <= 0)

                                                        or

                                                        (a.Agency  LIKE '%' + @Agency + '%')

                                                )

                                                 AND

                                                (

                                                        (LEN(@City) <= 0)

                                                        or

                                                        (a.City = @City )

                                                )

                                                AND

                                                (

                                                        (@StateID = 0)

                                                        or

                                                        (a.StateID = @StateID)

                                                )

                                                 AND

                                                a.Deleted = 0

                                ORDER BY a.Agency

        END

	IF @RoleID = 6
        
            BEGIN

                    SELECT  a.AgencyID, a.Agency, a.City, s.State

                            FROM    Agency a

                            LEFT JOIN State s ON a.StateID = s.StateID

                            INNER JOIN distributoremployee de on a.DistributorID=de.DistributorID AND de.UserID=@UserID

                            WHERE   (

                                                    (LEN(@Agency) <= 0)

                                                    or

                                                    (a.Agency  LIKE '%' + @Agency + '%')

                                            )

                                             AND

                                            (

                                                    (LEN(@City) <= 0)

                                                    or

                                                    (a.City = @City)

                                            )

                                            AND

                                            (

                                                    (@StateID = 0)

                                                    or

                                                    (a.StateID = @StateID)

                                            )

                                             AND

                                            a.Deleted = 0

                            ORDER BY a.Agency

		END

	IF @RoleID = 19

            BEGIN

                    SELECT  a.AgencyID, a.Agency, a.City, s.State

                            FROM    Agency a

                            LEFT JOIN State s ON a.StateID = s.StateID

							LEFT JOIN Distributor d ON d.DistributorID = a.DistributorID

							LEFT JOIN User_Role ur ON d.TamID = ur.UserID

                            WHERE   			ur.UserID = @UserID AND
											(

                                                    (LEN(@Agency) <= 0)

                                                    or

                                                    (a.Agency  LIKE '%' + @Agency + '%')

                                            )

                                             AND

                                            (

                                                    (LEN(@City) <= 0)

                                                    or

                                                    (a.City = @City)

                                            )

                                            AND

                                            (

                                                    (@StateID = 0)

                                                    or

                                                    (a.StateID = @StateID)

                                            )

                                             AND

                                            a.Deleted = 0

                            ORDER BY a.Agency

		END

GO
GRANT VIEW DEFINITION ON [AgencyGetBySearch] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [AgencyGetBySearch] TO [db_dml]
GO
