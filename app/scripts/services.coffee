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
      contentParts = rawContent.split /^-+$/m
      validParts = _(contentParts).select (part) -> part.replace(/\s/g, "")
      if contentParts[0].replace(/-/g, "") is ""
        metaData = $.extend post.metaData, jsyaml.load validParts[0]
        delete metaData.title
        post.metaData = metaData
        post.postData = validParts[1]
      else
        post.postData = validParts[0]
      post.htmlData = marked post.postData

    name = post.name.replace /\.(md|markdown)$/, ""
    createTimeRE = /^\d{4}-\d{1,2}-\d{1,2}-/
    createTimeStr = name.match(createTimeRE)[0].slice(0, -1)

    post.metaData ?= {}
    post.metaData.identifier = createTimeStr
    post.metaData.create_at_str = createTimeStr
    post.metaData.create_at = moment(createTimeStr).toDate().getTime()
    post.metaData.title = name
      .replace(createTimeRE, "")
      .replace(/([^\\])_/g,"$1 ")

  fetchContent = Gh3.File::fetchContent
  Gh3.File.extend
    #fetchContent: (callback) ->
      #postsCache = JSON.parse localStorage.getItem("posts") or "{}"
      #if postsCache[@path]?.sha is @sha
        #_.extend this, postsCache
        #return callback? null, this
      #fetchContent.call this, (err, file) ->
        #unless err or file.type isnt "file"
          #postsCache[file.path] = file
          #localStorage.setItem "posts", JSON.stringify postsCache
        #callback? err, file

    getMetaData: ->
      parsePostData(this)
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
        url: "https://api.github.com/repos/#{username}/#{reponame}/contents"
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

