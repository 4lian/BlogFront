#!/usr/bin/env python
# coding: utf-8
import os, views, hashlib
from config import blogColl
from datetime import datetime
from GetTextInHtml import CustomParser

def update(fileName, fileContent, fileDir = None): #{{{
    blogInfo = _getFileInfo(fileName, fileContent)
    try:
        if not fileDir:
            fileDir = _saveFile(fileName, fileContent)
        _moveFileByCate(blogInfo['category'], fileDir)
        if blogColl.find({'title':blogInfo['title']}).count():
            raise Exception,'%s：已存在的标题' % blogInfo['title']
        if blogColl.find({'blogfile':fileDir}).count():
            raise Exception,'%s：已存在的文件名' %fileDir
    except Exception, e:
        raise Exception, e.message
    else:
        blogInfoList = {'fileDir':'./blogfile/%s/%s' %(blogInfo['category'], fileName),
                        'title':blogInfo['title'],
                        'fileContent':fileContent,
                        'category':blogInfo['category'],
                        'tags':blogInfo['tags']}
        insertDate = _formatBlogInfo(blogInfoList)
        blogColl.insert(insertDate)
        return '上传成功'
#}}}

def checkBlogHash(blogId): #{{{
    idDict = {'_id':blogId}
    queryData = blogColl.find_one(idDict)
    fileDir = './%s' % queryData['blogfile']
    with open(fileDir,'r') as f:
        fileContent = f.read()
    fileName = os.path.split(queryData['blogfile'])[1]
    fileHash = _calcMD5(fileContent)
    fileInfo = _getFileInfo(fileName, fileContent)
    if fileHash != queryData['hash']:
        updateDict = _getUpdateDict(fileInfo, queryData, fileName, fileHash)
        blogColl.update(idDict,{'$set':updateDict})
        return False
    else:
        return True
#}}}

def _getUpdateDict(fileInfo, queryData, fileName, fileHash): #{{{
    updateDict = {'hash':fileHash}
    if fileInfo['category'] != queryData['category']:
        _moveFileByCate(fileInfo['category'], queryData['blogfile'])
        updateDict['category'] = fileInfo['category']
        updateDict['blogfile'] = './blogfile/%s/%s' %(fileInfo['category'], fileName)
    if fileInfo['tags'] != queryData['tags']:
        updateDict['tags'] = fileInfo['tags']
    if fileInfo['title'] != queryData['title']:
        updateDict['title'] = fileInfo['title']
    return updateDict
#}}}

def _saveFile(fileName, fileContent): #{{{
    tempPath = './temp/'
    absTempPath = _createFolder(tempPath)
    tempDir= absTempPath + fileName
    with open(tempDir, 'w') as fout:
        fout.write(fileContent)
    return tempPath + fileName 
#}}}

def _getFileInfo(fileName, fileContent): #{{{
    '''
    获取文件的相关信息，返回一个['tags':...,'title':...,'category':...]字典
    '''
    blogInfo = {'tags':_contentInMarkup(fileContent, 'tags')}
    blogInfo['title'] = _contentInMarkup(fileContent, 'title') \
            or fileName
    blogInfo['category'] = _contentInMarkup(fileContent, 'category') \
            or _contentInMarkup(fileContent, 'cate')
    return blogInfo
#}}}

def _contentInMarkup(fileContent, targetTag): #{{{
    '''
    根据传入的 tag 名，截取 fileContent 内被标签包括的内容
    '''
    parser = CustomParser(targetTag)
    parser.feed(fileContent)
    tagStr = parser.getContent()
    tagList = tagStr.split(',')
    if len(tagList) <= 1:
        return tagList[0].strip()
    else:
        return tagList
#}}}

def _formatBlogInfo(blogInfo): #{{{
    '''
    读取传入的文件信息 dict，格式化为插入数据库的字典数据，并返回
    '''
    title = blogInfo['title']
    fileDir= blogInfo['fileDir']
    category = blogInfo['category']
    formatedDate = {'title':title,
                    'blogfile':fileDir,
                    'createdate':datetime.now(),
                    'tags':blogInfo['tags'],
                    'category':category,
                    'hash':_calcMD5(blogInfo['fileContent'])}
    return formatedDate
#}}}

def _moveFileByCate(category, fileDir): #{{{
    fileFolder = os.path.split(os.path.dirname(fileDir))[1] #文件导入前所在的文件夹
    _createFolder('./blogfile/')
    if category and category not in views.getCateList():
        _createFolder('./blogfile/%s' % category)
    fileName = os.path.basename(fileDir)
    targetDir = './blogfile/%s/%s' %(category, fileName)
    absTargetDir = './%s' % targetDir
    if (category and fileFolder != category) or category == '':
        os.rename(fileDir, absTargetDir)
#}}}

def _createFolder(path): #{{{
    if not os.path.exists(path):
        os.mkdir(path)
    return path
#}}}

def _calcMD5(fileContent): #{{{
    md5obj = hashlib.md5()
    md5obj.update(fileContent)
    fileHash = md5obj.hexdigest()
    return fileHash
#}}}
