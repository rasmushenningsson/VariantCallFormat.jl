# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.9] - 2025-10-16

### Fixed
- Allow ':' characters in the CHROM field.

## [0.5.8] - 2025-10-14

### Fixed
- Fixed test failure on Julia 1.13 due to Dict order change. (Only affected unit tests.)

## [0.5.7] - 2025-08-19

### Changed
- Update to Automa.jl v1.

## [0.5.0] - 2020-02-18
Created VariantCallFormat.jl package, based on [GeneticVariation.jl](https://github.com/BioJulia/GeneticVariation.jl).

### Added
- Added Project.toml.

## Changed
- Removed functionality not related to VCF/BCF file IO.
- Removed several dependencies.
- Fixed hasinfo(record, key) bug

## [0.4.0] - 2018-11-22
### Added
- :arrow_up: Support for julia v0.7 / v1.0

### Changed
- Fixed an issue with parsing VCF files from recent GATK releases.

### Removed
- :exclamation: Dropped support for julia v0.6 and v0.7

## [0.3.2] - 2018-07-25
### Added
- Project files: HUMANS.md & CHANGELOG.md

### Changed
- Fixed an error in the `BCF.n_samples` getter method that was causing it to return incorrect values.
- Updated to README.md to latest style. 

## [0.3.1] - 2017-10-10
### Added
- Method computing the average number of mutations, that should have gone into
  version 0.3.0.

## [0.3.0] - 2017-10-05
### Added
- Number of segregating sites method.
- Methods for computing allele frequencies and nucleotide diversity from sequences.

### Changed
- Documentation updated.
- API changes to dN/dS methods.

## [0.2.0] - 2017-07-31
### Added
- MASH distances.
- NG86 method of dN/dS computation.
- Proportion distance.

### Removed
- :exclamation: Dropped support for julia v0.5.

## [0.1.0] - 2017-06-23

Initial release, split from [Bio.jl](https://github.com/BioJulia/Bio.jl).

[Unreleased]: https://github.com/rasmushenningsson/VariantCallFormat.jl/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/rasmushenningsson/VariantCallFormat.jl/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/BioJulia/GeneticVariation.jl/compare/v0.3.1...v0.4.0
[0.3.2]: https://github.com/BioJulia/GeneticVariation.jl/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/BioJulia/GeneticVariation.jl/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/BioJulia/GeneticVariation.jl/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/BioJulia/GeneticVariation.jl/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/BioJulia/GeneticVariation.jl/tree/v0.1.0
