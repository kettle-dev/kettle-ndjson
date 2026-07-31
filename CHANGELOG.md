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

- `release_lockfile` and `release_probe` are now first-class NDJSON event types
  for release tooling that needs to surface lockfile reset and published-gem
  availability probe activity.

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.6] - 2026-07-31

- TAG: [v0.1.6][0.1.6t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 25.81% documented

### Added

- `remote_parity` is now a first-class NDJSON event type for release tooling
  that needs to surface remote fetch, skip, failure, and parity activity.

- `ci_monitor` is now a first-class NDJSON event type for release tooling that
  needs to surface CI monitoring lifecycle activity.

- `pre_release` is now a first-class NDJSON event type for release tooling that
  needs to surface pre-release check activity.

- `changelog` is now a first-class NDJSON event type for release tooling that
  needs to surface changelog plan and coverage activity.

## [0.1.4] - 2026-07-31

- TAG: [v0.1.4][0.1.4t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 25.81% documented

### Added

- `secret_provider` is now a first-class NDJSON event type for release tooling
  that needs to surface secret-provider keepalive and prompt activity.

## [0.1.3] - 2026-07-30

- TAG: [v0.1.3][0.1.3t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 25.81% documented

### Added

- kettle-jem-template-20260729-005 - Gemspec metadata now publishes this
  project's RubyForum tag as `mailing_list_uri`, and support docs link to the
  tagged RubyForum community alongside Discord.

### Fixed

- kettle-jem-template-20260728-004 - Generated dep-heads workflows now use the
  setup-ruby Bundler install path for direct appraisal Gemfiles, avoiding rv
  lockfile parser failures on Git and path dependencies.
- kettle-jem-template-20260728-005 - VersionGem bootstrap now creates the
  missing canonical version spec when a project only has shim namespace version
  specs.
- kettle-jem-template-20260729-001 - Generated JRuby 9.4 workflows now use the
  legacy manual bundle install path, avoiding setup-time Bundler full-index
  failures against `gem.coop`.
- kettle-jem-template-20260729-002 - VersionGem bootstrap now preserves
  and templates dedicated `version_gem.rb` entrypoints even when the gemspec
  dependency is intentionally omitted, and generated anonymous-loader specs
  cover both `version.rb` and `version_gem.rb`.
- kettle-jem-template-20260729-003 - Old-Ruby gems below the VersionGem runtime
  floor now get managed minimal `version.rb` files and anonymous-loader version
  specs without adding `version_gem`.

- kettle-jem-template-20260730-001 - Gemspec package file enumeration now runs
  relative to the gemspec directory, so packaged template assets are included
  even when the gemspec is loaded from another working directory.

## [0.1.2] - 2026-07-28

- TAG: [v0.1.2][0.1.2t]
- COVERAGE: 100.00% -- 74/74 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 25.81% documented

### Added

- kettle-jem-template-20260726-001 - Projects now include YARD lint
  configuration and documentation dependencies so documentation issues fail
  before generated docs are refreshed.

- kettle-jem-template-20260727-001 - Spec harness documentation now lists the
  RSpec helpers provided by `kettle-test`.

### Changed

- kettle-jem-template-20260716-001 - Shim gems now package `LICENSE.md` instead
  of a missing `LICENSE.txt` file.
- kettle-jem-template-20260716-002 - Gemspecs now ship fewer repository-only
  files, reducing package noise for downstream packagers.
- kettle-jem-template-20260720-001 - READMEs can now display configured
  corporate sponsor logos.
- kettle-jem-template-20260720-002 - Development Gemfiles now use the released
  `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260720-003 - StructuredMerge Git diff driver config now
  uses the installed `smorg-rb` driver command.
- kettle-jem-template-20260720-004 - MRI-only projects now omit JRuby and
  TruffleRuby workflow jobs.
- kettle-jem-template-20260720-005 - README Support & Community links now
  include RubyForum.
- kettle-jem-template-20260725-001 - Release pull request branches beginning
  with `feature/release` now run JRuby and TruffleRuby workflows.
- kettle-jem-template-20260725-002 - Version specs now use `anonymous_loader` to
  cover `version.rb` without redefining constants, or are removed when version
  specs are not managed for the project.

- kettle-jem-template-20260728-001 - Generated Ruby workflows now use clearer
  setup-ruby-flash planning and can prepare appraisal-only jobs without
  installing the main Gemfile bundle.

### Fixed

- kettle-jem-template-20260726-002 - Generated version files now document their
  version namespace and constants, reducing warning-only YARD lint output.

- kettle-jem-template-20260726-003 - Coverage upload steps now treat Coveralls,
  QLTY, and Codecov as optional, so provider outages do not fail CI when local
  coverage thresholds still pass.
- kettle-jem-template-20260728-002 - Generated RuboCop configs now ignore the
  same `gemfiles/vendor/bundle` tree as `.gitignore`, so vendored dependency
  installs are not reported as project lint debt.
- kettle-jem-template-20260728-003 - Generated dep-heads workflows now run
  TruffleRuby jobs with current RubyGems and Bundler, avoiding setup failures
  before the test suite starts.

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

[Unreleased]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.6...HEAD
[0.1.6]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.4...v0.1.6
[0.1.6t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.6
[0.1.4]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.3...v0.1.4
[0.1.4t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.4
[0.1.3]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.2...v0.1.3
[0.1.3t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.3
[0.1.2]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.1...v0.1.2
[0.1.2t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.2
[0.1.1]: https://github.com/kettle-dev/kettle-ndjson/compare/v0.1.0...v0.1.1
[0.1.1t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.1
[0.1.0]: https://github.com/kettle-dev/kettle-ndjson/compare/b960037607f365b15262f5bf24417ded4dca5378...v0.1.0
[0.1.0t]: https://github.com/kettle-dev/kettle-ndjson/releases/tag/v0.1.0
