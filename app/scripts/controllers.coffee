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
      clean: ($scope) ->
        $window.DISQUS = null
      render: ($scope, callback) ->
        $scope.post.fetchContent (err, post) ->
          return false if err
          metaData = post.getMetaData()
          debugger
          callback("""
            <div class="modal-header">#{metaData.title}</div>
            <div class="modal-body" style="max-height:none;">
              <article id="article#{metaData.identifier}">
                #{post.getHtmlContent()}
                <div id="disqus_thread"></div>
              </article>
            </div>
            <script>
              var disqus_shortname = 'plaferinfo',
                  disqus_identifier = '#{metaData.identifier}',
                  disqus_title = '#{metaData.title}',
                  disqus_url = '#{window.location.href}#{metaData.identifier}'

              ;(function() {
                var d = window.document,
                    t = function(tn) { return d.getElementsByTagName(tn)[0] },
                    elem = d.getElementById("article#{metaData.identifier}"),
                    dsq = d.createElement('script')

                hljs.highlightBlock(elem);
                dsq.type = 'text/javascript'
                dsq.async = true
                dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js'
                ;(t('head') || t('body')).appendChild(dsq)
              })()
            </script>
            """
          )
]) # ]]]

