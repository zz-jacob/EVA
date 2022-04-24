import pymongo
import uuid
import time

class MessageManage:
    def __init__(self, port=27888):
        self.client = pymongo.MongoClient(f"mongodb://localhost:{port}/")
        self.handler = self.client['eva_dongting_message_record']['messages']

    def register_message(self, message):
        """服务接收到用户前段传来的消息"""
        uid = str(uuid.uuid1())
        self.handler.insert_one({
            'uid': uid,
            'message': message,
            'response': '',
            'processed': False,
            'time': time.time()
        })
        return uid

    def load_message(self):
        """后端服务从数据库中轮询获取新的信息"""
        target = None
        lowest_time = -1
        for item in self.handler.find({'processed': False}):
            if target is None:
                target = item
                lowest_time = item['time']
            else:
                if item['time'] < lowest_time:
                    target = item
                    lowest_time = item['time']
        return target

    def register_response(self, uid, response):
        """将模型给出的回复写入到回复队列"""
        myquery = {"uid": uid, 'processed': False}
        new_values = {"$set": {'response': response, 'processed': True}}
        modify_count = self.handler.update_many(myquery, new_values)
        return modify_count

    def load_response(self, uid):
        """服务接口根据uuid轮询得到系统的回复"""
        myquery = {"uid": uid, 'processed': True}
        results = []
        for item in self.handler.find(myquery):
            results.append(item)
        assert len(results) == 1 or len(results) == 0
        return results[0]['response'] if len(results) == 1 else None