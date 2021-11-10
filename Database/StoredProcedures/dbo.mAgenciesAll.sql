/*
Script generated by Aqua Data Studio 8.0.2 on Jan-15-2010 01:50:27 PM
Database: TrackerPal
Schema: <All Schemas>
Objects: PROCEDURE
*/
CREATE PROCEDURE [mAgenciesAll]

AS
BEGIN
SELECT 
AgencyID,
Agency,
StreetLine1,
StreetLine2,
City,
Agency.StateID,
st.State,
PostalCode,
Agency.CountryID,
Phone,
Fax,
URL,
EmailAddress,
CreatedDate,
CreatedByID,
ModifiedDate,
ModifiedByID,
Deleted,
OnCallPhone,
OnCallEmail,
OnCallPager,
TimeZoneID,
DayLightSavings,
DistributorID,
SMSAddress,
SMSGatewayID,
SFDCAccount

FROM Agency 
left join State st on st.StateID = Agency.StateID

WHERE Deleted = 0
ORDER BY Agency
END

GO
GRANT EXECUTE ON [mAgenciesAll] TO [db_dml]
GO
