/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [DistributorGetBySearch]




        @Distributor         NVARCHAR(50),

        @City           NVARCHAR(50),

        @StateID        INT,

        @RoleID         INT = -1,

        @UserID         INT = -1



AS

    IF (@RoleID <> 6 AND @RoleID <> 19)

        BEGIN

                               SELECT  d.DistributorID, d.DistributorName, d.City, s.State

                                FROM    Distributor d

                                LEFT JOIN State s ON d.StateID = s.StateID



                                WHERE   (

                                                        (LEN(@Distributor) <= 0)

                                                        or

                                                        (d.DistributorName  LIKE '%' + @Distributor + '%')

                                                )

                                                 AND

                                                (

                                                        (LEN(@City) <= 0)

                                                        or

                                                        (d.City = @City )

                                                )

                                                AND

                                                (

                                                        (@StateID = 0)

                                                        or

                                                        (d.StateID = @StateID)

                                                )

                                                 AND

                                                d.Deleted = 0

                                ORDER BY d.DistributorName

        END

	IF @RoleID = 6
        
            BEGIN

                    SELECT  d.DistributorID, d.DistributorName, d.City, s.State

                            FROM    Distributor d

                            LEFT JOIN State s ON d.StateID = s.StateID

                            INNER JOIN distributoremployee de on d.DistributorID=de.DistributorID AND de.UserID=@UserID

                            WHERE   (

                                                    (LEN(@Distributor) <= 0)

                                                    or

                                                    (d.DistributorName  LIKE '%' + @Distributor + '%')

                                            )

                                             AND

                                            (

                                                    (LEN(@City) <= 0)

                                                    or

                                                    (d.City = @City)

                                            )

                                            AND

                                            (

                                                    (@StateID = 0)

                                                    or

                                                    (d.StateID = @StateID)

                                            )

                                             AND

                                            d.Deleted = 0

                            ORDER BY d.DistributorName

		END

	IF @RoleID = 19

            BEGIN

                    SELECT  d.DistributorID, d.DistributorName, d.City, s.State

                            FROM    

                            State  s INNER JOIN
							Distributor  d ON s.StateID = d.StateID LEFT OUTER JOIN
							User_Role AS ur ON d.TamID = ur.UserID

                            WHERE   			ur.UserID = @UserID AND
											(

                                                    (LEN(@Distributor) <= 0)

                                                    or

                                                    (d.DistributorName LIKE '%' + @Distributor + '%')

                                            )

                                             AND

                                            (

                                                    (LEN(@City) <= 0)

                                                    or

                                                    (d.City = @City)

                                            )

                                            AND

                                            (

                                                    (@StateID = 0)

                                                    or

                                                    (d.StateID = @StateID)

                                            )

                                             AND

                                            d.Deleted = 0

                            ORDER BY d.DistributorName

		END


GO
GRANT EXECUTE ON [DistributorGetBySearch] TO [db_dml]
GO
