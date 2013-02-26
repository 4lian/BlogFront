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
    $scope.posts = []

    ghposts("bolasblack", "BlogPosts")
      .fail (err) ->
        $log.log "fetch posts list error:", err
      .done (posts) ->
        $scope.posts = posts
        $scope.$digest() unless $scope.$$phase

    $scope.avgrundOpts =
      width: 640
      height: "auto"
      render: ($scope, callback) ->
        $scope.post.fetchContent (err, post) ->
          return false if err
          codeId = $.now()
          callback("""
            <article id="article#{codeId}">
              <div class="modal-header">#{post.getMetaData().title}</div>
              <div class="modal-body">
                #{post.getHtmlContent()}
              </div>
            </article>
            <script>
              (function() {
                var elem = document.getElementById("article#{codeId}");
                hljs.highlightBlock(elem);
              })();
            </script>
            """
          )
]) # ]]]

