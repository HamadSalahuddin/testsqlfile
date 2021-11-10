USE [TrackerPal]
GO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE id = OBJECT_ID(N'[dbo].[spTPal_Bcn_GetByRole]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spTPal_Bcn_GetByRole]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   spTPal_Bcn_GetByRole.sql
 * Created On: 19-July-2014
 * Created By: Hamad Salahuddin	
 * Task #:     6603
 * Purpose:    Returns Unassigned Beacons Role Wise
 * Modified    H.Salahuddin 23-July-2014 Added Sort by serialNum for both the roles
 *		   H.Salahuddin 01-Aug-2014 Added parameter OldAgency having Default Value null,
 *			    Made the query daynamic by adding the Agency wise filteration
 *			D. Riding	14-Jan-2015  Updated how it determines if Beacon is already assigned. Since BeaconOffender is used for Beacon and Beacons table there is overlap in IDs, so check it is assumed now that if the Agency in the Beacons table and the Agency in teh Offender table is the same (which would be necessary for Beacon function) it is probably a new Beacon and not an old Beacon. 	
 *			R.Cole 3/2/2015 - Added defaults of NULL to @OldAgency and @Query, cleaned up the formatting for readability and accordance with coding standard.
 * **********************************************************/
CREATE PROCEDURE [dbo].[spTPal_Bcn_GetByRole] (
	@RoleID INT, 
	@UserID INT,
	@OldAgency INT = NULL, 
	@Query NVARCHAR(MAX) = NULL
)
AS
BEGIN
	IF @RoleID = 6 
    BEGIN
	    -- // if role is distributor then we should bring all unassigned beacons of agencies for that distributor. // --
	    DECLARE	@DistributorID INT
	    SELECT @DistributorID = DistributorID FROM DistributorEmployee WHERE UserID = @UserID AND Deleted = 0	
	
	    SET @Query = 'SELECT b.BeaconID, SerialNum, BeaconName, AgencyID, CreatedDate, CreatedByID, ModifiedDate, ModifiedByID, Deleted
	                  FROM [TrackerPal].[dbo].[Beacons] AS b
	                  WHERE b.BeaconID NOT IN(SELECT bo.BeaconID 
	                                          FROM BeaconOffender bo
			                                      INNER JOIN Beacons b ON b.BeaconID = bo.BeaconID
			                                      INNER JOIN Offender o ON o.OffenderID = bo.OffenderID
			                                      WHERE b.AgencyID = o.AgencyID
				                                      AND b.Deleted = 0) ' ;
      -- // All Agency // --
	    IF @OldAgency IS NULL 
	      BEGIN
		      SET	@Query = @Query + ' AND AgencyID IN (SELECT AgencyID
												                           FROM [Trackerpal].[Dbo].[Agency]
												                           WHERE Deleted = 0 AND DistributorID <> 0
												                             AND DistributorID = @DistributorID) ' ;
	      END
	    ELSE 
	      -- // Filter by AgencyID // --
	      BEGIN
		      SET @Query  = @Query + ' AND AgencyID = @OldAgency ' ;
	      END
	    SET @Query = @Query + '	AND Deleted = 0	ORDER BY SerialNum ASC ';
    END
  ELSE
    IF @RoleID = 4
      -- // if role is appliction Admin then all unassigned beacons regardless of agencies will be returned. // --
      BEGIN
	      SET @Query = 'SELECT b.BeaconID, SerialNum, BeaconName, AgencyID, CreatedDate, CreatedByID, ModifiedDate, ModifiedByID, Deleted
	                    FROM [TrackerPal].[dbo].[Beacons] AS b	
	                      -- Agency filtering
	                    WHERE b.BeaconID NOT IN(SELECT bo.BeaconID 
	                                            FROM BeaconOffender bo
			                                        INNER JOIN Beacons b ON b.BeaconID = bo.BeaconID
			                                        INNER JOIN Offender o ON o.OffenderID = bo.OffenderID
			                                        WHERE b.AgencyID = o.AgencyID
				                                        AND b.Deleted = 0) ' ;
				-- // Filter by AgencyID // --                                        
	      IF @OldAgency IS NOT NULL
	        BEGIN
		        SET @Query = @Query + 'AND b.AgencyID = @OldAgency ';
	        END
	      SET @Query = @Query + ' AND Deleted = 0	ORDER BY SerialNum ASC '
      END
      
  -- // Execute final query // --
  EXECUTE sp_executesql @Query,N'@OldAgency int, @DistributorID int',@OldAgency = @OldAgency,@DistributorID=@DistributorID
END
GO

GRANT EXECUTE ON [dbo].[spTPal_Bcn_GetByRole] TO db_dml;
GO


