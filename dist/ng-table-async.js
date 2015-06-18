/*
 * ng-table-async
 * ngTable wrapper that offers some basic functionality and abstractions for working with asynchronous tables.
 * @author  Andrés Mata Suárez <amatasuarez@gmail.com>
 * @version 0.0.0
 * @link    https://github.com/andresmatasuarez/ng-table-async
 * @license MIT
 */
(function() {
  'use strict';
  angular.module('ngTableAsync', ['ngTable']);

}).call(this);

(function() {
  'use strict';
  var module, parseColumn, parseColumnContent, parseColumnHeader;

  module = angular.module('ngTableAsync');

  parseColumnContent = function(column) {
    var content, contentAttr, contentElement;
    column = angular.element(column);
    content = column.html();
    if (content) {
      contentElement = _.isEmpty(column.find('nta-content')) ? column : column.find('nta-content');
      content = "<td>" + contentElement[0].outerHTML + "</td>";
    } else {
      contentAttr = column.attr('content');
      content = contentAttr ? "<td ng-bind=\"" + contentAttr + "\"></td>" : "<td></td>";
    }
    return content;
  };

  parseColumnHeader = function(column) {
    var header;
    column = angular.element(column);
    header = _.isEmpty(column.attr('header')) ? '' : column.attr('header');
    if (header) {
      header = "<th ng-bind=\"" + header + "\"></th>";
    } else {
      if (!_.isEmpty(column.find('nta-content'))) {
        header = column.find('nta-header').html();
      }
      header = "<th>" + header + "</th>";
    }
    return header;
  };

  parseColumn = function(column) {
    return {
      header: parseColumnHeader(column),
      content: parseColumnContent(column)
    };
  };


  /**
    @ngdoc    directive
    @name     ngTableAsync
    @module   ngTableAsync
    @restrict E
    @description
    ngTable wrapper directive that offers some basic functionality for working with asynchronous tables.
   */

  module.directive('ngTableAsync', function($q, ngTableParams) {
    return {
      restrict: 'E',
      scope: {
        options: '='
      },
      template: function(element, attrs) {
        var columns, compiledContents, compiledHeaders, loadingElement, loadingTemplate, loadingTemplateUrl, ndaElement, ndaTemplate, ndaTemplateUrl, pagerElement, pagerTemplate, pagerTemplateUrl, parsedColumns;
        columns = element.find('nta-column');
        parsedColumns = _.map(columns, parseColumn);
        compiledHeaders = _.map(parsedColumns, 'header');
        compiledContents = _.map(parsedColumns, 'content');
        ndaElement = element.find('no-data');
        ndaTemplate = ndaElement.html();
        if (!ndaTemplate) {
          ndaTemplateUrl = ndaElement.attr('template-url');
          if (ndaTemplateUrl) {
            ndaTemplate = "<nta-no-data template-url=\"" + ndaTemplateUrl + "\"></nta-no-data>";
          } else {
            ndaTemplate = "<nta-no-data text=\"" + (ndaElement.attr('text')) + "\"></nta-no-data>";
          }
        }
        pagerElement = element.find('pager');
        pagerTemplateUrl = pagerElement.attr('template-url');
        pagerTemplate = "<nta-pager template-url=\"" + pagerTemplateUrl + "\"></nta-pager>";
        loadingElement = element.find('loading');
        loadingTemplateUrl = loadingElement.attr('template-url');
        loadingTemplate = "<nta-loading template-url=\"" + loadingTemplateUrl + "\"></nta-loading>";
        return "<div class=\"container-fluid nta-container\" ng-show=\"tableParams.total()\"> <div class=\"row\"> <div class=\"col-md-12\"> <div ng-if=\"options.pagerOnTop\"> " + pagerTemplate + " </div> <div class=\"nta-content row\"> <div class=\"panel panel-default\"> <table ng-table=\"tableParams\" class=\"table ng-table ng-table-responsive nta-table\"> <thead> <tr> " + (compiledHeaders.join(' ')) + " </tr> </thead> <tbody> <tr ng-repeat=\"item in $data\"> " + (compiledContents.join(' ')) + " </tr> </tbody> </table> </div> <div ng-show=\"loading\" class=\"nta-loading-container\"> " + loadingTemplate + " </div> </div> <div ng-if=\"options.pagerOnBottom\"> " + pagerTemplate + " </div> </div> </div> </div> <div ng-show=\"!tableParams.total()\"> " + ndaTemplate + " </div>";
      },
      controller: function($scope, $element, ngTableAsyncDefaults) {
        $scope.options = _.merge({
          pagerOnTop: ngTableAsyncDefaults.PAGER_ON_TOP,
          pagerOnBottom: ngTableAsyncDefaults.PAGER_ON_BOTTOM,
          firstPage: ngTableAsyncDefaults.FIRST_PAGE,
          pageSize: ngTableAsyncDefaults.PAGE_SIZE
        }, $scope.options);
        $scope.mainScope = $scope;
        return $scope.tableParams = new ngTableParams({
          page: $scope.options.firstPage,
          count: $scope.options.pageSize
        }, {
          $scope: $scope,
          getData: function($defer, params) {
            var limit, skip;
            $scope.loading = true;
            skip = (params.page() - 1) * params.count();
            limit = params.count();
            return $scope.options.getPage(skip, limit).then(function(results) {
              $scope.tableParams.total(results[0]);
              $defer.resolve(results[1]);
              return delete $scope.loading;
            });
          }
        });
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  var module;

  module = angular.module('ngTableAsync');


  /**
    @ngdoc       object
    @name        ngTableAsyncDefaults
    @module      ngTableAsync
    @description Default settings for ngTableAsync
   */

  module.value('ngTableAsyncDefaults', {
    FIRST_PAGE: 1,
    PAGE_SIZE: 10,
    NO_DATA_TEXT: 'No available results to show',
    PAGER_ON_TOP: false,
    PAGER_ON_BOTTOM: true,
    SUPPORTED_VALUES: {
      NTA_ACTION_SIZE: ['xs', 'sm', 'lg'],
      NTA_ACTION_STYLE: ['default', 'primary', 'success', 'info', 'warning', 'danger', 'link']
    },
    DEFAULT_VALUES: {
      NTA_ACTION_SIZE: '',
      NTA_ACTION_STYLE: 'default'
    },
    DEFAULT_TEMPLATES: {
      NTA_ACTION: '_ng_table_async_action.html',
      NTA_LOADING: '_ng_table_async_loading.html',
      NTA_NO_DATA: '_ng_table_async_no_data.html',
      NTA_PAGER: '_ng_table_async_pager.html'
    }
  });

}).call(this);

(function() {
  'use strict';
  var module, parseDialogAttribute,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  module = angular.module('ngTableAsync');

  parseDialogAttribute = function(d) {
    var dialog;
    dialog = d && d.templateUrl ? d : void 0;
    if (_.isUndefined(dialog) || _.isEmpty(dialog.params) || _.isFunction(dialog.params)) {
      return dialog;
    }
    dialog.params = function() {
      if (_.isEmpty(dialog.params)) {
        return void 0;
      }
    };
    dialog.params = function(item) {
      if (_.isObject(dialog.params)) {
        return dialog.params;
      }
    };
    if (_.isString(dialog.params)) {
      dialog.params = function(item) {
        var params;
        params = {};
        params[dialog.params] = item;
        return params;
      };
    }
    dialog.params = function(item) {
      return {
        item: item
      };
    };
    return dialog;
  };


  /**
    @ngdoc    directive
    @name     ntaAction
    @module   ngTableAsync
    @restrict E
    @description
    Renders an action button for ngTableAsync directive
   */

  module.directive('ntaAction', function(ngTableAsyncDefaults) {
    return {
      restrict: 'E',
      scope: true,
      templateUrl: function(element, attrs) {
        if (attrs.templateUrl && attrs.templateUrl !== 'undefined') {
          return attrs.templateUrl;
        } else {
          return ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_ACTION;
        }
      },
      controller: function($scope, $attrs, $q, $injector) {
        var $modal, action, defaults, dialog, error, method, performAction, performActionWithDialog, ref, ref1, reload, triggerAction;
        defaults = ngTableAsyncDefaults;
        action = $scope.options.actions[$attrs.action];
        method = _.isFunction(action) ? action : action.method;
        reload = _.isUndefined(action.reload) ? true : action.reload;
        dialog = parseDialogAttribute(action.dialog);
        $scope.label = $attrs.label;
        $scope.icon = $attrs.icon && $attrs.icon !== 'undefined' ? $attrs.icon : void 0;
        if (ref = $attrs.size, indexOf.call(defaults.SUPPORTED_VALUES.NTA_ACTION_SIZE, ref) >= 0) {
          $scope.size = "btn-" + $attrs.size;
        } else {
          $scope.size = defaults.DEFAULT_VALUES.NTA_ACTION_SIZE;
        }
        if (ref1 = $attrs.style, indexOf.call(defaults.SUPPORTED_VALUES.NTA_ACTION_STYLE, ref1) >= 0) {
          $scope.style = "btn-" + $attrs.style;
        } else {
          $scope.style = "btn-" + defaults.DEFAULT_VALUES.NTA_ACTION_STYLE;
        }
        performAction = function(item) {
          $scope.mainScope.loading = true;
          return $q.when().then(function() {
            return method(item);
          }).then(function() {
            if (reload) {
              return $scope.tableParams.reload();
            }
          })["finally"](function() {
            return delete $scope.mainScope.loading;
          });
        };
        if (!_.isEmpty(action.dialog)) {
          try {
            $modal = $injector.get('$modal');
            performActionWithDialog = function(item) {
              var modalInstance, modalScope, params;
              params = dialog.params(item);
              modalScope = _.merge($scope.$new(true), params);
              modalInstance = $modal.open({
                templateUrl: dialog.templateUrl,
                scope: modalScope
              });
              return modalInstance.result.then(function() {
                return performAction(item);
              })["catch"](function() {
                if (dialog && dialog.onCancel) {
                  return dialog.onCancel(item, params);
                }
              });
            };
            triggerAction = performActionWithDialog;
          } catch (_error) {
            error = _error;
            triggerAction = performAction;
          }
        } else {
          triggerAction = performAction;
        }
        return $scope["do"] = function() {
          return triggerAction($scope.item);
        };
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  var module;

  module = angular.module('ngTableAsync');


  /**
    @ngdoc    directive
    @name     ntaLoading
    @module   ngTableAsync
    @restrict E
    @description
    Renders the 'loading table' markup for ngTableAsync directive
   */

  module.directive('ntaLoading', function(ngTableAsyncDefaults) {
    return {
      restrict: 'E',
      templateUrl: function(element, attrs) {
        if (attrs.templateUrl && attrs.templateUrl !== 'undefined') {
          return attrs.templateUrl;
        } else {
          return ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_LOADING;
        }
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  var module;

  module = angular.module('ngTableAsync');


  /**
    @ngdoc    directive
    @name     ntaNoData
    @module   ngTableAsync
    @restrict E
    @description
    Renders a 'No available data' for ngTableAsync directive
   */

  module.directive('ntaNoData', function(ngTableAsyncDefaults) {
    return {
      restrict: 'E',
      scope: true,
      templateUrl: function(element, attrs) {
        if (attrs.templateUrl && attrs.templateUrl !== 'undefined') {
          return attrs.templateUrl;
        } else {
          return ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_NO_DATA;
        }
      },
      controller: function($scope, $element, $attrs) {
        if (!$attrs.text || $attrs.text === 'undefined') {
          $attrs.text = ngTableAsyncDefaults.NO_DATA_TEXT;
        }
        return $scope.text = $attrs.text;
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  var module;

  module = angular.module('ngTableAsync');


  /**
    @ngdoc    directive
    @name     ntaPager
    @module   ngTableAsync
    @restrict E
    @description
    Renders a pager for ngTableAsync directive
   */

  module.directive('ntaPager', function(ngTableAsyncDefaults) {
    return {
      restrict: 'E',
      template: function(element, attrs) {
        if (!attrs.templateUrl || attrs.templateUrl === 'undefined') {
          attrs.templateUrl = ngTableAsyncDefaults.DEFAULT_TEMPLATES.NTA_PAGER;
        }
        return "<div ng-table-pagination=\"tableParams\" template-url=\"'" + attrs.templateUrl + "'\"></div>";
      }
    };
  });

}).call(this);
