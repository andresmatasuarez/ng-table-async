/**
 * ng-table-async
 * ngTable wrapper that offers some basic functionality and abstractions for working with asynchronous tables.
 * @author  Andrés Mata Suárez <amatasuarez@gmail.com>
 * @version 0.0.0
 * @link    https://github.com/andresmatasuarez/ng-table-async
 * @license MIT
 */
angular.module("ngTableAsync.templates", []).run(["$templateCache", function($templateCache) {$templateCache.put("_ng_table_async_action.html","<button type=\"button\" ng-click=\"do()\" class=\"btn {{size}} {{style}}\"><span ng-if=\"icon\"><span class=\"{{icon}}\"></span><span ng-if=\"label\">&nbsp;</span></span><span ng-bind=\"label\"></span></button>");
$templateCache.put("_ng_table_async_loading.html","<div class=\"nta-loading\"><div class=\"nta-loading-loader\"><i class=\"glyphicon glyphicon-refresh nta-loading-spinner\"></i></div></div>");
$templateCache.put("_ng_table_async_no_data.html","<div class=\"container no-data-container\"><div class=\"row\"><div class=\"col-md-6 col-md-offset-3\"><h2 ng-bind=\"text\" class=\"text-muted text-center\"></h2></div></div></div>");
$templateCache.put("_ng_table_async_pager.html","<div class=\"text-center\"><ul class=\"pagination ng-table-pagination\"><li ng-repeat=\"page in pages\" ng-class=\"{\'disabled active\': !page.active, \'previous\': page.type == \'prev\', \'next\': page.type == \'next\'}\" ng-switch=\"page.type\"><a ng-switch-when=\"prev\" ng-click=\"params.page(page.number)\" href=\"\">&lt;</a><a ng-switch-when=\"next\" ng-click=\"params.page(page.number)\" href=\"\">&gt;</a><a ng-switch-when=\"more\" ng-click=\"params.page(page.number)\" href=\"\">...</a><a ng-switch-default=\"\" ng-click=\"params.page(page.number)\" href=\"\">{{ page.number }}</a></li></ul></div>");}]);