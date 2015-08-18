#!/usr/local/bin/python

from simple_salesforce import Salesforce 
import pyodbc 
import numpy
import time

start_time = time.clock()

#  connection to Salesforce

sf = Salesforce(username='stephan.curiskis@nearmap.com',
	password='1618Andrejs3', security_token='8aS5IG3gW5mNOIoCZvKzC3pM')

# Extract Accounts modified or created today or yesterday
columns= ['ABN__c', 'AccessRights__c', 'AccessScript__c', 'AccountSource', 'AnnualRevenue', 'Balance__c', 'BalanceActionsEmail__c', 
	'BalanceChangeAction__c', 'BillingCity', 'BillingCountry', 'BillingInfo__c', 'BillingInfoNeeded__c', 'BillingLatitude', 
	'BillingLongitude', 'BillingPlatformAccountId__c', 'BillingPlatformId__c', 'BillingPostalCode', 'BillingState', 'BillingStreet', 
	'CaseSafeAccountID__c', 'CreatedById', 'CreatedDate', 'Culture__c', 'Currency__c', 'Description', 'DidAcceptCompanySizeLimit__c', 
	'DidAcceptCoverageDoc__c', 'Domain__c', 'Fax', 'Geographical_Interest__c', 'Id', 'Industry', 'Is_Active__c', 'IsBlacklist__c', 
	'IsDeleted', 'Jigsaw', 'JigsawCompanyId', 'LastActivity__c', 'LastActivityDate', 'LastActivityDetails__c', 'LastLoginFailure__c',
	 'LastModifiedById', 'LastModifiedDate', 'LastReferencedDate', 'LastViewedDate', 'LicenceInfo__c', 'ManagedByNearmap__c', 
	 'MasterRecordId', 'Migrated__c', 'MirrorId__c', 'Name', 'NumberOfEmployees', 'OwnerId', 'ParentId', 'Password__c', 'PasswordClear__c',
	  'Phone', 'Sector__c', 'SessionPolicy__c', 'ShippingCity', 'ShippingCountry', 'ShippingLatitude', 'ShippingLongitude', 'ShippingPostalCode', 
	  'ShippingState', 'ShippingStreet', 'SicDesc', 'Size_of_Business__c', 'Source_Addresses__c', 'SubscriptionNeedsSync__c', 'SystemModstamp', 
	  'TsAndCsInfo__c', 'Type', 'Type_of_Business__c', 'UsageLimitPolicy__c', 'Username__c', 'Vertical__c', 'WebData__c', 'Website',
    'ActivatedContract__c', 'ExpectedUsage__c', 'Hold_Correspondences__c', 'Mirror_Id__c', 'PlanCode__c', 'RecordTypeId', 'Region__c', 
    'Estimated_Upsell_Amount__c', 'Marketing_Segment__c']

