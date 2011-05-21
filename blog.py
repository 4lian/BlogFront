#!/usr/bin/env python
# coding: utf-8
import web
import post
import views
from mongodbHelper import db
from mongoSession import MongoStore

# TODO 
# user:
#  完成权限管理
# views.bloglist:
#  Feed
#  搜索
# post.POST:
#  title, tags 和 category 的修改
# mongodbHelper:
#  完成 intObjectId 函数

# TODO: post
#  是不是在blogfile文件夹里建立一个个分类文件夹？批量上传也是这个道理
#  存储的时间也有问题
# TODO: views.bloglist
# - 是不是在没有登录或者权限不够的时候不在列表旁显示 Del
# -- 完成搜索功能
# TODO: 插件
#  实现插件系统
# - 可以选择是用 markdown 写的还是用 HTML 写的
# - 可以把 HTML 文件存储在 Github 上
# -- 能够在 Blog 上发 Tweet
# -- 能够和 BlogList 一起显示 Tweet
# --- 完成缓存机制
# TODO: 最低优先级
#  多种文章的 url

urls = (
    '/login','user.login',
    '/logout','user.logout',
    '/post','post.page',
    '/quantitypost','post.quantity',
    '/delpost','post.delete',
    '/index','views.bloglist',
    '/search','views.search',
    '/','views.bloglist',
    '/(.*)','views.getblog'
)

app = web.application(urls, globals())

# 在调试模式与子应用中使用session {{{
if web.config.get('_session') is None:
    session = web.session.Session(app, MongoStore(db, 'session'), {'login':0})
    web.config._session = session
else:
    session = web.config._session

def session_hook():
    web.ctx.session = session

app.add_processor(web.loadhook(session_hook))
#}}}

if __name__ == "__main__":
    app.run()
