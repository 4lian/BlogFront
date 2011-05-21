#!/usr/bin/env python
# coding: utf-8
import web
import sys
from config import render
from mongodbHelper import user, bsondecode
reload(sys)
sys.setdefaultencoding('utf8')

class login(object):
    def GET(self):
        return render.login()

    def POST(self):
        loginInfo = web.input()
        bsonData = user.findOne({'username':loginInfo.username})
        if not bsonData:
            result = '没有这个用户名'
        else:
            queryData = bsondecode(bsonData)
            if queryData['password'] == loginInfo.password:
                web.ctx.session.login = 1
                raise web.seeother('/post')
            else:
                result = '密码错误'
        raise web.seeother('/login?result=%s' %result)

class logout(object):
    def GET(self):
        web.ctx.session.login = 0
        web.ctx.session.kill()
        raise web.seeother('/')
