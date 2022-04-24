# 2367:4659
# docker run -ti --name eva_dongting --network=host --gpus all -v  ${PWD}:/home/zhangzheng gyxthu17/eva:1.5 /bin/bash
from flask import Flask, session, redirect, render_template, flash, request, url_for
import uuid
import os
import json
import time
import fcntl
from message_manage import MessageManage

message_manager = MessageManage()

app = Flask(__name__)

def write_utterance(utterance):
    uid = str(uuid.uuid1())
    with open('input_json_file.json', 'r', encoding='utf-8') as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)
        ulist = json.load(f)
        ulist.append([uid, utterance])
    with open('input_json_file.json', 'w+', encoding='utf-8') as f2:
        fcntl.flock(f2.fileno(), fcntl.LOCK_EX)
        json.dump(ulist, f2, ensure_ascii=False)
    return uid

def load_response(uid):
    try:
        with open('output_json_file.json', 'r', encoding='utf-8') as f:
            ulist = json.load(f)
        for id, utterance in ulist:
            if id == uid:
                return utterance
    except:
        return None
    return None


@app.route('/fawubottest', methods=['POST'])
def debt_call():
    user_utterance = request.form.get('user_post')
    print(f'Get user utterance: {user_utterance}')
    # uid = write_utterance(user_utterance)
    uid = message_manager.register_message(user_utterance)
    response = None
    start = time.time()
    while True:
        time.sleep(0.25)
        response = message_manager.load_response(uid)
        if response is not None:
            break
        if time.time() - start > 15:
            response = '请求超时，请稍后重试'
            break
    return {
        'response': response,
        'confidence': 1.0,
        "name": "fawubottest"
    }

if __name__ == '__main__':
    """Main serving program."""
    f = open('input_json_file.json', 'w+', encoding='utf-8')
    f.write("[]")
    f.close()
    f = open('output_json_file.json', 'w+', encoding='utf-8')
    f.write("[]")
    f.close()
    app.config['JSON_AS_ASCII'] = False
    app.run(host="0.0.0.0", debug=True, threaded=False, port=2082)
