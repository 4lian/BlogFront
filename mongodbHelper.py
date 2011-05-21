#!/usr/bin/env python
# coding: utf-8
import json
from config import conn
from bson import BSON

bsondecode = lambda bsonObject:BSON.decode(BSON.encode(bsonObject))

db = conn.blog
blogColl = db.blog
userColl = db.user

# 作用是递归地将bson数据中的ObjectId转成str
def intObjectId(bsonData):
    for (key, value) in bsonData.items():
        if key == '_id':
            bsonData[key] = int(value)
        if isinstance(value, dict):
            bsonData[key] = intObjectId(value)
    return bsonData

def bsonConvJson(bsonData):
    if not isinstance(bsonData, dict):
        bsonData = bsondecode(bsonData)
    bsonData['_id'] = str(bsonData['_id'])
    jsonData = json.dumps(bsonData)
    return jsonData

def decodeAndReturn(func):
    def decodeData(self, queryCondition = None):
        bsonData = func(self, queryCondition)
        conn.disconnect()
        return bsonData
    return decodeData

class blog(object):
    @classmethod
    @decodeAndReturn
    def find(self, queryCondition = None):
        bsonData = blogColl.find(queryCondition)
        return bsonData

    @classmethod
    @decodeAndReturn
    def findOne(self, queryCondition):
        bsonData = blogColl.find_one(queryCondition)
        return bsonData

class user(object):
    @classmethod
    @decodeAndReturn
    def find(self, queryCondition = None):
        bsonData = userColl.find(queryCondition)
        return bsonData

    @classmethod
    @decodeAndReturn
    def findOne(self, queryCondition):
        bsonData = userColl.find_one(queryCondition)
        return bsonData
