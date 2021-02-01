# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Support for Ruby@2.7.2, Ruby@3.0.0;

### Changed
- No more `TravisCI` (TODO: migrate to `Github Actions`);
- Updated development dependencies;

## [0.6.0] 2018-03-28
### Changed
- Removed verbose code from `#__actual_context__` and `#method` methods of
  `Symbiont::PublicTrigger` and `Symbiont::PrivateTrigger` classes.

## [0.5.0] 2018-03-28
### Added
- Support for method dispatching for `BasicObject` instances (which does not support `#respond_to?` method);
- Support for method extracting for `BasicObject` instances (which does not support `#method` method);
- Updated development dependencies;
- Support for `Ruby@2.6.2`, `Ruby@2.5.5`;

## [0.4.0] 2018-10-25
### Added
- Support for Ruby@2.5.3, Ruby@2.4.5, Ruby@2.3.8;
- Updated development dependencies;

### Changed
- End of Ruby@2.2;

## [0.3.0] 2018-06-15
### Added
- `Symbiont::Isolator` - proc object isolation layer for delayed invocations;

## [0.2.0] 2018-04-22
### Added
- Logo ^_^ (special thanks to **Viktoria Karaulova**)
- Support for multiple inner contexts: you can pass an array of objects as a context argument
  to `Symbiont::Executor`. Each object will be used as an inner context in order they are passed.

### Changed
- Method signature: context direction should be passed as a named attribute `context_direction:`.

  Affected methods:
  - `Symbiont::Executor.evaluate`
  - `Symbiont::Executor.evaluate_private`
  - `Symbiont::Executor.public_method`
  - `Symbiont::Executor.private_method`

## [0.1.0] - 2018-04-08
- Release :)
