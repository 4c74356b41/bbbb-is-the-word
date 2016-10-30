import os,pip,sys,time
try:
 import pyodbc
except:
 package = 'pyodbc-3.0.10-cp27-none-win32.whl'
 pip.main(['install', '--user', package])
 raise ImportError('Restarting')

table_name = 'TemporalTable'
table_key = 'TemporalKey'
table_query = "insert into {}({}) values (?)".format(table_name, table_key)
table_create = """
CREATE TABLE {}
(
{} nvarchar(255) NOT NULL PRIMARY KEY
)
""".format(table_name, table_key)

input = open(os.environ['input']).read()
try:
 cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=1433;DATABASE=%s;UID=%s;PWD=%s' % (os.getenv('SQL_ADR'), os.getenv('SQL_DTB'), os.getenv('SQL_USR'), os.getenv('SQL_PWD')))
 cursor = cnxn.cursor()
except:
 print('sleeping')
 time.sleep(60)

if cursor.tables(table=table_name).fetchone():
 cursor.execute(table_query, input)
else:
 cursor.execute(table_create)
 cursor.commit()
 cursor.execute(table_query, input)
cursor.commit()
