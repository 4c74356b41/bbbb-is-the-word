import os, pyodbc, json, re, base64
from datetime import datetime
from flask import render_template, url_for, request, redirect, session, flash
from FlaskWebProject import app
from azure.storage.queue import QueueService, QueueMessageFormat

queue_service = QueueService(account_name=os.getenv('storageAccount'), account_key=os.getenv('storageKey'))
queue_service.encode_function = QueueMessageFormat.text_base64encode

app.secret_key = 'my_secret_key1'
where = "{0}-{1}".format(os.getenv('LOCATION'), os.getenv('COMPUTERNAME'))

#/create_queue?queueName=bbbb
#insert_queue?message=bbbb-is-the-word!

@app.route('/', methods=['get','post'])
def default():
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=1433;DATABASE=%s;UID=%s;PWD=%s' % (
        os.getenv('SQL_ADR'), os.getenv('SQL_DTB'), os.getenv('SQL_USR'), os.getenv('SQL_PWD')))
    cursor = cnxn.cursor()

    # if request.method == "POST":
    #     data = request.form['data']
    #     cursor.execute("insert into TemporalTable(TemporalKey) values (?)", data)
    #     cnxn.commit()
    #     cursor.execute("select * from TemporalTable")
    #     row = cursor.fetchall()
    #     return render_template(
    #         'index.html',
    #         title='bbbb',
    #         year=datetime.now().year,
    #         data=row
    #     )
    
    try:
        cursor.execute("select * from TemporalTable")
        row = cursor.fetchall()
        return render_template(
            'index.html',
            title='bbbb',
            year=datetime.now().year,
            data=row,
            location=where
        )
    except:
        norow = 'Azure Functions not yet initialized'
        return render_template(
            'index.html',
            title='bbbb',
            year=datetime.now().year,
            nodata=norow,
            location=where
        )

@app.route('/create_queue')
def create_queue():
    queueName = request.args.get('queueName')
    try:
        queue_service.create_queue(queueName)
    except:
        return json.dumps({'success':False}, {'ContentType':'application/json'}), 409
    flash('Created queue \"{}\"'.format(queueName))

    return render_template(
        'index.html',
        title='bbbb',
        year=datetime.now().year,
        location=where
    )

@app.route('/insert_queue')
def insert_queue():
    message = request.args.get('message')
    try:
        queue_service.put_message('bbbb', message)
    except:
        return json.dumps({'success':False}, {'ContentType':'application/json'}), 409
    flash('Inserted message \"{}\"'.format(message))

    return render_template(
        'index.html',
        title='bbbb',
        year=datetime.now().year,
        location=where
    )

@app.route('/peek_queue')
def peek_queue():
    queueName = request.args.get('queueName')
    try:
        messages = queue_service.peek_messages(queueName, 10)
    except:
        return json.dumps({'success':False}, {'ContentType':'application/json'}), 409
    results = ""
    for message in messages:
        results += (base64.b64decode(message.content)).decode("utf-8")
        results += "; "

    return results, 200



@app.route('/test_db')
def test_db():
    cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=%s;PORT=1433;DATABASE=%s;UID=%s;PWD=%s' % (
        os.getenv('SQL_ADR'), os.getenv('SQL_DTB'), os.getenv('SQL_USR'), os.getenv('SQL_PWD')))
    cursor = cnxn.cursor()
    cursor.execute("SELECT db_name()")
    data = cursor.fetchall()
    return json.dumps({'success':True, "zdata": re.sub(r'\W+', '', str(data))}, {'ContentType':'application/json'}), 200
