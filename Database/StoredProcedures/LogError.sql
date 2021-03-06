/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [LogError]
 @ID	bigint OUTPUT,
 @TypeID int,
 @TimeStamp DateTime,
 @ClassName varchar(100),
 @FunctionName varchar(100),
 @Message varchar(200),
 @Exception varchar(1000)
AS
insert into LogErrors (TypeID,TimeStamp,ClassName,FunctionName,[Message],Exception) VALUES 
(@TypeID,@TimeStamp,@ClassName,@FunctionName,@Message,@Exception)
    
SET @ID = @@IDENTITY
GO
GRANT VIEW DEFINITION ON [LogError] TO [db_object_def_viewers]
GO
GRANT EXECUTE ON [LogError] TO [db_dml]
GO
