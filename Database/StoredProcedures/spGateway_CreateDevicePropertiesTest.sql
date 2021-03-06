USE [Gateway]
GO
/****** Object:  StoredProcedure [dbo].[spGw_Otd_CreateDeviceProperties]    Script Date: 03/26/2016 06:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/* **********************************************************
 * FileName:   spGateway_CreateDevicePropertiesTest.sql
 * Created On: 10/Nov/2015
 * Created By: H.Salahuddin
 * Task #:     
 * Purpose:    This procedure will be called for saving a device properties to its parallel server stack.  
 * Modified By: Sahib -Removed Primary Server Address Check.
 * ******************************************************** */
-- =============================================
ALTER PROCEDURE [dbo].[spGw_Otd_CreateDeviceProperties]
	@DevicePropertyTypeList NVARCHAR(MAX),
	@UniqueID VARCHAR(32)
AS
BEGIN
	DECLARE	@hDoc INT,
            @NSEndPos INT,
            @PropertyID CHAR(4),
            @PropertyName VARCHAR(64),
            @DeviceID INT
            SELECT @NSEndPos = PATINDEX('%>%', @DevicePropertyTypeList) + 1
            SELECT @DevicePropertyTypeList =  SUBSTRING(@DevicePropertyTypeList,@NSEndPos,LEN(@DevicePropertyTypeList) - @NSEndPos +1)
            EXEC sp_xml_preparedocument @hDoc OUTPUT, @DevicePropertyTypeList
            
			DECLARE @getDevicePropertyTypeList CURSOR
            SET @getDevicePropertyTypeList = CURSOR FOR
		    
			SELECT PropertyID, PropertyName           
			FROM OPENXML(@hdoc,'/DevicePropertyTypeList/DevicePropertyType',3) 		--'/DevicePropertyTypeList/DevicePropertyType',3 [means, read the root node as well as attribute node.
			WITH (PropertyID CHAR(4), PropertyName VARCHAR(64))
		
			OPEN @getDevicePropertyTypeList 
				FETCH NEXT FROM @getDevicePropertyTypeList  
				INTO @PropertyID,  @PropertyName
		       
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF NOT EXISTS (SELECT * FROM DevicePropertyTypes WHERE PropertyID = @PropertyID)
				BEGIN
					INSERT INTO [DevicePropertyTypes] (	 [PropertyID], [PropertyName] )
			   	    VALUES (  @PropertyID, @PropertyName )
				END
			    ELSE
				BEGIN
					UPDATE [DevicePropertyTypes]  SET	PropertyName = @PropertyName					
					WHERE  PropertyID = @PropertyID
			    END
			
				SELECT @DeviceID = DeviceID FROM [Devices] WHERE UniqueID = @UniqueID AND Deleted = 0
			
				IF @@ERROR = 0
				  BEGIN
					  IF NOT EXISTS (SELECT * FROM DeviceProperties WHERE DeviceID = @DeviceID AND PropertyID = @PropertyID)
						  BEGIN
				   			 INSERT INTO [DeviceProperties] (
										  [DeviceID],
										  [PropertyID],
										  [PropertyValue],
											[State],
											[Notify],
											[Dirty]
										)
									  VALUES (
										  @DeviceID, 
										  @PropertyID, 
										  @PropertyName,
											0,
											1,
											0
										)
						  END
					  ELSE
						  BEGIN
							  UPDATE [DeviceProperties]    SET PropertyValue = @PropertyName
							  WHERE DeviceID = @DeviceID  AND PropertyID = @PropertyID
						  END				
				  END
				FETCH NEXT FROM @getDevicePropertyTypeList  INTO @PropertyID, @PropertyName
	        END
	-- // Cleanup // --  
	CLOSE @getDevicePropertyTypeList 
	DEALLOCATE @getDevicePropertyTypeList 
		
	IF @@ERROR = 0 
	  SELECT 'SUCCESS'
	ELSE
		SELECT 'FAIL'	
		
END
