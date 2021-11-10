USE [Trackerpal]
GO
/****** Object:  StoredProcedure [dbo].[AlarmProtocolActionGetBySetIDEventID]    Script Date: 11/09/2013 15:11:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* **********************************************************
 * FileName:   AlarmProtocolActionGetBySetIDEventID.sql
 * Created On: Unknown         
 * Created By: Aculis, Inc.
 * Task #:     N/A
 * Purpose:    Return protocol actions to the TrackerPAL UI               
 *
 * Modified By: Sohail Khaliq - 8/6/2013: Per #4237, Changed 
 *              ORDER BY to include [TYPE]
 *              R.Cole - 8/6/2013: Revised to meet standard.
 * ******************************************************** */
ALTER PROCEDURE [dbo].[AlarmProtocolActionGetBySetIDEventID] (
  @AlarmProtocolSetID		INT,
	@AlarmProtocolEventID	INT
) 
AS
-- // Main Query // --
SELECT apa.AlarmProtocolActionID, 
       apa.AlarmProtocolSetID, 
       apa.AlarmProtocolEventID, 
			 apa.[Type],
       apa.Priority, 
			 CASE apa.Priority WHEN '*' THEN 0 ELSE CONVERT(INT , Priority) END AS 'OrderPriority',
       apa.[From], 
       apa.[To], 
       apa.[Action], 
       apa.Recipient, 
			 apa.ContactInfo, 
       apa.Retry, 
       apa.Note, 
       aps.AlarmProtocolSetTypeID
FROM AlarmProtocolAction apa
  LEFT OUTER JOIN AlarmProtocolSet aps ON	apa.AlarmProtocolSetID = aps.AlarmProtocolSetID
WHERE	apa.AlarmProtocolSetID = @AlarmProtocolSetID 
  AND apa.AlarmProtocolEventID = @AlarmProtocolEventID 
  AND apa.Deleted = 0
ORDER BY [type],
         OrderPriority
