#!/usr/bin/env python
# coding: utf-8
import web
import pymongo

# DataBase Config
conn = pymongo.Connection('localhost')
conn.disconnect()

# Cashe Refresh Time (Min)
useCashe = 'false'
refreshTime = 5

# Use Github?
useGithub = 0
gitUsername = ''

# Render
render = web.template.render('templates/', base = 'base')

# Blog Name
blogName = 'Plafer'
