'use strict'

### Directives ###

# register the module with Angular
angular.module('app.directives', [])

.directive('avgrund', [ ->
  link: ($scope, elem, attrs) ->
    options = angular.copy $scope.$eval attrs.avgrund

    options.onLoad = ->
      options.render $scope, (html) ->
        $(".avgrund-overlay").append $(".avgrund-popin").detach().html html

    $(elem).avgrund options
])
