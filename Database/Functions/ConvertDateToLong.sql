USE TrackerPal

-- // converts DateTime to long date format // --
CREATE FUNCTION [dbo].[ConvertDateToLong] (
  @Date DATETIME
)

RETURNS BIGNINT
WITH SCHEMABINDING
AS

BEGIN 
  DECLARE @Result BIGINT, 
          @float FLOAT, 
          @bigint BIGINT
  SET @float = CONVERT(FLOAT, @Date) 
  SET @bigint = CONVERT(BIGINT, FLOOR(@float))
  
  SET @Result = CONVERT(BIGINT, (@bigint + 109207) * 864000000000 + CONVERT(BIGINT, FLOOR(ABS(@bigint - @float) * 864000000000)) ) 

  RETURN @Result
END
GO
