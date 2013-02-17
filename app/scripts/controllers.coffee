'use strict'

### Controllers ###

angular.module('app.controllers', [])

.controller('NavCtrl', [ # [[[
  '$rootScope'
  '$scope'
  '$location'

($rootScope, $scope, $location) ->
  $scope.$location = $location

  $scope.navTitleConfig =
    '/': "文章列表"

  $scope.$watch '$location.path()', (path) ->
    $rootScope.pageTitle = $scope.navTitleConfig[path]

  $scope.getNavClass = (path) ->
    if $location.path().indexOf(path) is 0 then 'active' else ''
]) # ]]]

.controller('PostListCtrl', [ # [[[
  '$scope'
  '$log'
  '$routeParams'
  '$window'
  'ghposts'
  'Deferred'
  'DeferredQueue'

  ($scope, $log, $routeParams, $window, ghposts, Deferred, DeferredQueue) ->
    $scope.pageSize = 1
    $scope.posts = []
    $scope.fullPosts = []

    ghposts("bolasblack", "BlogPosts")
      .fail (err) ->
        $log.log "fetch posts list error:", err
      .done (posts) ->
        $scope.fullPosts = posts
        $scope.currentPage = parseInt $routeParams.page or 1, 10
        $scope.$digest() unless $scope.$$phase

    $scope.$watch "fullPosts + currentPage", ->
      if $scope.currentPage
        $window.location.hash = "!/page/#{$scope.currentPage}"
      realPage = $scope.currentPage - 1
      $scope.fullPosts.fetchContents?(
        realPage
        realPage + $scope.pageSize
      ).done (posts) ->
        $scope.posts = posts
        $scope.$digest() unless $scope.$$phase
]) # ]]]

