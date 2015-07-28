ngTableAsync
=============================
**[ngTable](http://ng-table.com/)** wrapper that offers some base functionality and abstractions for working with asynchronous tables. It serves as a way to avoid table boilerplate code, by declaring only those things relevant in our context.

It's specially useful for backoffice/dashboard developers, so they can come out with a fully functional asynchronous table with a default Bootstrap style in very few quick steps, where **behaviour has more priority than markup**.

This module **in no way** intends to be a replacement for **ngTable**, but an enhancement. If it doesn't satisfy your needs, submit a feature PR or go back to **ngTable** :).

[Homepage](https://andresmatasuarez.github.io/ng-table-async/)

## Index
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Configuration object](#configuration-object)
5. [Examples](#examples)
6. [Development](#development)
7. [TODO](#todo)
8. [License](#license)

## Requirements
* [AngularJS](https://angularjs.org/)
* [Bootstrap](http://getbootstrap.com/) - styles only
* [Lodash](https://lodash.com/)
* [ngTable](http://ng-table.com/)

### Optional requirements
* [UI.Bootstrap](https://angular-ui.github.io/bootstrap)

## Installation
1. Install with **[Bower](http://bower.io/)**:<br />
`bower install ng-table-async`
2. Include dependency files in your markup:
  * `<link rel="stylesheet" href="bootstrap.css">`
  * `<script src="lodash.js"></script>`
  * `<script src="angular.js"></script>`
  * `<script src="ui-boostrap.js"></script>`
  * `<script src="ng-table.js"></script>`
3. Include **ngTableAsync** files in your markup:
  * `<link rel="stylesheet" href="ng-table-async.css"></script>`
  * `<script src="ng-table-async.js"></script>`
4. Include **ngTableAsync** as a module dependency in your **AngularJS** app:<br />
`angular.module('myApp', [ ... 'ngTableAsync' ... ])`

> NOTE: `ng-table-async.js` contains the raw **ngTableAsync** module, whereas `ng-table-async-tpls.js` also includes default directives' templates.
> If you choose the first, you must supply all templates yourself, just the same as if you choose `ui-bootstrap.js` over `ui-boostrap-tpls.js`.

## Usage
  ngTableAsync offers a way to write HTML tables in a column-oriented declarative way:
```html
<ng-table-async options="tableOptions">
  <nta-column header="'id'" content="item.id"></nta-column>
  <nta-column header="'Email'" content="item.email"></nta-column>
  <nta-column header="'Counter'">
    <span ng-bind="item.counter"></span>
    <nta-action action="increment" size= "xs" icon="glyphicon glyphicon-plus"></nta-action>
  </nta-column>
  <nta-column>
    <nta-header>Actions</nta-header>
    <nta-content>
      <nta-action label="Reset counter" action="reset" size="xs" icon="glyphicon glyphicon-ban-circle"></nta-action>
      <nta-action label="Remove" action="remove" size="xs" icon="glyphicon glyphicon-trash" style="danger"></nta-action>
    </nta-content>
  </nta-column>
</ng-table-async>
```
* **`nta-column`**: defines a column.
  * Children
    * **`nta-header`**: defines HTML markup for column header
    * **`nta-content`**: defines HTML markup for column content.

By looking at the above example, we can infer that:
* Both children of `nta-column` can also be defined as `header` and `content` attributes of the `nta-column` element, respectively.
* Child-wise definition takes more precedence than attribute-wise definition.
* If the only child of `nta-column` is `nta-content`, then we can skip the `nta-content` tag.
* There is a `nta-action` element that seems to define an action.

### Directives
**ngTableAsync** also defines the following directives for further customization:

#### Directive: `ntaAction`
To declare action buttons for each row element in the table. It is only allowed as child of `nta-header` or `nta-content` elements. Supports the following attributes configuration:
* **`label`**: Action button label
* **`action`**: Key referencing an action in the actions array of **ngTableAsync**. See [Configuration object](#configuration-object) section for more information.
* **`size`**: Action button size, using Bootstrap size suffixes. Suppported values: `xs`, `sm`, `lg`. *Defaults to default button size*.
* **`icon`**: Action Button icon class. *Defaults to no icon*.
* **`style`**: Action button style, using Bootstrap style suffixes. Supported values: `default`, `primary`, `success`, `info`, `warning`, `danger`, `link`. *Defaults to `default`*.
* **`template-url`**: Markup template url. Defaults to `'_ng_table_async_action.html'`
  > When overriding this template, **ngTableAsync** exposes all this attributes in the scope, plus a function `do`. You may or may not make use of them but you should ***not*** forget to call the `do` function to trigger the action in the template. For example: include `ng-click="do()"` in some button in your custom template.

```html
<ng-table-async>
  ...
  <nta-action
    label="Delete me!"
    action="delete"
    size="xs"
    icon="glyphicon glyphicon-trash"
    style="danger"
    template-url="my_custom_action.html"></nta-action>
  ...
</ng-table-async>
```

#### Directive: `ntaLoading`
To render the 'Loading table' markup. Supports the following attributes configuration:
* **`template-url`**: Markup template url. Defaults to `'_ng_table_async_loading.html'`

```html
<ng-table-async>
  ...
  <nta-loading template-url="my_custom_loading.html"></nta-loading>
  ...
</ng-table-async>
```
> NOTE: `ntaLoading` directive is **only** used to override 'Loading table' page template. **Neither its location nor the times it is included in the markup** have any kind of influence in the resulting table.

#### Directive: `ntaNoData`
To render the markup to show when table is empty. Supports the following attribute configuration:
* **`text`**: Text to show when table is empty.
* **`template-url`**: Markup template url. Defaults to `'_ng_table_async_no_data.html'`
  > When overriding this template, **ngTableAsync** exposes the `text` attribute in the scope of the template. You may or may not make use of it.

```html
<ng-table-async>
  ...
  <nta-no-data text="Table is empty!!" template-url="my_custom_no_data.html"></nta-no-data>
  ...
</ng-table-async>
```
> NOTE: `ntaNoData` directive is **only** used to override 'No results available' page template. **Neither its location nor the times it is included in the markup** have any kind of influence in the resulting table.

#### Directive: `ntaPager`
To render the pagination markup template. Supports the following attribute configuration:
* **`template-url`**: Markup template url. Defaults to `'_ng_table_async_pager.html'`
  > When overriding this template, please refer to **ngTable**'s documentation on how to override its pager.

```html
<ng-table-async>
  ...
  <nta-pager template-url="my_custom_pager.html"></nta-pager>
  ...
</ng-table-async>
```
> NOTE: `ntaPager` directive is **only** used to override pager's template. **Neither its location nor the times it is included in the markup** have any kind of influence in the resulting table.

## Configuration object
**ngTableAsync** accepts an `options` attribute for initialization of table-level settings:
```html
<ng-table-async options="tableOptions">
  ...
</ng-table-async>
```
Of course, `tableOptions` should be exposed in the scope where **ngTableAsync** is being created, and it can contain any of the following properties:
```javascript
$scope.tableOptions = {
  defaultPage   : 3,     // Default selected page.                        Defaults to 1.
  pageSize      : 5,     // Table page size.                              Defaults to 10.
  pagerOnTop    : true,  // Enable pager above table.                     Defaults to false.
  pagerOnBottom : false, // Enable pager below table.                     Defaults to true.
  headerIfEmpty : false, // Do not hide table header when table is empty. Defaults to true.

  // REQUIRED
  // Function to retrieve current page's data, in terms of 'skip' and 'limit' params
  // skip: rows to skip from the beggining of the data.
  // limit: quantity of rows to return.
  // Returns a promise of an array of data.
  getPage: function(skip, limit){
    returns API.items.getPage(skip, limit);
  },

  // Actions
  // Each action can be a Function or an Object.
  actions: {

    // Action definition using Object form
    actionName: {
      reload: false,  // Reload table on this action's completion. Defaults to true.
      method: function(item){
        // Action to perform on row item.
        // If a promise is not returned, it will be promisified internally.
        // ngTableAsync will render the 'Loading table' markup until action completion.
      },

      // If action requires confirmation dialog.
      // Action method will only be triggered on dialog acceptance.
      // IMPORTANT: UI.Bootstrap should be included for dialog to work.
      dialog: {
          templateUrl : '_my_action_dialog.html',
          params      : {}                         // Params to be passed to dialog template scope.
          onCancel    : function(item, params){}   // To be called on dialog cancel
      }
    },

    // Action definition using Function form.
    // Simplest form to define an action.
    // Table will be reload on completion, and no dialog confirmation is required.
    // Same as: anotherActionName: { method: function(item){} }
    anotherActionName: function(item){},
  }
};
```

## Examples
  You can view a variety of usage examples in [ngTableAsync homepage](https://andresmatasuarez.github.io/ng-table-async/).

## Development
1. Fork repo
2. `npm install && bower install`
3. `npm install gulp -g`
4. `gulp` - Watches for changes in `src` directory and reruns tasks on each modified file. Outputs are in `dist` directory.
4. Write contribution
5. Write tests
6. Submit Pull Request

## TODO
* Tests
* Global override of templates.
* Receive custom ngTable configuration object and use it on ngTableParams instantiation.
* Basic sorting and filtering out of the box.

## License
The MIT License (MIT)

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
