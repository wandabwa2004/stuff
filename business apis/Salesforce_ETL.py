# -*- coding: utf-8 -*-
"""
Script to export data from salesforce and load to SQL Server
Run on Windows
"""


from simple_salesforce import Salesforce
import pandas as pd
from pandas import DataFrame, Series
import pyodbc
from sqlalchemy import create_engine


# Connect to Salesforce
sf = Salesforce(username='', password=''
    ,security_token='')

#account_meta = sf.Account.metadata()
#account_describe = sf.Account.describe()

# set up dictionary to map Salesforce datatypes to SQL Server data types
types = {'tns:ID':'VARCHAR(18)'
,'xsd:boolean':'INT'
,'xsd:int':'BIGINT'
,'xsd:double':'FLOAT'
,'xsd:date':'DATE'
,'xsd:dateTime':'DATETIME'
,'xsd:string':'VARCHAR(MAX)'}

# Get field list from Salesforce

lead_dict, account_dict, contact_dict, opportunity_dict, task_dict, campaign_dict, note_dict \
, campaign_member_dict = {}, {}, {}, {}, {}, {}, {}, {} 
# Run calls to Salesforce
for x in sf.Lead.describe()['fields']:
    #lead_fd.append(x['name'])
    #lead_dt.append(types[x['soapType']])
    lead_dict.update({x['name']: types[x['soapType']]})

for x in sf.Account.describe()['fields']:
    #account_fd.append(x['name'])
    #account_dt.append(types[x['soapType']])
    account_dict.update({x['name']: types[x['soapType']]})

for x in sf.Contact.describe()['fields']:
    #contact_fd.append(x['name'])
    #contact_dt.append(types[x['soapType']])
    contact_dict.update({x['name']: types[x['soapType']]})

for x in sf.Opportunity.describe()['fields']:
    #opportunity_fd.append(x['name'])
    #opportunity_dt.append(types[x['soapType']])
    opportunity_dict.update({x['name']: types[x['soapType']]})

for x in sf.Task.describe()['fields']:
    #task_fd.append(x['name'])
    #task_dt.append(types[x['soapType']])
    task_dict.update({x['name']: types[x['soapType']]})

for x in sf.Campaign.describe()['fields']:
    #campaign_fd.append(x['name'])
    #campaign_dt.append(types[x['soapType']])
    campaign_dict.update({x['name']: types[x['soapType']]})

for x in sf.Note.describe()['fields']:
    #note_fd.append(x['name'])
    #note_dt.append(types[x['soapType']])
    note_dict.update({x['name']: types[x['soapType']]})

for x in sf.CampaignMember.describe()['fields']:
    #campaign_member_fd.append(x['name'])
    #campaign_member_dt.append(types[x['soapType']])
    campaign_member_dict.update({x['name']: types[x['soapType']]})

# lead fields are not sorted in alphabetical order

# SOQL column lists for statement

# Create table column and data type lists for SQL Server create script

lead_df = zip(lead_dict.keys(), lead_dict.values())
lead_df.sort()

lead_sql, lead_cte = lead_df[0][0], lead_df[0][0] + ' ' + lead_df[0][1]
for i in range(1, len(lead_df)-1):
    lead_sql = lead_sql + ',' + lead_df[i][0]
    lead_cte = lead_cte + ',' + lead_df[i][0] + ' ' + lead_df[i][1]

account_df = zip(account_dict.keys(), account_dict.values())
account_df.sort()

account_sql, account_cte = account_df[0][0], account_df[0][0] + ' ' + account_df[0][1]
for i in range(1, len(account_df)-1):
    account_sql = account_sql + ',' + account_df[i][0]
    account_cte = account_cte + ',' + account_df[i][0] + ' ' + account_df[i][1]

campaign_df = zip(campaign_dict.keys(), campaign_dict.values())
campaign_df.sort()

campaign_sql, campaign_cte = campaign_df[0][0], campaign_df[0][0] + ' ' + campaign_df[0][1]
for i in range(1, len(campaign_df)-1):
    campaign_sql = campaign_sql + ',' + campaign_df[i][0]
    campaign_cte = campaign_cte + ',' + campaign_df[i][0] + ' ' + campaign_df[i][1]



# Connect to SQL Server
connection_str =    """
Driver={SQL Server};
Server=AWS-SFA-00.nearmap.local;
Database=salesforce_migration;
Trusted_Connection=yes;
"""
# open connection
db_connection = pyodbc.connect(connection_str)
db_connection.autocommit = True
db_cursor = db_connection.cursor()


sql_droptables = '''
IF OBJECT_ID('stg_Lead', 'U') IS NOT NULL
DROP TABLE stg_Lead
IF OBJECT_ID('stg_Account', 'U') IS NOT NULL
DROP TABLE stg_Account
IF OBJECT_ID('stg_Campaign', 'U') IS NOT NULL
DROP TABLE stg_Campaign
'''

db_cursor.execute(sql_droptables)
db_connection.commit()

db_cursor.close()
del db_cursor


# Create DB engine using SQLAlchemy
eng = create_engine("mssql+pyodbc://SQLServer")


# Extract data from Salesforce
# Use sf.query_all to get all the records, not just the first 1000 or so

# Leads
leads = DataFrame(sf.query('SELECT {} FROM Lead'.format(lead_sql))['records'])
leads = leads.drop('attributes',1)
leads[leads.select_dtypes(include=['bool']).columns.values] = leads[leads.select_dtypes(include=['bool']).columns.values]+0
leads[leads.select_dtypes(include=['float64']).columns.values]=leads[leads.select_dtypes(include=['float64']).columns.values].fillna(0)

leads.to_sql("stg_Lead", eng)
del leads

# Accounts
accounts = DataFrame(sf.query_all('SELECT {} FROM account'.format(account_sql))['records'])
accounts = accounts.drop('attributes',1)
accounts[accounts.select_dtypes(include=['bool']).columns.values] = accounts[accounts.select_dtypes(include=['bool']).columns.values]+0
accounts[accounts.select_dtypes(include=['float64']).columns.values]=accounts[accounts.select_dtypes(include=['float64']).columns.values].fillna(0)

accounts.to_sql("stg_Account", eng)
del accounts

# Campaigns
campaigns = DataFrame(sf.query_all('SELECT {} FROM Campaign'.format(campaign_sql))['records'])
campaigns = campaigns.drop('attributes',1)
campaigns[campaigns.select_dtypes(include=['bool']).columns.values] = campaigns[campaigns.select_dtypes(include=['bool']).columns.values]+0
campaigns[campaigns.select_dtypes(include=['float64']).columns.values]=campaigns[campaigns.select_dtypes(include=['float64']).columns.values].fillna(0)

campaigns.to_sql("stg_Campaign", eng)
del campaigns

eng.dispose()

#notes = DataFrame(sf.query('SELECT {} FROM Note'.format(note_sql))['records'])
#campaign_members = DataFrame(sf.query('SELECT {} FROM CampaignMember'.format(campaign_member_sql))['records'])


# approach using insert statements and pyodbc
#quest = ','.join('?' * (len(campaign_df)-1))
#
#db_cursor.execute('''
#    INSERT INTO SF.Campaign 
#    VALUES({})'''.format(quest), list(campaigns.iloc[1]))
