# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.1] - 2026-07-25

- TAG: [v0.1.1][0.1.1t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 19.35% documented

### Changed

- Lowered the published runtime Ruby floor to Ruby 2.4.0 so Kettle tools that
  support older Rubies can depend on `kettle-ndjson`.

## [0.1.0] - 2026-07-25

- TAG: [v0.1.0][0.1.0t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 19.35% documented
- Initial release

### Added

- Added `Kettle::Ndjson` event stream, recorder, filter, timing, step,
  diagnostic, and summary helpers for newline-delimited JSON CLI events.

### Changed

- kettle-jem-template-initial - Initial templating by kettle-jem.

[Unreleased]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.0...v0.1.1
[0.1.1t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.1
[0.1.0]: https://github.com/kettle-dev/kettle-ndjson/compare/b960037607f365b15262f5bf24417ded4dca5378...v0.1.0
[0.1.0t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.0
