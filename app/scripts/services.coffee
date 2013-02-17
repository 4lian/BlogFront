'use strict'

### Sevices ###

angular.module('app.services', ['ngResource'])

.factory('Deferred', -> # [[[
  -> $.Deferred()
) # ]]]

.factory('DeferredQueue', -> # [[[
  (deferreds...) ->
    deferreds = deferreds[0] if _(deferreds[0]).isArray()
    $.when.apply $, deferreds
) # ]]]

.factory("Gh3.File", -> # [[[
  parsePostData = (post) ->
    rawContent = post.getRawContent()
    if rawContent
      validParts = _(rawContent.split /(^|\s)-+(\s|$)/).filter (part) ->
        part.replace(/\s/g, "")

      post.metaData = $.extend post.metaData, jsyaml.load validParts[0]
      post.postData = validParts[1]
      post.htmlData = marked post.postData

    post.metaData ?= {}
    create_at_str = post.name.match(/^\d{4}-\d{2}-\d{2}/)[0]
    post.metaData.create_at_str = create_at_str
    post.metaData.create_at = moment(create_at_str).toDate().getTime()

  Gh3.File.extend
    fetchContent: (callback) ->
      ls = window.localStorage
      try firstfetch = parseInt ls.getItem("firstfetch"), 10
      outtime = 1000 * 60 * 60 * 24 * 15
      timeout = not firstfetch or ($.now() - firstfetch) >= outtime
      ls.removeItem("posts") if timeout
      try postsData = JSON.parse ls.getItem "posts"
      postsData or= {}

      if rawContent = postsData[@path]
        @rawContent = rawContent
        callback? null, this
      else
        Gh3.File::fetchContent.call this, (err, post) ->
          return callback?(err) if err
          postsData[post.path] = post.getRawContent()
          ls.setItem "posts", JSON.stringify postsData
          ls.setItem "firstfetch", $.now() if timeout
          callback? null, post

    getMetaData: ->
      parsePostData(this) unless @metaData
      @metaData

    getPostContent: ->
      parsePostData(this) unless @postData
      @postData

    getHtmlContent: ->
      parsePostData(this) unless @htmlData
      @htmlData
) # ]]]

.factory("Gh3.FileList", [ # [[[
  '$log'
  'Gh3.File'
  'Deferred'
  'DeferredQueue'

($log, File, Deferred, DeferredQueue) ->
  (files) ->
    filelist = _(files).map (file) ->
      unless file instanceof File
        $log.error file, "must instanceof", File
      file

    filelist.fetchContents = (start=0, end=5) ->
      listDeferred = Deferred()
      range = @slice start, end
      fetchDeferreds = _(range).map (file) ->
        deferred = Deferred()
        if file.getRawContent()
          deferred.resolve file
        else
          file.fetchContent (err, file) ->
            if err then \
              deferred.reject err else \
              deferred.resolve file
        deferred
      DeferredQueue(fetchDeferreds)
        .done (files...) ->
          listDeferred.resolve files
        .fail (err) ->
          listDeferred.reject err
      listDeferred.promise()

    filelist.sort (file1, file2) ->
      f1createAt = file1.getMetaData().create_at
      f2createAt = file2.getMetaData().create_at
      if f1createAt > f2createAt
        -1
      else if f1createAt is f2createAt
        0
      else
        1

    filelist
]) # ]]]

.factory("ghrepo", [ # [[[
  "$window"
  "$resource"
  "Deferred"

($window, $resource, Deferred) ->
  (username, reponame) ->
    deferred = Deferred()

    user = new Gh3.User username
    repo = new Gh3.Repository reponame, user

    repo.fetch (err, resp) ->
      return deferred.reject(err) if err
      deferred.resolve resp

    deferred.promise()
]) # ]]]

.factory("ghposts", [ # [[[
  'ghrepo'
  'Deferred'
  'Gh3.File'
  'Gh3.FileList'

(ghrepo, Deferred, File, FileList) ->
  (username, reponame) ->
    deferred = Deferred()

    postList = _.waterfall (callback) ->
      $.ajax
        url: "https://api.github.com/repos/#{username}\
          /#{reponame}/contents"
        headers: "Origin": location.host
      .fail (jqXHR, textStatus, errorThrown) ->
        callback jqXHR.responseText
      .done (data, textStatus, jqXHR) ->
        callback null, data
    .then (contents, callback) ->
      posts = _(contents).chain()
        .filter (content) ->
          content.type is "file" and content.name.charAt(0) isnt "."
        .map (post) ->
          new File post, new Gh3.User(username), reponame, "master"
        .value()
      deferred.resolve new FileList posts
    .fail (err) ->
      deferred.reject err

    postList()
    deferred.promise()
]) # ]]]

