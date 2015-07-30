'use strict'

module = angular.module 'ngTableAsync'

parseColumnContent = (column) ->
  column  = angular.element column
  content = column.html()

  if content
    contentElement = if _.isEmpty(column.find('nta-content')) then column else column.find 'nta-content'
    content        = "<td>#{ contentElement[0].outerHTML }</td>"
  else
    contentAttr = column.attr 'content'
    content     = if contentAttr then "<td ng-bind=\"#{ contentAttr }\"></td>" else "<td></td>"

  content

parseColumnHeader = (column) ->
  column = angular.element column
  header = if _.isEmpty(column.attr 'header') then '' else column.attr('header')

  if header
    header = "<th ng-bind=\"#{ header }\"></th>"
  else
    if !_.isEmpty column.find('nta-content')
      header = column.find('nta-header').html()
    header = "<th>#{ header }</th>"

  header

parseColumn = (column) ->
  header  : parseColumnHeader  column
  content : parseColumnContent column

###*
  @ngdoc    directive
  @name     ngTableAsync
  @module   ngTableAsync
  @restrict E
  @description
  ngTable wrapper directive that offers some basic functionality for working with asynchronous tables.
###
module.directive 'ngTableAsync', ($q, ngTableParams) ->
  restrict: 'E'
  scope:
    options: '='

  template: (element, attrs) ->
    columns          = element.find 'nta-column'
    parsedColumns    = _.map columns, parseColumn
    compiledHeaders  = _.map parsedColumns, 'header'
    compiledContents = _.map parsedColumns, 'content'

    # Determine 'No Data Available' template
    ndaElement = _.last element.find 'nta-no-data'
    if ndaElement
      ndaTemplate = ndaElement.outerHTML
    else
      ndaTemplate = "<nta-no-data></nta-no-data>"

    # Determine pager template
    pagerElement = _.last element.find 'nta-pager'
    if pagerElement
      pagerTemplate = pagerElement.outerHTML
    else
      pagerTemplate = "<nta-pager></nta-pager>"

    # Determine loading template
    loadingElement = _.last element.find 'nta-loading'
    if loadingElement
      loadingTemplate = loadingElement.outerHTML
    else
      loadingTemplate = "<nta-loading></nta-loading>"

    # Tried to extract this template to a separate file
    # but there is no blocking way to load it.
    # Sadly, this function cannot return a promise, so
    # the $templateRequest alternative becomes useless.
    """
    <div class=\"container-fluid nta-container\" ng-show=\"options.headerIfEmpty || tableParams.total()\">
      <div class=\"row\">
        <div class=\"col-md-12\">

          <div ng-if=\"options.pagerOnTop\">
            #{ pagerTemplate }
          </div>

          <div class=\"nta-content row\">
            <div class=\"panel panel-default\">
              <table ng-table=\"tableParams\" class=\"table ng-table ng-table-responsive nta-table\">
                <thead>
                  <tr>
                    #{ compiledHeaders.join(' ') }
                  </tr>
                </thead>

                <tbody>
                  <tr ng-repeat=\"item in $data track by $index\">
                    #{ compiledContents.join(' ') }
                  </tr>

                  <tr class=\"no-data-container\" ng-show=\"!tableParams.total()\">
                    <td colspan=\"#{ compiledHeaders.length }\">#{ ndaTemplate }</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div ng-show=\"loading\" class=\"nta-loading-container\">
              #{ loadingTemplate }
            </div>

          </div>

          <div ng-if=\"options.pagerOnBottom\">
            #{ pagerTemplate }
          </div>

        </div>
      </div>

    </div>

    <div class=\"container-fluid no-data-container\" ng-if=\"!options.headerIfEmpty\" ng-show=\"!tableParams.total()\">
      #{ ndaTemplate }
    </div>

    """

  controller: ($scope, $element, $q, ngTableAsyncDefaults) ->

    $scope.options = _.merge
      pagerOnTop    : ngTableAsyncDefaults.PAGER_ON_TOP
      pagerOnBottom : ngTableAsyncDefaults.PAGER_ON_BOTTOM
      defaultPage   : ngTableAsyncDefaults.DEFAULT_PAGE
      pageSize      : ngTableAsyncDefaults.PAGE_SIZE
      headerIfEmpty : ngTableAsyncDefaults.HEADER_IF_EMPTY
    , $scope.options

    $scope.mainScope = $scope

    $scope.tableParams = new ngTableParams
      page  : $scope.options.defaultPage
      count : $scope.options.pageSize
    ,
      # '$scope: $scope' line added to avoid
      # "TypeError: Cannot read property '$on' of null"
      # src: https://github.com/esvit/ng-table/issues/182
      $scope: $scope

      getData: ($defer, params) ->
        $scope.loading = true

        skip = (params.page() - 1) * params.count()
        limit = params.count()

        pagePromise = $scope.options.getPage skip, limit
        pagePromise = $q.all(pagePromise) if not pagePromise.then

        pagePromise
        .then (results) ->
          $scope.tableParams.total results[0]
          $defer.resolve results[1]
          delete $scope.loading
          $defer.promise

    $scope.$on 'ng-table-async:reload', ->
      $scope.loading = true
      $scope.tableParams.reload()
      .then ->
        delete $scope.loading
