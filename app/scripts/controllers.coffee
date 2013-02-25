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
    $scope.pageSize = 5
    $scope.posts = []
    $scope.fullPosts = []

    $scope.pageCount = ->
      Math.ceil $scope.fullPosts.length / $scope.pageSize

    ghposts("bolasblack", "BlogPosts")
      .fail (err) ->
        $log.log "fetch posts list error:", err
      .done (posts) ->
        $scope.fullPosts = posts
        $scope.currentPage = parseInt $routeParams.page or 1, 10
        $scope.$digest() unless $scope.$$phase

    $scope.avgrundOpts =
      width: 640
      height: "auto"
      render: ($scope, callback) ->
        $scope.post.fetchContent (err, post) ->
          return false if err
          callback("""
            <article>
              <div class="modal-header">#{post.getMetaData().title}</div>
              <div class="modal-body">
                #{post.getHtmlContent()}
              </div>
            </article>
            """
          )

    $scope.$watch "fullPosts + currentPage", ->
      if $scope.currentPage
        $window.location.hash = "!/page/#{$scope.currentPage}"
      realPage = $scope.currentPage - 1
      $scope.posts = $scope.fullPosts.slice realPage, realPage + $scope.pageSize
]) # ]]]

