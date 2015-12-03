# Rforcecom
install.packages("RForcecom")
library(RForcecom)

username <- ""
password <- ""
instanceURL <- "https://login.salesforce.com/"
apiVersion <- "27.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)


Objects <- rforcecom.getObjectList(session)

objectName <- "Contact"
Contact <- rforcecom.getObjectDescription(session, objectName)

write.table(Contact, "Contact.xls", sep="\t")

objectName <- "Contact"
head(rforcecom.getObjectDescription(session, objectName))
BillingCity,BillingState,BillingPostalCode,BillingCountry

soqlQuery <- "SELECT Id,IsDeleted,MasterRecordId,AccountId,LastName,FirstName,Salutation,Name,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Fax,MobilePhone,HomePhone,OtherPhone,AssistantPhone,ReportsToId,Email,Title,Department,AssistantName,LeadSource,Birthdate,Description,OwnerId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastCURequestDate,LastCUUpdateDate,EmailBouncedReason,EmailBouncedDate,Jigsaw,JigsawContactId,Is_Active__c,NewsLetter__c,PasswordClear__c,Password__c,Username__c,AccessRights__c,ValidationEmailToken__c,EmailValidatedStamp__c,ValidationEmailSentStamp__c,EmailValidationRequired__c,SmsUpdates__c,Verification_Emails_Sent_Count__c,VerificationEmailStatus__c,MirrorId__c,RegisteredDate__c,Balance__c,LastActivity__c,LastActivityDetails__c,LastLoginFailure__c,Linkedin_Profile__c,Primary_Contact__c,LicenceInfo__c,TsAndCsInfo__c,Domain__c,Email_Domain__c,Free_Commercial_Email__c,CaseSafeContactID__c,LegacyEmail__c,LegacyUsername__c,mkto2__Acquisition_Date__c,mkto2__Acquisition_Program_Id__c,mkto2__Acquisition_Program__c,mkto2__Inferred_City__c,mkto2__Inferred_Company__c,mkto2__Inferred_Country__c,mkto2__Inferred_Metropolitan_Area__c,mkto2__Inferred_Phone_Area_Code__c,mkto2__Inferred_Postal_Code__c,mkto2__Inferred_State_Region__c,mkto2__Lead_Score__c,mkto2__Original_Referrer__c,mkto2__Original_Search_Engine__c,mkto2__Original_Search_Phrase__c,mkto2__Original_Source_Info__c,mkto2__Original_Source_Type__c,Status__c
FROM Contact"

,Title,Department,AssistantName,LeadSource,Birthdate,Description,OwnerId,CreatedDate,CreatedById 

soqlQuery <- "SELECT Id,IsDeleted,MasterRecordId,AccountId,LastName,FirstName,Salutation,Email
      FROM Contact"
ContactQ <- RForcecom.query(session, soqlQuery)

fields <- c("Id","IsDeleted","MasterRecordId","AccountId","LastName","FirstName","Salutation","Name","ReportsToId","Email","Title","Department","AssistantName","LeadSource","Birthdate","Description","OwnerId","CreatedDate","CreatedById")
ContactR <- rforcecom.retrieve(session, objectName, fields)

rforcecom.retrieve
rforcecom.query
