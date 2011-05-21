#!/usr/bin/env python
# coding: utf-8
import os
import web
import sys
from config import render
from datetime import datetime
from GetTextInHtml import CustomParser
from mongodbHelper import blog, blogColl, bsondecode
reload(sys)
sys.setdefaultencoding('utf8')

def loginAuth(func):
    def __loginAuth(self):
        if not web.ctx.session.login:
            raise web.seeother('/login')
        else:
            return func(self)
    return __loginAuth

class page(object): #{{{
    @loginAuth
    def GET(self):
        return render.postblog()

    def POST(self):
        inputInfo = web.input(updataFile = {})
        try:
            isFailed = self.saveFile(inputInfo.updataFile)
            if not isFailed:
                inputFile = inputInfo.updataFile.file
                inputFile.seek(0)
                fileContent = inputFile.read()
                fileName = inputInfo.updataFile.filename
                title = contentInMarkup(fileContent, 'title') or fileName
                blogInfoList = {'title':title, 
                                'fileName':'/blogfile/%s' %fileName,
                                'fileContent':fileContent}
                insertDate = formatBlogInfo(blogInfoList)
                blogColl.insert(insertDate)
                result = '导入成功'
            else:
                result = isFailed
        except Exception,e:
            delFile(inputInfo.updataFile.filename)
            result = e.message
        raise web.seeother('/post?result=%s' %result)

    def saveFile(self, inputFile):
        try:
            fileDir = '%s/blogfile/' % os.getcwd()
            filePath = inputFile.filename.replace('\\','/')
            fileName = os.path.basename(filePath)
            fout = open('%s/%s'%(fileDir, fileName),'w')
            fout.write(inputFile.file.read())
            fout.close()
            return 0
        except Exception,e:
            return e.message
#}}}

class quantity(object): #{{{
    @loginAuth
    def GET(self):
        return render.quantityPost()

    def POST(self):
        try:
            inputInfo = web.input(folderStr = {})
            folderStr = inputInfo.folderStr
            folderList = folderStr.split(',')
            allFolder = os.walk(os.getcwd()).next()[1]
            for folder in folderList:
                if folder not in allFolder:
                    raise Exception, '有文件夹不在目录下'
            map(self.insertDateOfList, folderList)
            result = '导入成功'
        except Exception,e:
            result = e.message
        raise web.seeother('/quantitypost?result=%s' %result)

    def insertDateOfList(self, folder):
        rootPath = '%s/%s' %(os.getcwd(), folder)
        fileList = []
        # 遍历目标文件夹内所有文件，fileList 内容类似：
        # ['/blogfile/test.html','/upfile/bar.html','/upfile/foo/bar.html']
        for root, dirs, files in os.walk(rootPath):
            for f in files:
                fileDir = '%s/%s' %(root, f)
                fileList.append(fileDir.replace(os.getcwd(), ''))
        try:
            blogInfoList = map(self.readDataFromFile, fileList)
            insertDateList = map(formatBlogInfo, blogInfoList)
            blogColl.insert(insertDateList)
        except Exception,e:
            raise Exception,'%s文件夹内的文件导入出错，出错原因：%s' %(folder, e.message)

    def readDataFromFile(self, fileDir):
        fileName = os.path.basename(fileDir)
        with open('%s/%s' %(os.getcwd(), fileDir), 'r') as f:
            fileContent = f.read()
            title = contentInMarkup(fileContent, 'title') or fileName
        fileData = {'title':title, 
                    'fileName': fileDir,
                    'fileContent':fileContent}
        return fileData
#}}}

class delete(object): #{{{
    @loginAuth
    def GET(self):
        try:
            params = web.input(title = None)
            titleDict = {'title':params.title}
            bsonDate = blog.findOne(titleDict)
            queryDate = bsondecode(bsonDate)
            delFile(queryDate['blogfile'])
            blogColl.remove(titleDict)
        except Exception,e:
            result = e.message
        else:
            result = '删除成功'
        finally:
            raise web.seeother('/index?result=%s' %result)
#}}}

def delFile(fileName):
    try:
        os.remove('%s/%s' %(os.getcwd(), fileName))
    except Exception,e:
        return e.message

def formatBlogInfo(blogInfo):
    title = blogInfo['title']
    fileName = blogInfo['fileName']
    fileContent = blogInfo['fileContent']
    if blog.find({'title':title}).count():
        raise Exception,'%s：已存在的标题' %title
    if blog.find({'blogfile':fileName}).count():
        raise Exception,'%s：已存在的文件名' %fileName
    formatedDate = {'title':title,
                    'blogfile':fileName,
                    'createdate':datetime.ctime(datetime.now()),
                    'tags':contentInMarkup(fileContent, 'tags'),
                    'category':contentInMarkup(fileContent, 'category') \
                        or contentInMarkup(fileContent, 'cate')}
    return formatedDate

def contentInMarkup(fileContent, targetTag):
    parser = CustomParser(targetTag)
    parser.feed(fileContent)
    tagStr = parser.getContent()
    tagList = tagStr.split(',')
    if len(tagList) <= 1:
        return tagList[0].strip()
    else:
        return tagList
