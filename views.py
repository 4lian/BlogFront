#!/usr/bin/env python
# coding: utf-8
import os
import web
import json
from config import render
from GetTextInHtml import CustomParser
from mongodbHelper import bsondecode, bsonConvJson, blog

class bloglist(object): #{{{
    def GET(self):
        bloglist = []
        params = web.input(count = 10, page = 1)
        count = int(params.count)
        page = int(params.page)
        bsonData = blog.find().limit(count).skip(count * (page - 1))
        if bsonData.count():
            for aBlog in bsonData:
                aBlog['_id'] = str(aBlog['_id'])
                bloglist.append(bsondecode(aBlog))
        return json.dumps({'titlelist':bloglist})
#}}}

#{{{ json data in db
#{
#'_id':...,
#'title':...,
#'tags':...,
#'category':...,
#'createdate':...,
#'blogfile':...,
#}
#}}}

class getblog(object): #{{{
    def GET(self, blogtitle):
        bsonData = blog.findOne({'title':blogtitle})
        if not bsonData:
            return render.notfind()
        else:
            queryData = bsondecode(bsonData)
            blogfile = queryData['blogfile']
            jsonData = bsonConvJson(queryData)
            try:
                queryData['content'] = self.getblogtext(blogfile)
            except Exception,e:
                jsonData['content'] = '返回数据出错啦！出错内容：%s' %e.message
            return jsonData

    def getblogtext(self, blogfile):
        parser = CustomParser('body')
        try:
            fileDir = '/%s/%s' %(os.getcwd(), blogfile)
            with open(fileDir , 'r') as f:
                fileContent = f.read()
        except Exception,e:
            return '读取数据出错，出错内容：%s' %e.message
        else:
            parser.feed(fileContent)
            content = parser.getContent()
            parser.close()
            if not content:
                content = fileContent
            return content
#}}}

class search(object):
    def GET(self):
        inputInfo = web.input(q = None)
        if inputInfo.q:
            # 搜索数据库中的标题与标签
            # 应该去看看 DokuWiki 的搜索使用的方法
            pass
        else:
            return {'result':None}
