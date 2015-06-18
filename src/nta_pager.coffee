'use strict'

module = angular.module 'ngTableAsync'

###*
  @ngdoc    directive
  @name     ntaPager
  @module   ngTableAsync
  @restrict E
  @description
  Renders a pager for ngTableAsync directive
###
module.directive 'ntaPager', (ngTableAsyncDefaults) ->
  restrict: 'E'
  template: (element, attrs) ->
    if !attrs.templateUrl or attrs.templateUrl == 'undefined'
      attrs.templateUrl = ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_PAGER
    "<div ng-table-pagination=\"tableParams\" template-url=\"'#{attrs.templateUrl}'\"></div>"
