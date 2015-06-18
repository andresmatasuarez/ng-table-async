ngTableAsync
=============================
[ngTable](http://ng-table.com/) wrapper that offers some base functionality and abstractions for working with asynchronous tables. It serves as a way to avoid table boilerplate code, by declaring only those things relevant in our context.

It's specially useful for developers, so they can come out with a fully functional asynchronous table with a default Bootstrap style in very few quick steps, when **behaviour has more priority than markup**.

[Integral demo](http://plnkr.co/edit/3PYJbl3fCkDfLsLmZzMp)

## Requirements
* [AngularJS](https://angularjs.org/)
* [Lodash](https://lodash.com/)
* [ngTable](http://ng-table.com/)

## Optional requirements
* [UI.Bootstrap](https://angular-ui.github.io/bootstrap)

## Installation
`bower install ng-table-async`

## Usage & configuration
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

**ngTableAsync** also defines the following directives for further customization:
* **`nta-action`**: to declare action buttons for each row element in the table, configurable through the following attributes.
  * **`label`**: Action button label
  * **`action`**: Key referencing an action in the actions array passed in the options to `ng-table-async` directive
  * **`size`**: Action button size, using Bootstrap size suffixes. Suppported values: `xs`, `sm`, `lg`. *Defaults to default button size*.
  * **`icon`**: Action Button icon class. *Defaults to no icon*.
  * **`style`**: Action button style, using Bootstrap style suffixes. Supported values: `default`, `primary`, `success`, `info`, `warning`, `danger`, `link`. *Defaults to `default`*.
  * **`template-url`**: Markup template url. Defaults to `'_ng_table_async_action.html'`
    * When overriding this template, **ngTableAsync** exposes all this attributes in the scope, plus a function `do`. You may or may not make use of them but you should ***not*** forget to call the `do` function in the template. For example: you can trigger the action with `ng-click="do()"`.
* **`nta-loading`**: to render the 'Loading table' markup, configurable through the following attributes:
  * **`template-url`**: Markup template url. Defaults to `'_ng_table_async_loading.html'`
* **`nta-no-data`**: to render the markup to show when table is empty, configurable through the following attributes:
  * **`text`**: Text to show when table is empty.
  * **`template-url`**: Markup template url. Defaults to `'_ng_table_async_no_data.html'`
    * When overriding this template, **ngTableAsync** exposes the `text` attribute in the scope. You may or may not make use of it.
* **`nta-pager`**: to render the pagination markup, configurable through the following attributes:
  * **`template-url`**: Markup template url. Defaults to `'_ng_table_async_pager.html'`
    * When overriding this template, please refer to **ngTable**'s documentation on how to override its pager.

## Examples
  TODO Write examples for each config

## Development
  TODO Write how to contribute and develop

## TODO
* Global override of templates.
