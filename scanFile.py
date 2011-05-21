#!/usr/bin/env python
# coding: utf-8
<<<<<<< HEAD
import os
from bson import ObjectId
from fileUpdate import update
from user import loginAuth, exceptAction
from config import render, blogColl
reload(sys)
sys.setdefaultencoding('utf8')
=======
import os, time
<<<<<<< HEAD
from fileOperate import addFile, checkFile
from config import blogColl, timeUnit, scanInterval
>>>>>>> 6b16d76... 2011.6.12
=======
from fileOperate import addFile, fileChanged
from config import postColl, postFolder, timeUnit, scanInterval
>>>>>>> 3e84293... 几乎把所有的 blog 改成了 post （静态文件除外）

def checkThreading(): #{{{
    while True:
        checkFolder()
        unitDict = {'d':86400, 'h':3600, 'm':60, 's':1}
        if timeUnit not in unitDict:
            raise Exception, 'timeUnit error'
        else:
            sleepTime = scanInterval * unitDict[timeUnit]
            time.sleep(sleepTime)
#}}}

def checkFolder(): #{{{
    '''
    检查文件夹里的文件是否有改动
    发现数据有出入就修改数据库
    文件少了就删除数据
    发现多了文件就加入数据库
    '''
    #发现数据有出入就修改数据库
    #文件少了就删除数据
    bsonData = postColl.find()
    for queryData in bsonData:
        fileChanged(queryData)
    
    #发现多了文件就加入数据库
    fileList_inFolder = []
    for file in _walkPath(postFolder):
        fileList_inFolder.append(file.decode('utf8'))

    fileList_inDb = []
    for queryData in postColl.find({}, {'postFilePath':True}):
        fileList_inDb.append(queryData['postFilePath'])

    newFile = list(set(fileList_inFolder) - set(fileList_inDb))
    for fileDir in newFile:
        addFile(fileDir)
#}}}

def _walkPath(dir):  #{{{
    '''
    遍历目标文件夹内所有文件，fileList 内容类似：
    ["/postfile/test.html","/upfile/bar.html","/upfile/foo/bar.html"]
    '''
<<<<<<< HEAD
    fileList = fileIter(folder)
    try:
        for fileDir in fileList:
            fileName = os.path.basename(fileDir)
            with open(fileDir, 'r') as f:
                fileContent = f.read()
            upLoad(fileName, fileContent, fileDir)
        return '上传成功'
    except Exception,e:
        raise Exception,'%s文件夹内的文件%s导入出错，出错原因：%s' %(folder, fileDir, e)
#}}}
#}}}

def delete(blogId = None): #{{{
    try:
        if not blogId:
            raise Exception, 'Need Blog Id'
        idDict = {'_id':ObjectId(blogId)}
        bsonDate = blogColl.find_one(idDict)
        if not bsonDate:
            raise Exception, '没有找到文章'
        blogColl.remove(idDict)
        result = '删除成功'
    except Exception,e:
        raise e
    else:
        os.remove(bsonDate['blogfile'])
    return result
#}}}
=======
    fileList = []
    for root, dirs, files in os.walk(dir):
        for f in files:
            fileDir = '%s/%s' %(root, f)
            reDir = fileDir.replace(os.getcwd(), '')
            fileList.append(reDir)
    return fileList
<<<<<<< HEAD
>>>>>>> 6b16d76... 2011.6.12
=======
#}}}
>>>>>>> 3e84293... 几乎把所有的 blog 改成了 post （静态文件除外）
