'use strict'

### Directives ###

# register the module with Angular
angular.module('app.directives', [])

.directive('avgrund', [ ->
  link: ($scope, elem, attrs) ->
    options = angular.copy $scope.$eval attrs.avgrund

    {template, onload, onUnload} = options
    options.template = ->
      template $scope

    options.onLoad = ->
      onLoad?.apply this, arguments

    options.onUnload = ->
      $(".avgrund-popin").remove()
      onUnload?.apply this, arguments

    $(elem).avgrund options
])
