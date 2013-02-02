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
      $scope.fullPosts = posts
      $scope.fullPosts.fetchContents()
        .done (posts) -> $scope.$apply (scope) ->
          scope.prevPage = false
          scope.nextPage = posts.length is scope.fullPosts.length
          scope.posts = posts
    .fail (err) ->
      $log.log "fetch posts list error:", err
    )()
])
