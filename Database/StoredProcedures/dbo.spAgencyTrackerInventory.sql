/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [spAgencyTrackerInventory]
@Agencyid int


As 
SELECT
--       d.[Name]
		  dp5.PropertyValue AS 'Gateway Serial Number'
        ,a.Agency

         ,(CASE When t1.CreatedDate IS NULL Then 'N/A' Else CONVERT(char(25),DATEADD(mi,-420,t1.CreatedDate),101)END) AS 'AgencyAssignmentDate'
         ,(CASE When t1.trackeruniqueid IS NOT NULL THEN opr2.FirstNAme+' '+opr2.LastName
           ELSE 'Not Assigned' END)AS 'Assigned By'
		     ,(
				CASE
					WHEN t1.Deleted = 1
				THEN CONVERT(char(25),DateADD(mi,-420,t1.ModifiedDate),101)
             ELSE ''
				END )AS 'Agency Un-AssignmentDate'
,(CASE When t1.Deleted = 1 THEN opr.FirstNAme+' '+opr.LastName
 ELSE 'Assigned' END)AS 'Un-Assigned By'
,(CASE When ofi.Officerid IS NULL THEN 'NotAssigned'
ELSE ofi.FirstNAme+' '+ofi.LastName END)As 'Officer Name'	 
,(CASE When o.Offenderid IS NULL THEN 'Not Assigned'
ELSE o.FirstNAme+' '+o.LastNAme END)AS 'Assigned Offender'
			,CONVERT(char(25),DATEADD(mi,-360,ta.AssignmentDate),101) As 'AssignmentDate'
      ,(CASE 
          WHEN ta.Trackerassignmenttypeid = 1 Then 'Assigned'
          Else 'Unassigned' END) As 'AssignmentStatus'
--,(CASE When ta.AssignmentDate Is NULL Then 'N/A' ELSE CONVERT(char(25),DATEADD(mi,-420,ta.AssignmentDate),101)END) AS 'AssignmentDate'
--,(CASE When ta3.AssignmentDate Is NULL Then 'N/A' ELSE CONVERT(char(25),DATEADD(mi,-420,ta3.AssignmentDate),101)END) AS 'Un-AssignmentDate'
		  

FROM gateway.dbo.devices d WITH (NoLock)
LEFT JOIN (SELECT TrackerID, Max(TrackerActivationID) AS ActivationID FROM OffenderTrackerActivation WITH (NOLOCK) GROUP BY TrackerID) AS ota1 ON ota1.TrackerID = d.deviceID
LEFT JOIN (SELECT TrackerID, Max(TrackerAssignmentID) AS AssignmentID FROM TrackerAssignment WITH (NOLOCK)GROUP BY TrackerID) AS ta1 ON ta1.TrackerID = d.deviceid
--LEFT JOIN (SELECT TrackerID, Max(TrackerAssignmentID) AS AssignmentID FROM TrackerAssignment WITH (NOLOCK) Where TrackerAssignmenttypeid = 2 GROUP BY TrackerID) AS ta2 ON ta2.TrackerID = d.deviceid
LEFT JOIN (SELECT TrackerID, Max(TrackerUniqueID) As uniqueid FROM Tracker WITH (NOLOCK) Group BY Trackerid) AS t ON t.trackerid = d.deviceid
LEFT JOIN Gateway.dbo.DeviceProperties dp5 ON d.DeviceID = dp5.DeviceID AND dp5.PropertyID = '8012'
LEFT JOIN OffenderTrackerActivation ota ON ota.TrackerActivationID = ota1.ActivationID
LEFT JOIN TrackerAssignment ta ON ta.TrackerAssignmentID = ta1.AssignmentID
--LEFT JOIN TrackerAssignment ta3 ON ta3.TrackerAssignmentID = ta2.AssignmentID
LEFT JOIN tracker t1 on t.uniqueid = t1.trackeruniqueid
JOIN Agency a ON t1.AgencyID = a.AgencyID
LEFT JOIN Offender o ON o.Offenderid = ta.Offenderid
LEFT JOIN Officer ofi ON ofi.Officerid = ta.supervisionOfficerid
LEFT JOIN Operator opr ON opr.userid = t1.ModifiedById
LEFt JOIN Operator opr2 ON opr2.userid = t1.createdByid
Where a.agencyid =@Agencyid
ORDER BY a.agency










GO
GRANT EXECUTE ON [spAgencyTrackerInventory] TO [db_dml]
GO
