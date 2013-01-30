'use strict'

### Controllers ###

angular.module('app.controllers', [])

.controller('PostListCtrl', [
  '$rootScope'
  '$scope'
  '$log'
  'ghposts'
  'Deferred'
  'DeferredQueue'

  ($rootScope, $scope, $log, ghposts, Deferred, DeferredQueue) ->
    $rootScope.pageTitle = "文章列表"
    $scope.posts = []

    (_.waterfall (callback) ->
      ghposts("bolasblack", "bolasblack.github.com")
        .fail((err) -> callback err)
        .done (posts) -> callback null, posts
    .then (posts, callback) ->
      _(posts).forEach (post) ->
        rawContent = post.getRawContent()
        validParts = _(rawContent.split /-+/).filter (part) -> part
        post.metaData = jsyaml.load validParts[0]
        post.metaData.create_at = post.name.match(/^\d{4}-\d{2}-\d{2}/)[0]
        post.postData = validParts[1]

      $scope.$apply (scope) ->
        scope.posts = posts
    .fail (err) ->
      $log.log "fetch posts list error:", err
    )()
])
