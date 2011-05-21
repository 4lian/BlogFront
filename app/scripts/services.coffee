'use strict'

### Sevices ###

angular.module('app.services', ['ngResource'])

.factory('version', -> "0.1")

.factory('Deferred', -> -> $.Deferred())
.factory('DeferredQueue', ->
  (deferreds...) ->
    deferreds = deferreds[0] if _(deferreds[0]).isArray()
    $.when.apply $, deferreds
)

.factory("ghrepo", [
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
])

.factory("ghposts", [
  'ghrepo'
  'Deferred'
  'DeferredQueue'

(ghrepo, Deferred, DeferredQueue) ->
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
    .then (posts, callback) ->
      postDeferreds = _(posts)
        .chain()
        .filter (post) ->
          post.type is "file"
        .map (post) ->
          new Gh3.File post, new Gh3.User(username), reponame, "master"
        .map (post) ->
          postDeferred = Deferred()
          post.fetchContent (err, post) ->
            return postDeferred.reject err if err
            postDeferred.resolve post
          postDeferred
        .value()

      callback null, postDeferreds
    .then (postDeferreds) ->
      DeferredQueue(postDeferreds)
        .fail((message) -> callback message)
        .done (posts...) ->
          deferred.resolve posts
    .fail (err) ->
      deferred.reject err

    postList()
    deferred.promise()
])
