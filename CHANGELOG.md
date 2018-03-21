# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Support for multiple inner contexts: you can pass an array of objects as a context argument
  to `Symbiont::Executor`. Each object will be used as an inner context in order they are passed.

### Changed
- Method signature: context direction should be passed as a named attribute `context_direction:`.

## [0.1.0] - 2018-04-08
- Release :)
