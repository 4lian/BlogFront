'use strict'

### Directives ###

# register the module with Angular
angular.module('app.directives', [])

.directive('avgrund', [ ->
  ($scope, elem, attrs) ->
    options = $scope.$eval attrs.avgrund

    {template, onload, onUnload} = options
    options.template = -> template $scope

    options.onload = ->
      onload?.apply this, arguments

    options.onUnload = ->
      $(".avgrund-popin").remove()
      onUnload?.apply this, arguments

    $(elem).avgrund options
])
