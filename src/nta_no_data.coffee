'use strict'

module = angular.module 'ngTableAsync'

###*
  @ngdoc    directive
  @name     ntaNoData
  @module   ngTableAsync
  @restrict E
  @description
  Renders a 'No available data' for ngTableAsync directive
###
module.directive 'ntaNoData', (ngTableAsyncDefaults) ->
  restrict : 'E'
  scope    : true
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_NO_DATA

  controller: ($scope, $element, $attrs) ->
    if !$attrs.text or $attrs.text == 'undefined'
      $attrs.text = ngTableAsyncDefaults.NO_DATA_TEXT

    $scope.text = $attrs.text
