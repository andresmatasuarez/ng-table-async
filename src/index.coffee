'use strict'

app = angular.module 'ngTableAsync', [ 'ngTable' ]

prepareColumnHtml = (column) ->
  _.map column.children(), (child) ->
    child = angular.element child
    if child.is 'action'
      "<ng-table-async-button
        label  = \"#{child.attr 'label'}\"
        action = \"actions.#{child.attr 'perform'}(item)\"
        style  = \"#{child.attr 'style'}\"
        size   = \"#{child.attr 'size'}\"
        icon   = \"#{child.attr 'icon'}\">
      </ng-table-async-button>"
    else
      child[0].outerHTML

parseColumnContent = (column) ->
  column  = angular.element column
  content = column.html()

  if content
    contentElement = if _.isEmpty(column.find('content')) then column else column.find 'content'
    content        = "<td>#{ prepareColumnHtml(contentElement).join ' ' }</td>"
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
    if !_.isEmpty column.find('content')
      header = column.find('header').html()
    header = "<th>#{ header }</th>"

  header

parseColumn = (column) ->
  header  : parseColumnHeader  column
  content : parseColumnContent column

parseAttribute =
  pagerOnTop    : (v) -> if _.isUndefined v then DEFAULT_PAGER_ON_TOP else v
  pagerOnBottom : (v) -> if _.isUndefined v then DEFAULT_PAGER_ON_BOTTOM else v
  firstPage     : (v) -> v || DEFAULT_FIRST_PAGE
  pageSize      : (v) -> v || DEFAULT_PAGE_SIZE
  actions:
    dialog:
      params: (p) ->
        return p if _.isFunction p

        return        -> undefined if _.isEmpty p
        return (item) -> p         if _.isObject p

        if _.isString p
          return (item) ->
            params = {}
            params[p] = item
            params

        # Default
        (item) -> item: item

###*
  @ngdoc       object
  @name        ngTableAsyncDefaults
  @module      ngTableAsync
  @description Default settings for ngTableAsync
###
app.value 'ngTableAsyncDefaults',
  FIRST_PAGE             : 1
  PAGE_SIZE              : 10
  NO_DATA_AVAILABLE_TEXT : "No available results to show"
  PAGER_ON_TOP           : false
  PAGER_ON_BOTTOM        : true

###*
  @ngdoc    directive
  @name     ngTableAsync
  @module   ngTableAsync
  @restrict E
  @description
  ngTable wrapper directive that offers some basic functionality for working with asynchronous tables.
