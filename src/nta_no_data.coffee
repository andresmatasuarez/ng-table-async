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
module.directive 'ntaNoData', ->
  restrict : 'E'
  scope    : true
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      '_ng_table_async_no_data.html'

  controller: ($scope, $element, $attrs, ngTableAsyncDefaults) ->
    if !$attrs.text or $attrs.text == 'undefined'
      $attrs.text = ngTableAsyncDefaults.NO_DATA_AVAILABLE_TEXT

    $scope.text = $attrs.text
