/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:24:57 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: TRIGGER
*/
CREATE TRIGGER [dbo].[AlarmProtocolActionCreate] 
   ON  dbo.[AlarmProtocolAction] 
   AFTER DELETE, INSERT, UPDATE
AS 
BEGIN

    -- Insert statements for trigger here

		BEGIN
			INSERT INTO AlarmProtocolChangeLog (ModifiedDate,
			ModifiedByID,OriginalValues,NewValues,AlarmProtocolActionID)
			SELECT GetDate(),i.ModifiedByID,
			'Type:' +d.[Type] + ' - ' +
			'Priority:'+d.Priority + ' - ' +
			'From:'+d.[From] + ' - ' +
			'To:'+d.[To] + ' - ' +
			'Action:'+d.[Action] + ' - ' +
			'Recipient:'+d.Recipient + ' - ' +
			'ContactInfo:'+d.ContactInfo + ' - ' +
			'Retry:'+d.Retry + ' - ' +
			'Note:'+d.Note + ' - ' +
			'CreatedDate:'+ cast(d.CreatedDate as varchar) + ' - ' +
			'CreatedByID:'+ cast(d.CreatedByID as varchar) + ' - ' +
			'ModifiedDate:'+ cast(d.ModifiedDate as varchar) + ' - ' +
			'ModifiedByID:'+ cast(d.ModifiedByID as varchar) + ' - ' +
			'Deleted:'+ cast(d.Deleted as varchar),
			'Type:'+i.[Type] + ' - ' +
			'Priority:'+i.Priority + ' - ' +
			'From:'+i.[From] + ' - ' + 
			'To:'+i.[To] + ' - ' +
			'Action:'+i.[Action] + ' - ' +
			'Recipient:'+i.Recipient + ' - ' +
			'ContactInfo:'+i.ContactInfo + ' - ' +
			'Retry:'+i.Retry + ' - ' +
			'Note:'+i.Note + ' - ' +
			'CreatedDate:'+ cast(i.CreatedDate as varchar) + ' - ' +
			'CreatedByID:'+ cast(i.CreatedByID as varchar) + ' - ' +
			'ModifiedDate:'+ cast(i.ModifiedDate as varchar) + ' - ' +
			'ModifiedByID:'+ cast(i.ModifiedByID as varchar) + ' - ' +
			'Deleted:'+ cast(i.Deleted as varchar),
			d.AlarmProtocolActionID FROM 
			deleted d inner join inserted i
			ON d.AlarmProtocolActionID = i.AlarmProtocolActionID

			If @@Error<> 0
			BEGIN
				RAISERROR ('Error update change log', 16, 1)
				Rollback Transaction
			END
		END
END
GO