###
app.directive 'ngTableAsync', ($q, $modal, ngTableParams) ->
  restrict: 'E'
  scope:
    options: '='

  template: (element, attrs) ->
    columns          = element.find 'column'
    parsedColumns    = _.map columns, parseColumn
    compiledHeaders  = _.map parsedColumns, 'header'
    compiledContents = _.map parsedColumns, 'content'

    # Determine 'No Data Available' template
    ndaElement = element.find 'no-data-available'
    ndaTemplate = ndaElement.html()
    if !ndaTemplate
      ndaTemplateUrl = ndaElement.attr 'template-url'
      if ndaTemplateUrl
        ndaTemplate = "<ng-table-async-no-data-available template-url=\"#{ndaTemplateUrl}\"></ng-table-async-no-data-available>"
      else
        ndaTemplate = "<ng-table-async-no-data-available text=\"#{ndaElement.attr 'text'}\"></ng-table-async-no-data-available>"

    # Determine pager template
    pagerElement     = element.find 'pager'
    pagerTemplateUrl = pagerElement.attr 'template-url'
    pagerTemplate    = "<ng-table-async-pager template-url=\"#{pagerTemplateUrl}\"></ng-table-async-pager>"

    # Tried to extract this template to a separate file
    # but there is no blocking way to load it.
    # Sadly, this function cannot return a promise, so
    # the $templateRequest alternative becomes useless.
    "
    <div class=\"container table-container\" ng-show=\"tableParams.total()\">
      <div class=\"row\">
        <div class=\"col-md-12\">

          <div ng-if=\"options.pagerOnTop\">
            #{ pagerTemplate }
          </div>

          <div class=\"table-content row\">
            <div class=\"panel panel-default\">
              <table ng-table=\"tableParams\" class=\"table ng-table ng-table-responsive\">
                <thead>
                  <tr>
                    #{ compiledHeaders.join(' ') }
                  </tr>
                </thead>
                <tbody>
                  <tr ng-repeat=\"item in $data\">
                    #{ compiledContents.join(' ') }
                  </tr>
                </tbody>
              </table>
            </div>
            <div ng-show=\"loadingTable\" class=\"loadingTable text-center\">
              <i class=\"fa fa-spin fa-4x fa-spinner\"></i>
            </div>
          </div>

          <div ng-if=\"options.pagerOnBottom\">
            #{ pagerTemplate }
          </div>

        </div>
      </div>

    </div>

    <div ng-show=\"!tableParams.total()\">
      #{ ndaTemplate }
    </div>

    "

  controller: ($scope, $element) ->
    $scope.options = _.merge
      pagerOnTop         : DEFAULT_PAGER_ON_TOP
      pagerOnBottom      : DEFAULT_PAGER_ON_BOTTOM
      firstPage          : DEFAULT_FIRST_PAGE
      pageSize           : DEFAULT_PAGE_SIZE
    , $scope.options

    # Preprocess actions
    $scope.actions = _.map $scope.options.actions, (action, key) ->
      method = if _.isFunction action then action else action.method
      reload = if _.isUndefined action.reload then true else action.reload
      dialog = if action.dialog and action.dialog.templateUrl then action.dialog else undefined

      methodPromise = (item) ->
        $scope.loadingTable = true
        $q.when()
        .then -> method(item)
        .then ->
          $scope.tableParams.reload() if reload
        .finally ->
          delete $scope.loadingTable

      return [ key, methodPromise ] if !dialog

      confirmationMethodPromise = (item) ->
        params = parseAttribute.actions.dialog.params(dialog.params) item

        # Launch modal
        modalScope = _.merge $scope.$new(true), params
        modalInstance = $modal.open
          templateUrl : action.dialog.templateUrl
          scope       : modalScope

        # Handle result
        modalInstance.result
        .then ->
          methodPromise(item)
        .catch ->
          if action.dialog and action.dialog.onCancel
            action.dialog.onCancel item, params

      [ key, confirmationMethodPromise ]

    $scope.actions = _.object $scope.actions

    $scope.tableParams = new ngTableParams
      page  : $scope.options.firstPage
      count : $scope.options.pageSize
    ,
      # '$scope: $scope' line added to avoid
      # "TypeError: Cannot read property '$on' of null"
      # src: https://github.com/esvit/ng-table/issues/182
      $scope: $scope

      getData: ($defer, params) ->
        $scope.loadingTable = true

        skip = (params.page() - 1) * params.count()
        limit = params.count()

        $scope.options.getPage skip, limit
        .then (results) ->
          $scope.tableParams.total results[0]
          $defer.resolve results[1]
          delete $scope.loadingTable

###*
  @ngdoc    directive
  @name     ngTableAsyncTableButton
  @module   ngTableAsync
  @restrict E
  @description
  Renders an action button for ngTableAsync directive
###
app.directive 'ngTableAsyncButton', ->
  restrict: 'E'
  scope:
    action : '&'
    label  : '='
    size   : '@'
    style  : '@'
    icon   : '@'
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      'partials/_ng_table_async_button.html'

  link: (scope, element, attrs) ->
    attrs.size  = if attrs.size in [ 'xs', 'sm', 'lg' ] then "btn-#{attrs.size}" else ''
    attrs.style = if attrs.style and attrs.style != 'undefined' then "btn-#{attrs.style}" else 'btn-default'
    attrs.icon  = if attrs.icon and attrs.icon != 'undefined' then attrs.icon else undefined

###*
  @ngdoc    directive
  @name     ngTableAsyncNoDataAvailable
  @module   ngTableAsync
  @restrict E
  @description
  Renders a 'No available data' for ngTableAsync directive
###
app.directive 'ngTableAsyncNoDataAvailable', ->
  restrict: 'E'
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      'partials/_ng_table_async_no_data_available.html'

  link: (scope, element, attrs) ->
    if !attrs.text or attrs.text == 'undefined'
      attrs.text = DEFAULT_NO_DATA_AVAILABLE_TEXT

    scope.text = attrs.text

###*
  @ngdoc    directive
  @name     ngTableAsyncPager
  @module   ngTableAsync
  @restrict E
  @description
  Renders a pager for ngTableAsync directive
###
app.directive 'ngTableAsyncPager', ->
  restrict: 'E'
  template: (element, attrs) ->
    if !attrs.templateUrl or attrs.templateUrl == 'undefined'
      attrs.templateUrl = 'partials/_ng_table_async_pager.html'
    "<div ng-table-pagination=\"tableParams\" template-url=\"'#{attrs.templateUrl}'\"></div>"

