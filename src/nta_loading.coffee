'use strict'

module = angular.module 'ngTableAsync'

###*
  @ngdoc    directive
  @name     ntaLoading
  @module   ngTableAsync
  @restrict E
  @description
  Renders the 'loading table' markup for ngTableAsync directive
###
module.directive 'ntaLoading', (ngTableAsyncDefaults) ->
  restrict: 'E'
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_LOADING
