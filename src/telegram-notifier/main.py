import json
import os
import requests

aws_session_token = os.environ.get('AWS_SESSION_TOKEN')
url = 'http://localhost:2773/systemsmanager/parameters/get?withDecryption=true&name='
chat_id_param = '/telegram/chat_id'
token_param = '/telegram/token'

def notify(event, context):
    headers = {'X-Aws-Parameters-Secrets-Token':aws_session_token}
    response = requests.get(url + chat_id_param, headers = headers)
    chat_id = json.loads(response.text)
    response = requests.get(url + token_param, headers = headers)
    token = json.loads(response.text)
    bot_message = event['Records']['Sns']['Message']
    send_text = 'https://api.telegram.org/bot' + token['Parameter']['Value'] + '/sendMessage?chat_id=' + chat_id['Parameter']['Value'] + '&parse_mode=Markdown&text=' + bot_message
    response = requests.get(send_text)
    print(response)