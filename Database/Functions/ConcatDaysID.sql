
CREATE FUNCTION [dbo].[ConcatDaysID] (
  @ScheduleID INT
)  
RETURNS VARCHAR(50) AS   
  BEGIN   
    DECLARE @retvalue VARCHAR(50)  
    SET @retvalue='';  
  
    SELECT @retvalue = @retvalue + LTRIM(RTRIM(ISNULL(DayID,'')))+','  
    FROM (SELECT DayID 
          FROM dbo.ScheduleRepeatedDay 
          WHERE ScheduleRepeatedDay.ScheduleID = @ScheduleID) AS tmp_tbl  
 
    IF (@retvalue<>'')
	    SET @retvalue = SUBSTRING(@retvalue,1,LEN(@retvalue)-1)
    RETURN @retvalue
END  
GO
