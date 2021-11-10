/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mCurrentAssignmentAndActivations]

AS
BEGIN
SELECT
ta.Trackerassignmentid
,ta.Trackerid
,o.Offenderid
,ofi.Officerid
,ta.AssignmentDate
,ta.CreatedBy
,ta.CreatedDate
,ota.Offenderid
,ota.TrackerActivationId
,ota.ActivateDate
,o.Victim
,o.VictimAssociatedOffenderID as 'OffenderForVictimID'
,ota3.Trackerid as 'OffenderForVictimTrackerID'
,o2.offenderid As 'VictimForOffenerID'
,ota5.trackerid as 'VictimForOffenderTrackerID'

FROM (SELECT TrackerID, MAX(TrackerassignmentID) AS maxassignment FROM Trackerassignment GROUP BY Trackerid) ta1
JOIN Trackerassignment ta ON ta.Trackerassignmentid = ta1.maxassignment
LEFT JOIN (SELECT trackerid, MAX(Trackeractivationid) As Maxactivation From Offendertrackeractivation Where deactivatedate IS NULL Group BY trackerid) ota1 ON ota1.trackerid = ta.trackerid
LEFT JOIN Offendertrackeractivation ota ON ota.Trackeractivationid = ota1.Maxactivation
JOIN Offender o ON o.Offenderid = ta.Offenderid
JOIN Officer ofi ON ofi.Officerid = ta.Supervisionofficerid
LEFT JOIN (SELECT Offenderid, MAX(Trackeractivationid) As Maxactivation From Offendertrackeractivation Group BY Offenderid) ota2 ON ota2.offenderid = o.VictimAssociatedOffenderID 
LEFT JOIN Offendertrackeractivation ota3 ON ota2.maxactivation = ota3.trackeractivationid 
And ota3.DeactivateDate IS NULL
LEFT JOIN Offender o2 ON o2.VictimAssociatedOffenderID = o.Offenderid AND o2.Offenderid IN 
(Select Offenderid From Offendertrackeractivation Where deactivatedate IS NULL)
LEFt JOIN Offendertrackeractivation ota5 On o2.Offenderid = ota5.Offenderid And ota5.deactivatedate is NULL



Where ta.Trackerassignmenttypeid = 1
Order By o.Offenderid
END



GO
GRANT EXECUTE ON [mCurrentAssignmentAndActivations] TO [db_dml]
GO
