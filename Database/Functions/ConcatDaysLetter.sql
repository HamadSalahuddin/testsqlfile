USE TrackerPal
GO

CREATE FUNCTION [dbo].[ConcatDaysLetter] (
  @ScheduleID int
)  

RETURNS VARCHAR(50) AS   
  BEGIN   
    DECLARE @retvalue VARCHAR(50)  
    SET @retvalue='';  
    SELECT @retvalue = @retvalue + LTRIM(RTRIM(ISNULL(Short_Name,'')))+','  
    FROM (SELECT Short_Name 
          FROM dbo.ScheduleRepeatedDay s 
            INNER JOIN dbo.refDay r ON r.ID=s.DayID 
          WHERE s.ScheduleID = @ScheduleID) AS tmp_tbl  
 
    IF (@retvalue <> '')
	    SET @retvalue = SUBSTRING(@retvalue,1,LEN(@retvalue)-1)
    RETURN @retvalue
END  
GO
