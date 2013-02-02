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
    rawContent = Gh3.File::getRawContent.call post
    validParts = _(rawContent.split /-+/).filter (part) -> part
    post.metaData = jsyaml.load validParts[0]
    post.metaData.create_at = post.name.match(/^\d{4}-\d{2}-\d{2}/)[0]
    post.postData = validParts[1]

  Gh3.File.extend
    getRawContent: ->
      parsePostData(this) unless @postData
      @postData

    getMetaData: ->
      parsePostData(this) unless @metaData
      @metaData
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
          /#{reponame}/contents/_posts"
        headers: "Origin": location.host
      .fail (jqXHR, textStatus, errorThrown) ->
        callback jqXHR.responseText
      .done (data, textStatus, jqXHR) ->
        callback null, data
    .then (contents, callback) ->
      posts = _(contents).chain()
        .filter (content) ->
          content.type is "file"
        .map (post) ->
          new File post, new Gh3.User(username), reponame, "master"
        .value()
      deferred.resolve new FileList posts
    .fail (err) ->
      deferred.reject err

    postList()
    deferred.promise()
]) # ]]]