result = sf.query_all('''SELECT {} FROM Account
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

# Establish connection to SQL Server.  NOTE: this only works on Windows with an ODBC connection setup with DSN = 'SQLServer'

cnxn = pyodbc.connect('DSN=SQL Server') 
cursor = cnxn.cursor()

#cursor.execute("DROP TABLE Staging.STG.Account")
#cursor.execute("DROP TABLE Staging.STG.Lead")
#cursor.execute("DROP TABLE Staging.STG.Contact")
#cursor.execute("DROP TABLE Staging.STG.Opportunity")
#cursor.execute("DROP TABLE Staging.STG.Task")
#cursor.execute("DROP TABLE Staging.STG.Campaign")
#cursor.execute("DROP TABLE Staging.STG.AccountHistory")
#cursor.execute("DROP TABLE Staging.STG.CampaignMember")
#cursor.execute("DROP TABLE Staging.STG.CampaignMemberStatus")
#cursor.execute("DROP TABLE Staging.STG.OpportunityLineItem")
#cursor.execute("DROP TABLE Staging.STG.Groups")
#cursor.execute("DROP TABLE Staging.STG.Contract")
#cursor.execute("DROP TABLE Staging.STG.OpportunityHistory")
#cursor.execute("DROP TABLE Staging.STG.Pricebook")
#cursor.execute("DROP TABLE Staging.STG.PricebookEntry")
#cursor.execute("DROP TABLE Staging.STG.Product")
#cursor.execute("DROP TABLE Staging.STG.RecentUsage")
#cursor.execute("DROP TABLE Staging.STG.TransactionReportItems")
#cursor.execute("DROP TABLE Staging.STG.UserRole")
#cursor.execute("DROP TABLE Staging.STG.ContractContactRole")
#cursor.execute("DROP TABLE Staging.STG.Users")
#cnxn.commit() 

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)



cursor.execute("CREATE TABLE Staging.STG.Account ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Account VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Leads

# Extract Accounts modified or created today or yesterday
columns= ['Account__c','Alternate_Email__c','AnnualRevenue','Charity_Reg_Number_or_ABN__c','City','Close_Date__c','Company',
	'ConvertedAccountId','ConvertedContactId','ConvertedDate','ConvertedOpportunityId','Country','Coverage_Requested__c',
	'Created_Date_Date_Only__c','CreatedById','CreatedDate','Description','Deskcom__twitter_username__c','Email','EmailBouncedDate',
	'EmailBouncedReason','ExpectedUsage__c','FirstName','Geographical_Interest__c','Id','Industry','Industry_Description_Detail__c',
	'InviteCode__c','IsConverted','IsDeleted','IsUnreadByOwner','Jigsaw','JigsawContactId','LastActivityDate','LastModifiedById',
	'LastModifiedDate','LastName','LastReferencedDate','LastViewedDate','Latitude','Lead_Prioritisation_Score__c','LeadSource',
	'Longitude','Marketing__c','MarketoTrackingCookieId__c','MasterRecordId','mkto2__Acquisition_Date__c','mkto2__Acquisition_Program__c',
	'mkto2__Acquisition_Program_Id__c','mkto2__Inferred_City__c','mkto2__Inferred_Company__c','mkto2__Inferred_Country__c',
	'mkto2__Inferred_Metropolitan_Area__c','mkto2__Inferred_Phone_Area_Code__c','mkto2__Inferred_Postal_Code__c',
	'mkto2__Inferred_State_Region__c','mkto2__Lead_Score__c','mkto2__Original_Referrer__c','mkto2__Original_Search_Engine__c'
	,'mkto2__Original_Search_Phrase__c','mkto2__Original_Source_Info__c','mkto2__Original_Source_Type__c','MobilePhone','Name',
	'Number_Of_Users__c','NumberOfEmployees','OwnerId','Parent_Company__c','Phone','PostalCode','PreferredCallTime__c',
	'Primary_Contact__c','Probability__c','Rating','Salutation','Size_of_Business__c','State','Status','Street',
	'Subscribe_me_to_the_nearmap_newsletter__c','SystemModstamp','Time_Since_Last_Activity__c','Title','Type_of_Business__c',
	'Value__c','Website','Vertical__c']

result = sf.query_all('''SELECT {} FROM Lead
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)



