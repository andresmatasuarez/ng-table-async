(function() {
  'use strict';
  var app, parseAttribute, parseColumn, parseColumnContent, parseColumnHeader, prepareColumnHtml;

  app = angular.module('ngTableAsync', ['ngTable']);

  prepareColumnHtml = function(column) {
    return _.map(column.children(), function(child) {
      child = angular.element(child);
      if (child.is('action')) {
        return "<ng-table-async-button label  = \"" + (child.attr('label')) + "\" action = \"actions." + (child.attr('perform')) + "(item)\" style  = \"" + (child.attr('style')) + "\" size   = \"" + (child.attr('size')) + "\" icon   = \"" + (child.attr('icon')) + "\"> </ng-table-async-button>";
      } else {
        return child[0].outerHTML;
      }
    });
  };

  parseColumnContent = function(column) {
    var content, contentAttr, contentElement;
    column = angular.element(column);
    content = column.html();
    if (content) {
      contentElement = _.isEmpty(column.find('content')) ? column : column.find('content');
      content = "<td>" + (prepareColumnHtml(contentElement).join(' ')) + "</td>";
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
      if (!_.isEmpty(column.find('content'))) {
        header = column.find('header').html();
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

  parseAttribute = {
    pagerOnTop: function(v) {
      if (_.isUndefined(v)) {
        return DEFAULT_PAGER_ON_TOP;
      } else {
        return v;
      }
    },
    pagerOnBottom: function(v) {
      if (_.isUndefined(v)) {
        return DEFAULT_PAGER_ON_BOTTOM;
      } else {
        return v;
      }
    },
    firstPage: function(v) {
      return v || DEFAULT_FIRST_PAGE;
    },
    pageSize: function(v) {
      return v || DEFAULT_PAGE_SIZE;
    },
    actions: {
      dialog: {
        params: function(p) {
          if (_.isFunction(p)) {
            return p;
          }
          return function() {
            if (_.isEmpty(p)) {
              return void 0;
            }
          };
          return function(item) {
            if (_.isObject(p)) {
              return p;
            }
          };
          if (_.isString(p)) {
            return function(item) {
              var params;
              params = {};
              params[p] = item;
              return params;
            };
          }
          return function(item) {
            return {
              item: item
            };
          };
        }
      }
    }
  };


  /**
    @ngdoc       object
    @name        ngTableAsyncDefaults
    @module      ngTableAsync
    @description Default settings for ngTableAsync
   */

  app.value('ngTableAsyncDefaults', {
    FIRST_PAGE: 1,
    PAGE_SIZE: 10,
    NO_DATA_AVAILABLE_TEXT: "No available results to show",
    PAGER_ON_TOP: false,
    PAGER_ON_BOTTOM: true
  });


  /**
    @ngdoc    directive
    @name     ngTableAsync
    @module   ngTableAsync
    @restrict E
    @description
    ngTable wrapper directive that offers some basic functionality for working with asynchronous tables.
   */

  app.directive('ngTableAsync', function($q, $modal, ngTableParams) {
    return {
      restrict: 'E',
      scope: {
        options: '='
      },
      template: function(element, attrs) {
        var columns, compiledContents, compiledHeaders, ndaElement, ndaTemplate, ndaTemplateUrl, pagerElement, pagerTemplate, pagerTemplateUrl, parsedColumns;
        columns = element.find('column');
        parsedColumns = _.map(columns, parseColumn);
        compiledHeaders = _.map(parsedColumns, 'header');
        compiledContents = _.map(parsedColumns, 'content');
        ndaElement = element.find('no-data-available');
        ndaTemplate = ndaElement.html();
        if (!ndaTemplate) {
          ndaTemplateUrl = ndaElement.attr('template-url');
          if (ndaTemplateUrl) {
            ndaTemplate = "<ng-table-async-no-data-available template-url=\"" + ndaTemplateUrl + "\"></ng-table-async-no-data-available>";
          } else {
            ndaTemplate = "<ng-table-async-no-data-available text=\"" + (ndaElement.attr('text')) + "\"></ng-table-async-no-data-available>";
          }
        }
        pagerElement = element.find('pager');
        pagerTemplateUrl = pagerElement.attr('template-url');
        pagerTemplate = "<ng-table-async-pager template-url=\"" + pagerTemplateUrl + "\"></ng-table-async-pager>";
        return "<div class=\"container table-container\" ng-show=\"tableParams.total()\"> <div class=\"row\"> <div class=\"col-md-12\"> <div ng-if=\"options.pagerOnTop\"> " + pagerTemplate + " </div> <div class=\"table-content row\"> <div class=\"panel panel-default\"> <table ng-table=\"tableParams\" class=\"table ng-table ng-table-responsive\"> <thead> <tr> " + (compiledHeaders.join(' ')) + " </tr> </thead> <tbody> <tr ng-repeat=\"item in $data\"> " + (compiledContents.join(' ')) + " </tr> </tbody> </table> </div> <div ng-show=\"loadingTable\" class=\"loadingTable text-center\"> <i class=\"fa fa-spin fa-4x fa-spinner\"></i> </div> </div> <div ng-if=\"options.pagerOnBottom\"> " + pagerTemplate + " </div> </div> </div> </div> <div ng-show=\"!tableParams.total()\"> " + ndaTemplate + " </div>";
      },
      controller: function($scope, $element) {
        $scope.options = _.merge({
          pagerOnTop: DEFAULT_PAGER_ON_TOP,
          pagerOnBottom: DEFAULT_PAGER_ON_BOTTOM,
          firstPage: DEFAULT_FIRST_PAGE,
          pageSize: DEFAULT_PAGE_SIZE
        }, $scope.options);
        $scope.actions = _.map($scope.options.actions, function(action, key) {
          var confirmationMethodPromise, dialog, method, methodPromise, reload;
          method = _.isFunction(action) ? action : action.method;
          reload = _.isUndefined(action.reload) ? true : action.reload;
          dialog = action.dialog && action.dialog.templateUrl ? action.dialog : void 0;
          methodPromise = function(item) {
            $scope.loadingTable = true;
            return $q.when().then(function() {
              return method(item);
            }).then(function() {
              if (reload) {
                return $scope.tableParams.reload();
              }
            })["finally"](function() {
              return delete $scope.loadingTable;
            });
          };
          if (!dialog) {
            return [key, methodPromise];
          }
          confirmationMethodPromise = function(item) {
            var modalInstance, modalScope, params;
            params = parseAttribute.actions.dialog.params(dialog.params)(item);
            modalScope = _.merge($scope.$new(true), params);
            modalInstance = $modal.open({
              templateUrl: action.dialog.templateUrl,
              scope: modalScope
            });
            return modalInstance.result.then(function() {
              return methodPromise(item);
            })["catch"](function() {
              if (action.dialog && action.dialog.onCancel) {
                return action.dialog.onCancel(item, params);
              }
            });
          };
          return [key, confirmationMethodPromise];
        });
        $scope.actions = _.object($scope.actions);
        return $scope.tableParams = new ngTableParams({
          page: $scope.options.firstPage,
          count: $scope.options.pageSize
        }, {
          $scope: $scope,
          getData: function($defer, params) {
            var limit, skip;
            $scope.loadingTable = true;
            skip = (params.page() - 1) * params.count();
            limit = params.count();
            return $scope.options.getPage(skip, limit).then(function(results) {
              $scope.tableParams.total(results[0]);
              $defer.resolve(results[1]);
              return delete $scope.loadingTable;
            });
          }
        });
      }
    };
  });


  /**
    @ngdoc    directive
    @name     ngTableAsyncTableButton
    @module   ngTableAsync
    @restrict E
    @description
    Renders an action button for ngTableAsync directive
   */

  app.directive('ngTableAsyncButton', function() {
    return {
      restrict: 'E',
      scope: {
        action: '&',
        label: '=',
        size: '@',
        style: '@',
        icon: '@'
      },
      templateUrl: function(element, attrs) {
        if (attrs.templateUrl && attrs.templateUrl !== 'undefined') {
          return attrs.templateUrl;
        } else {
          return 'partials/_ng_table_async_button.html';
        }
      },
      link: function(scope, element, attrs) {
        var ref;
        attrs.size = (ref = attrs.size) === 'xs' || ref === 'sm' || ref === 'lg' ? "btn-" + attrs.size : '';
        attrs.style = attrs.style && attrs.style !== 'undefined' ? "btn-" + attrs.style : 'btn-default';
        return attrs.icon = attrs.icon && attrs.icon !== 'undefined' ? attrs.icon : void 0;
      }
    };
  });


  /**
    @ngdoc    directive
    @name     ngTableAsyncNoDataAvailable
    @module   ngTableAsync
    @restrict E
    @description
    Renders a 'No available data' for ngTableAsync directive
   */

  app.directive('ngTableAsyncNoDataAvailable', function() {
    return {
      restrict: 'E',
      templateUrl: function(element, attrs) {
        if (attrs.templateUrl && attrs.templateUrl !== 'undefined') {
          return attrs.templateUrl;
        } else {
          return 'partials/_ng_table_async_no_data_available.html';
        }
      },
      link: function(scope, element, attrs) {
        if (!attrs.text || attrs.text === 'undefined') {
          attrs.text = DEFAULT_NO_DATA_AVAILABLE_TEXT;
        }
        return scope.text = attrs.text;
      }
    };
  });


  /**
    @ngdoc    directive
    @name     ngTableAsyncPager
    @module   ngTableAsync
    @restrict E
    @description
    Renders a pager for ngTableAsync directive
   */

  app.directive('ngTableAsyncPager', function() {
    return {
      restrict: 'E',
      template: function(element, attrs) {
        if (!attrs.templateUrl || attrs.templateUrl === 'undefined') {
          attrs.templateUrl = 'partials/_ng_table_async_pager.html';
        }
        return "<div ng-table-pagination=\"tableParams\" template-url=\"'" + attrs.templateUrl + "'\"></div>";
      }
    };
  });

}).call(this);
