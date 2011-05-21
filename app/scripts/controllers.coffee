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
      $scope.$apply (scope) ->
        scope.posts = posts
    .fail (err) ->
      $log.log "fetch posts list error:", err
    )()
])
