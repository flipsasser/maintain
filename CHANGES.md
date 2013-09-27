## 0.3.0
* Rails 4 compatibility
* Fixed `bang!` methods not saving on the back end

## 0.2.22
* Added `bang!` method support, so now you can call `@object.awesome!`
  and its state will be set to "awesome." Like all Maintain methods,
  I'm saying f\*ck you to convention and letting you go nuts; you can
  achieve the same effect one of three ways:

  ```
  @object.awesome!
  @object.state.awesome!
  @object.state_awesome!
  ```

## 0.2.21
* Added Enumerable support to bitmask values, so now you can parse
  through flags with each, select, map, find, and more! This also
  means `to_a` is now a method on @object.maintained_attribute.

## 0.2.20
* Removed accidental debugging `puts` calls from ActiveRecord backend

## 0.2.19
* Added :force option to state and aggregate definitions, allowing you
  to force a method overwrite
* Added an attribute_name alias to named scopes in the ActiveRecord
  backend, since Rails 3.1 has eaten up a number of previously
  usable state names

## 0.2.18
* Ruby 1.9.2 and Rails 3.1 compatibility updates (no API changes)
