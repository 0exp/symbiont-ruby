# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Changed
- End of Ruby 2.2;

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
