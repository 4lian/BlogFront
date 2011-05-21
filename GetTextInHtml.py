#!/usr/bin/env python
# coding: utf-8
import HTMLParser
 
class CustomParser(HTMLParser.HTMLParser):
    def __init__(self, targetTag):
        HTMLParser.HTMLParser.__init__(self)
        self.__start = 0
        self.__feeded = 0
        self.__content = ''
        self.__targetTag = targetTag

    def handle_starttag(self, tag, attrs):
        if self.__start:
            theTag = '<' + tag
            for name, value in attrs:
                theTag += ' %s=%s' %(name, value)
            theTag += '>'
            self.__content += theTag
        if tag == self.__targetTag:
            self.__start=1

    def handle_data(self, data):
        if self.__start:
            self.__content += data

    def handle_endtag(self, tag):
        if tag == self.__targetTag:
            self.__start=0
        if self.__start:
            self.__content += '</%s>' %tag

    def feed(self, data):
        self.__feeded = 1
        HTMLParser.HTMLParser.feed(self, data)

    def getContent(self):
        if self.__feeded:
            return self.__content
        else:
            raise HTMLParser.HTMLParseError,'feed first'

if __name__ == "__main__":
    #parser = CustomParser('tags')
    parser = CustomParser('body')
    with open('./test.html','r') as f:
        parser.feed(f.read())
    content = parser.getContent()
    parser.close()
    print content
