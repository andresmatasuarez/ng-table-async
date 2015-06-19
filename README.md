ngTableAsync
=============================
**[ngTable](http://ng-table.com/)** wrapper that offers some base functionality and abstractions for working with asynchronous tables. It serves as a way to avoid table boilerplate code, by declaring only those things relevant in our context.

It's specially useful for developers, so they can come out with a fully functional asynchronous table with a default Bootstrap style in very few quick steps, when **behaviour has more priority than markup**.

This module **in no way** intends to be a replacement for **ngTable**, but an enhancement. If it doesn't satisfy your needs, go back to **ngTable**.

[Integral demo](http://plnkr.co/edit/3PYJbl3fCkDfLsLmZzMp)

## Requirements
* [AngularJS](https://angularjs.org/)
* [Lodash](https://lodash.com/)
* [ngTable](http://ng-table.com/)

## Optional requirements
* [UI.Bootstrap](https://angular-ui.github.io/bootstrap)

## Installation
`bower install ng-table-async`

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
* **`action`**: Key referencing an action in the actions array of **ngTableAsync**. See [Table configuration](#) section for more information.
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

## Examples
  TODO Write examples for each config

## Development
  TODO Write how to contribute and develop

## TODO
* Global override of templates.