cursor.execute("CREATE TABLE Staging.STG.Lead ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Lead VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Contacts

# Extract Accounts modified or created today or yesterday
columns= ['AccessRights__c','AccountId','AssistantName','AssistantPhone','Balance__c','Birthdate','CaseSafeContactID__c',
	'CreatedById','CreatedDate','Department','Description','Email','Email_Domain__c','EmailBouncedDate','EmailBouncedReason',
	'EmailValidatedStamp__c','EmailValidationRequired__c','Fax','FirstName','Free_Commercial_Email__c','HomePhone','Id',
	'Is_Active__c','IsDeleted','Jigsaw','JigsawContactId','LastActivity__c','LastActivityDate','LastActivityDetails__c',
	'LastCURequestDate','LastCUUpdateDate','LastLoginFailure__c','LastModifiedById','LastModifiedDate','LastName',
	'LastReferencedDate','LastViewedDate','LeadSource','LegacyEmail__c','LegacyUsername__c','LicenceInfo__c','Linkedin_Profile__c',
	'MailingCity','MailingCountry','MailingLatitude','MailingLongitude','MailingPostalCode','MailingState','MailingStreet',
	'MasterRecordId','MirrorId__c','mkto2__Acquisition_Date__c','mkto2__Acquisition_Program__c','mkto2__Acquisition_Program_Id__c',
	'mkto2__Inferred_City__c','mkto2__Inferred_Company__c','mkto2__Inferred_Country__c','mkto2__Inferred_Metropolitan_Area__c',
	'mkto2__Inferred_Phone_Area_Code__c','mkto2__Inferred_Postal_Code__c','mkto2__Inferred_State_Region__c','mkto2__Lead_Score__c',
	'mkto2__Original_Referrer__c','mkto2__Original_Search_Engine__c','mkto2__Original_Search_Phrase__c','mkto2__Original_Source_Info__c',
	'mkto2__Original_Source_Type__c','MobilePhone','Name','NewsLetter__c','OtherCity','OtherCountry','OtherLatitude','OtherLongitude',
	'OtherPhone','OtherPostalCode','OtherState','OtherStreet','OwnerId','Password__c','PasswordClear__c','Phone','Primary_Contact__c',
	'RegisteredDate__c','ReportsToId','Salutation','SmsUpdates__c','SystemModstamp','Title','TsAndCsInfo__c','Username__c',
	'ValidationEmailSentStamp__c','ValidationEmailToken__c','Verification_Emails_Sent_Count__c','VerificationEmailStatus__c']

result = sf.query_all('''SELECT {} FROM Contact
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Contact ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Contact VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Opportunity

# Extract Accounts modified or created today or yesterday
columns= ['AccountId','Amount','Amount_Estimate__c','Amount_Override__c','CampaignId','Category__c','CloseDate','CreatedById',
	'CreatedDate','Date_For_Exception_Term_Payment_Receipt__c','Days_till_close__c','Description','Exception_Payment_Terms__c',
	'Fiscal','FiscalQuarter','FiscalYear','ForecastCategory','ForecastCategoryName','Group_Package_Purchased__c',
	'HasOpportunityLineItem','Id','Invoice_Date__c','Invoice_Number__c','IsClosed','IsDeleted','IsWon','LastActivityDate',
	'LastModifiedById','LastModifiedDate','LastReferencedDate','LastViewedDate','LeadSource','Licence_Period__c','Name',
	'NextStep','OwnerId','Previous_Contract_Value__c','Pricebook2Id','Probability','Renewal_Date__c','Renewal_Invoice_Only__c',
	'StageName','SyncedQuoteId','SystemModstamp','Total_Contract_Value_exc_GST__c','Total_Number_of_Seats__c','Type',
	'UpgradeFrom__c']

result = sf.query_all('''SELECT {} FROM Opportunity
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Opportunity ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Opportunity VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Task

# Extract Accounts modified or created today or yesterday
# removed description field because it takes too long to run
columns= ['AccountId','ActivityDate','CallDisposition','CallDurationInSeconds','CallObject','CallType','CreatedById',
	'CreatedDate','Id','IsArchived','IsClosed','IsDeleted','IsRecurrence','IsReminderSet','LastModifiedById',
	'LastModifiedDate','OwnerId','Priority','RecordTypeId','RecurrenceActivityId','RecurrenceDayOfMonth',
	'RecurrenceDayOfWeekMask','RecurrenceEndDateOnly','RecurrenceInstance','RecurrenceInterval','RecurrenceMonthOfYear',
	'RecurrenceStartDateOnly','RecurrenceTimeZoneSidKey','RecurrenceType','ReminderDateTime','Status','Subject','SystemModstamp',
	'WhatId','WhoId']

result = sf.query_all('''SELECT {} FROM Task
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Task ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Task VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Account History

# Extract Accounts modified or created today or yesterday
columns= ['AccountId','CreatedById','CreatedDate','Field','Id','IsDeleted','NewValue','OldValue']

result = sf.query_all('''SELECT {} FROM AccountHistory
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.AccountHistory ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.AccountHistory VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Campaign

# Extract Accounts modified or created today or yesterday
columns= ['ActualCost','AmountAllOpportunities','AmountWonOpportunities','BudgetedCost','CampaignMemberRecordTypeId',
	'CreatedById','CreatedDate','Description','EndDate','ExpectedResponse','ExpectedRevenue','Id','IsActive',
	'IsDeleted','LastActivityDate','LastModifiedById','LastModifiedDate','LastReferencedDate','LastViewedDate',
	'Name','NumberOfContacts','NumberOfConvertedLeads','NumberOfLeads','NumberOfOpportunities','NumberOfResponses',
	'NumberOfWonOpportunities','NumberSent','OwnerId','ParentId','StartDate','Status','SystemModstamp','Type']

result = sf.query_all('''SELECT {} FROM Campaign
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Campaign ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Campaign VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Campaign Member

# Extract Accounts modified or created today or yesterday
columns= ['CampaignId','ContactId','CreatedById','CreatedDate','FirstRespondedDate','HasResponded','Id',
	'IsDeleted','LastModifiedById','LastModifiedDate','LeadId','Status','SystemModstamp']

result = sf.query_all('''SELECT {} FROM CampaignMember
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.CampaignMember ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.CampaignMember VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## Campaign Member

# Extract Accounts modified or created today or yesterday
columns= ['CampaignId','CreatedById','CreatedDate','HasResponded','Id','IsDefault','IsDeleted','Label',
	'LastModifiedById','LastModifiedDate','SortOrder','SystemModstamp']

result = sf.query_all('''SELECT {} FROM CampaignMemberStatus
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.CampaignMemberStatus ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.CampaignMemberStatus VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Opportunity Line Item

# Extract Accounts modified or created today or yesterday
columns= ['CreatedById','CreatedDate','CurrencyIsoCode','Description','Dimension_1__c','Dimension_2__c','Dimension_3__c',
	'Dimension_4__c','Discounted_Unit_Price__c','HasQuantitySchedule','HasRevenueSchedule','HasSchedule','Id','IsDeleted',
	'LastModifiedById','LastModifiedDate','ListPrice','OpportunityId','PricebookEntryId','Quantity','ServiceDate',
	'SortOrder','SystemModstamp','TotalPrice','UnitPrice']

result = sf.query_all('''SELECT {} FROM OpportunityLineItem
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.OpportunityLineItem ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.OpportunityLineItem VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Contracts

# Extract Accounts modified or created today or yesterday
columns= ['AccountId','ActivatedById','ActivatedDate','BillingCity','BillingCountry','BillingLatitude',
	'BillingLongitude','BillingPlatformId__c','BillingPostalCode','BillingState','BillingStreet','CompanySignedDate',
	'CompanySignedId','ContractNumber','ContractTerm','CreatedById','CreatedDate','CustomerSignedDate',
	'CustomerSignedId','CustomerSignedTitle','Description','EndDate','Id','IsDeleted','IsPerSeatAllowance__c',
	'IsSuspended__c','LastActivityDate','LastApprovedDate','LastModifiedById','LastModifiedDate','LastReferencedDate',
	'LastViewedDate','MirrorId__c','OwnerExpirationNotice','OwnerId','PhotoMapAllowanceMegabytesPerSeat__c',
	'Postcodes__c','Product_01__c','Product_01_Info__c','Product_02__c','Product_02_Info__c','Product_03__c',
	'Product_03_Info__c','PropertyReportsAllowance__c','Quantity_01__c','Quantity_02__c','Quantity_03__c',
	'ShippingCity','ShippingCountry','ShippingLatitude','ShippingLongitude','ShippingPostalCode','ShippingState',
	'ShippingStreet','SpecialTerms','StartDate','Status','StatusCode','SystemModstamp','TerminationDate__c']

result = sf.query_all('''SELECT {} FROM Contract
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Contract ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Contract VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Groups

# Extract Accounts modified or created today or yesterday
columns= ['CreatedById','CreatedDate','DeveloperName','DoesIncludeBosses','DoesSendEmailToMembers','Email'
	,'Id','LastModifiedById','LastModifiedDate','Name','OwnerId','RelatedId','SystemModstamp','Type']

result = sf.query_all('''SELECT {} FROM Group
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Groups ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Groups VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Opportunity History

# Extract Accounts modified or created today or yesterday
columns= ['Amount','CloseDate','CreatedById','CreatedDate','ExpectedRevenue','ForecastCategory','Id','IsDeleted'
	,'OpportunityId','Probability','StageName','SystemModstamp']

result = sf.query_all('''SELECT {} FROM OpportunityHistory
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.OpportunityHistory ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.OpportunityHistory VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Pricebook

# Extract Accounts modified or created today or yesterday
columns= ['CreatedById','CreatedDate','Description','Id','IsActive','IsDeleted','IsStandard','LastModifiedById',
	'LastModifiedDate','LastReferencedDate','LastViewedDate','Name','SystemModstamp']

result = sf.query_all('''SELECT {} FROM Pricebook2
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Pricebook ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Pricebook VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Pricebook Entry

# Extract Accounts modified or created today or yesterday
columns= ['CreatedById','CreatedDate','Id','IsActive','IsDeleted','LastModifiedById','LastModifiedDate','Name'
	,'Pricebook2Id','Product2Id','ProductCode','SystemModstamp','UnitPrice','UseStandardPrice']

result = sf.query_all('''SELECT {} FROM PricebookEntry
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.PricebookEntry ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.PricebookEntry VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Product

# Extract Accounts modified or created today or yesterday
columns= ['AccessKeys__c','AddOnCode__c','Availability__c','CreatedById','CreatedDate','Description',
	'E_Commerce_Multi_Licence_Packages__c','Family','Id','IntervalLength__c','IntervalUnit__c','IsActive','IsDeleted'
	,'LastModifiedById','LastModifiedDate','MirrorId__c','Name','NeedsEmailVerification__c','NumberOfQuantityInstallments',
	'NumberOfRevenueInstallments','NumberOfSeats__c','PackageId__c','PhotoMapAllowanceMegabytesPerSeat__c','PlanCode__c'
	,'PooledPropertyReportsAllowanceOnSignup__c','Product_Info__c','ProductCode','QuantityInstallmentPeriod'
	,'QuantityScheduleType','RecordTypeId','RequiresBillingInfo__c','RevenueInstallmentPeriod','RevenueScheduleType'
	,'SystemModstamp','TotalBillingCycles__c','TrialIntervalLength__c','TrialIntervalUnit__c','UsageResetType__c'
	,'VisibleInApi__c']

result = sf.query_all('''SELECT {} FROM Product2
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Product ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Product VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Recent Usage

# Extract Accounts modified or created today or yesterday
columns= ['AccountId__c','AverageNumSearchesInLast03Months__c','AverageNumSearchesInLast12Months__c',
	'AverageUsageInMbLast03Months__c','AverageUsageInMbLast12Months__c','ContactId__c','CreatedById','CreatedDate',
	'CurrencyIsoCode','Id','IsAccountRecord__c','IsDeleted','LastActivityDate','LastModifiedById','LastModifiedDate',
	'LastRecordedUsageDateTime__c','Name','NumSearchesInApr__c','NumSearchesInAug__c','NumSearchesInDec__c',
	'NumSearchesInFeb__c','NumSearchesInJan__c','NumSearchesInJul__c','NumSearchesInJun__c','NumSearchesInMar__c',
	'NumSearchesInMay__c','NumSearchesInNov__c','NumSearchesInOct__c','NumSearchesInSep__c','OwnerId','SystemModstamp',
	'UsageInMbForApr__c','UsageInMbForAug__c','UsageInMbForDec__c','UsageInMbForFeb__c','UsageInMbForJan__c',
	'UsageInMbForJul__c','UsageInMbForJun__c','UsageInMbForMar__c','UsageInMbForMay__c','UsageInMbForNov__c',
	'UsageInMbForOct__c','UsageInMbForSep__c','Year__c','YearType__c']

result = sf.query_all('''SELECT {} FROM RecentUsage__c
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
    	OR LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.RecentUsage ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.RecentUsage VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Transaction Report Items

# Extract Accounts modified or created today or yesterday
columns= ['AccountId__c','AddOn1Id__c','AddOn1Quantity__c','AddOn2Id__c','AddOn2Quantity__c','AnnualTaxValue__c',
	'AnnualValueExTax__c','AnnualValueInclTax__c','BillingPlatformAccountId__c','ContractId__c','CreatedById',
	'CreatedDate','CurrencyIsoCode','CurrentYearRevenueExTax__c','CustomerType__c','ExternalReferenceID__c','Id',
	'InvoiceDiscountAmountExTax__c','InvoiceNumber__c','InvoiceTaxAmount__c','InvoiceTotalExTax__c',
	'InvoiceTotalInclTax__c','IsDeleted','LastModifiedById','LastModifiedDate','LastReferencedDate','LastViewedDate',
	'MovementAmountExTax__c','Name','NextInvoiceDate__c','Notes__c','OwnerId','PlanId__c','PlanQuantity__c',
	'PriorContractAmountExTax__c','ProductDescription__c','SalesNature__c','SalespersonId__c','SalesType__c',
	'SubscriptionId__c','SystemModstamp','TaxRate__c','TotalContractExTax__c','TotalContractInclTax__c',
	'TotalContractTaxValue__c','TransactionDate__c','TransactionId__c']

result = sf.query_all('''SELECT {} FROM Transaction_Report_Item__c
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.TransactionReportItems ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.TransactionReportItems VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## User Role

# Extract Accounts modified or created today or yesterday
columns= ['CaseAccessForAccountOwner','ContactAccessForAccountOwner','DeveloperName','ForecastUserId','Id',
	'LastModifiedById','LastModifiedDate','MayForecastManagerShare','Name','OpportunityAccessForAccountOwner',
	'ParentRoleId','PortalAccountId','PortalAccountOwnerId','PortalType','RollupDescription','SystemModstamp']

result = sf.query_all('''SELECT {} FROM UserRole
    WHERE LastModifiedDate = TODAY OR LastModifiedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.UserRole ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.UserRole VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


## Users

# Extract Accounts modified or created today or yesterday
columns= ['AboutMe','AccountId','Alias','CallCenterId','Can_Approve__c','City','CommunityNickname','CompanyName',
	'ContactId','Country','CreatedById','CreatedDate','CurrencyIsoCode','DefaultCurrencyIsoCode',
	'DefaultGroupNotificationFrequency','DelegatedApproverId','Department','DigestFrequency','Division','Email',
	'EmailEncodingKey','EmailPreferencesAutoBcc','EmailPreferencesAutoBccStayInTouch','EmailPreferencesStayInTouchReminder',
	'EmployeeNumber','Extension','Fax','FederationIdentifier','FirstName','ForecastEnabled','FullPhotoUrl','Id','IsActive',
	'LanguageLocaleKey','LastLoginDate','LastModifiedById','LastModifiedDate','LastName','LastPasswordChangeDate',
	'LastReferencedDate','LastViewedDate','Latitude','LocaleSidKey','Longitude','ManagerId','MobilePhone','Name',
	'OfflinePdaTrialExpirationDate','OfflineTrialExpirationDate','Phone','PostalCode','ProfileId','ReceivesAdminInfoEmails',
	'ReceivesInfoEmails','SenderEmail','SenderName','Signature','SmallPhotoUrl','State','StayInTouchNote',
	'StayInTouchSignature','StayInTouchSubject','Street','SystemModstamp','TimeZoneSidKey','Title','User_Role__c','Username',
	'UserPermissionsAvantgoUser','UserPermissionsCallCenterAutoLogin','UserPermissionsChatterAnswersUser',
	'UserPermissionsInteractionUser','UserPermissionsMarketingUser','UserPermissionsMobileUser','UserPermissionsOfflineUser',
	'UserPermissionsSFContentUser','UserPermissionsSupportUser','UserPreferencesActivityRemindersPopup',
	'UserPreferencesApexPagesDeveloperMode','UserPreferencesContentEmailAsAndWhen','UserPreferencesContentNoEmail',
	'UserPreferencesDisableAllFeedsEmail','UserPreferencesDisableBookmarkEmail','UserPreferencesDisableChangeCommentEmail',
	'UserPreferencesDisableFileShareNotificationsForApi','UserPreferencesDisableFollowersEmail',
	'UserPreferencesDisableLaterCommentEmail','UserPreferencesDisableLikeEmail','UserPreferencesDisableMentionsPostEmail',
	'UserPreferencesDisableMessageEmail','UserPreferencesDisableProfilePostEmail','UserPreferencesDisableSharePostEmail',
	'UserPreferencesDisCommentAfterLikeEmail','UserPreferencesDisMentionsCommentEmail','UserPreferencesDisProfPostCommentEmail',
	'UserPreferencesEnableAutoSubForFeeds','UserPreferencesEventRemindersCheckboxDefault','UserPreferencesHideCSNDesktopTask',
	'UserPreferencesHideCSNGetChatterMobileTask','UserPreferencesOptOutOfTouch','UserPreferencesReminderSoundOff',
	'UserPreferencesShowCityToExternalUsers','UserPreferencesShowCityToGuestUsers','UserPreferencesShowCountryToExternalUsers',
	'UserPreferencesShowCountryToGuestUsers','UserPreferencesShowEmailToExternalUsers','UserPreferencesShowFaxToExternalUsers',
	'UserPreferencesShowManagerToExternalUsers','UserPreferencesShowMobilePhoneToExternalUsers',
	'UserPreferencesShowPostalCodeToExternalUsers','UserPreferencesShowPostalCodeToGuestUsers',
	'UserPreferencesShowProfilePicToGuestUsers','UserPreferencesShowStateToExternalUsers',
	'UserPreferencesShowStateToGuestUsers','UserPreferencesShowStreetAddressToExternalUsers',
	'UserPreferencesShowTitleToExternalUsers','UserPreferencesShowTitleToGuestUsers',
	'UserPreferencesShowWorkPhoneToExternalUsers','UserPreferencesTaskRemindersCheckboxDefault','UserRoleId','UserType']

result = sf.query_all('''SELECT {} FROM User
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.Users ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.Users VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()



## ContractContactRole

# Extract Accounts modified or created today or yesterday
columns= ['ContactId','ContractId','CreatedById','CreatedDate','Id','IsDeleted','IsPrimary','LastModifiedById',
	'LastModifiedDate','Role','SystemModstamp']

result = sf.query_all('''SELECT {} FROM ContractContactRole
    WHERE CreatedDate = TODAY OR CreatedDate = YESTERDAY
	'''.format(', '.join(columns)))

table = []
datatype = []

for col in columns:
	row = '{} varchar(8000)'.format(col)
	table.append(row)

exp = ', '.join(table)


cursor.execute("CREATE TABLE Staging.STG.ContractContactRole ({})".format(exp))
cnxn.commit()

# Insert results from Salesforce extract into staging table
placeholders = ('?,' * len(columns))[:-1]

for account in result['records']:
	values = [account[col] for col in columns]
	query = 'INSERT INTO Staging.STG.ContractContactRole VALUES ({})'.format(placeholders)
	#print query, values
	cursor.execute(query, *values)

cnxn.commit()


print time.clock() - start_time, "seconds run time"
