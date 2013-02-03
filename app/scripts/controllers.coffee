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
    $scope.pageSize = 1
    $scope.posts = []
    $scope.fullPosts = []

    ghposts("bolasblack", "bolasblack.github.com")
      .fail (err) ->
        $log.log "fetch posts list error:", err
      .done (posts) ->
        $scope.fullPosts = posts
        $scope.currentPage = 1
        $scope.$digest() unless $scope.$$phase

    $scope.$watch "fullPosts + currentPage", ->
      realPage = $scope.currentPage - 1
      $scope.fullPosts.fetchContents?(
        realPage
        realPage + $scope.pageSize
      ).done (posts) ->
        $scope.posts = posts
        $scope.$digest() unless $scope.$$phase
])
