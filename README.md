# VCF.jl

<!--
[![Stable documentation](https://img.shields.io/badge/docs-stable-blue.svg?style=flat-square)](https://rasmushenningsson.github.io/VCF.jl/stable)
[![Latest documentation](https://img.shields.io/badge/docs-latest-blue.svg?style=flat-square)](https://rasmushenningsson.github.io/VCF.jl/latest)
-->

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](https://github.com/rasmushenningsson/VCF.jl/blob/master/LICENSE)
[![Build Status](https://github.com/rasmushenningsson/VCF.jl/workflows/CI/badge.svg)](https://github.com/rasmushenningsson/VCF.jl/actions)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/rasmushenningsson/VCF.jl?svg=true)](https://ci.appveyor.com/project/rasmushenningsson/VCF-jl)
[![Coverage](https://codecov.io/gh/rasmushenningsson/VCF.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rasmushenningsson/VCF.jl)


VCF.jl is based on previous work in [GeneticVariation.jl](https://github.com/BioJulia/GeneticVariation.jl).
Big thanks to the original authors!

## Description

VCF.jl provides read/write functionality for VCF (Variant Call Format) files as
well as for its binary sister format BCF.

VCF files are use ubiquitously in bioinformatics to represent genetic variants.


## Installation

Install VCF.jl from the Julia REPL:

```julia
using Pkg
Pkg.add("VCF")
```
(Note, this doesn't work just yet. But it will soon work when the package has
been registered in the Julia general package registry.)

## Further Reading
[VCF and BCF file format descriptions.](https://samtools.github.io/hts-specs/)

