'use strict'

module = angular.module 'ngTableAsync'

###*
  @ngdoc       object
  @name        ngTableAsyncDefaults
  @module      ngTableAsync
  @description Default settings for ngTableAsync
###
module.value 'ngTableAsyncDefaults',
  DEFAULT_PAGE       : 1
  PAGE_SIZE          : 10
  NO_DATA_TEXT       : 'No available results to show'
  PAGER_ON_TOP       : false
  PAGER_ON_BOTTOM    : true
  HEADER_IF_EMPTY    : true

  SUPPORTED_VALUES   :
    NTA_ACTION_SIZE  : [ 'xs', 'sm', 'lg' ]
    NTA_ACTION_STYLE : [ 'default', 'primary', 'success', 'info', 'warning', 'danger', 'link' ]

  DEFAULT_VALUES     :
    NTA_ACTION_SIZE  : ''
    NTA_ACTION_STYLE : 'default'

  DEFAULT_TEMPLATES  :
    NTA_ACTION       : '_ng_table_async_action.html'
    NTA_LOADING      : '_ng_table_async_loading.html'
    NTA_NO_DATA      : '_ng_table_async_no_data.html'
    NTA_PAGER        : '_ng_table_async_pager.html'
