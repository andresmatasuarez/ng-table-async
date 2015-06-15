'use strict'

module = angular.module 'ngTableAsync'

###*
  @ngdoc       object
  @name        ngTableAsyncDefaults
  @module      ngTableAsync
  @description Default settings for ngTableAsync
###
module.value 'ngTableAsyncDefaults',
  FIRST_PAGE             : 1
  PAGE_SIZE              : 10
  NO_DATA_AVAILABLE_TEXT : 'No available results to show'
  PAGER_ON_TOP           : false
  PAGER_ON_BOTTOM        : true
