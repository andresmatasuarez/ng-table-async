'use strict'

module = angular.module 'ngTableAsync'

parseDialogAttribute = (d) ->
  dialog = if d and d.templateUrl then d else undefined

  if _.isUndefined(dialog) or _.isEmpty(dialog.params) or _.isFunction(dialog.params)
    return dialog

  dialog.params =        -> undefined     if _.isEmpty dialog.params
  dialog.params = (item) -> dialog.params if _.isObject dialog.params

  if _.isString dialog.params
    dialog.params = (item) ->
      params = {}
      params[dialog.params] = item
      params

  dialog.params = (item, index) -> item: item, index: index

  dialog

###*
  @ngdoc    directive
  @name     ntaAction
  @module   ngTableAsync
  @restrict E
  @description
  Renders an action button for ngTableAsync directive
###
module.directive 'ntaAction', (ngTableAsyncDefaults) ->
  restrict : 'E'
  scope    : true
  templateUrl: (element, attrs) ->
    if attrs.templateUrl and attrs.templateUrl != 'undefined'
      attrs.templateUrl
    else
      ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_ACTION

  controller: ($scope, $attrs, $q, $injector) ->
    defaults = ngTableAsyncDefaults
    action   = $scope.options.actions[$attrs.action]
    method   = if _.isFunction action then action else action.method
    reload   = if _.isUndefined action.reload then true else action.reload
    dialog   = parseDialogAttribute action.dialog

    $scope.label  = $attrs.label
    $scope.icon   = if $attrs.icon and $attrs.icon != 'undefined' then $attrs.icon else undefined

    if $attrs.size in defaults.SUPPORTED_VALUES.NTA_ACTION_SIZE
      $scope.size = "btn-#{$attrs.size}"
    else
      $scope.size = defaults.DEFAULT_VALUES.NTA_ACTION_SIZE

    if $attrs.style in defaults.SUPPORTED_VALUES.NTA_ACTION_STYLE
      $scope.style = "btn-#{$attrs.style}"
    else
      $scope.style = "btn-#{defaults.DEFAULT_VALUES.NTA_ACTION_STYLE}"

    performAction = (item, index) ->
      $scope.mainScope.loading = true
      $q.when()
      .then    -> method(item, index)
      .then    -> $scope.tableParams.reload() if reload
      .finally -> delete $scope.mainScope.loading

    if !_.isEmpty action.dialog
      # Checks if ui.bootstrap.modal is available
      try
        $modal = $injector.get '$modal'

        # AngularUI Bootstrap Modal module is available
        performActionWithDialog = (item, index) ->
          params = dialog.params item, index

          # Launch modal
          modalScope = _.merge $scope.$new(true), params
          modalInstance = $modal.open
            templateUrl : dialog.templateUrl
            scope       : modalScope

          # Handle result
          modalInstance.result
          .then ->
            performAction item, index
          .catch ->
            if dialog and dialog.onCancel
              dialog.onCancel item, params

        triggerAction = performActionWithDialog

      catch error
        # AngularUI Bootstrap Modal module is not available
        triggerAction = performAction
    else
      triggerAction = performAction

    $scope.do = -> triggerAction $scope.item, $scope.$index
