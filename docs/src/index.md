```@meta
CurrentModule = VCF
```

# VCF.jl

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](https://github.com/rasmushenningsson/VCF.jl/blob/main/LICENSE)

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

## Further Reading
[VCF and BCF file format descriptions.](https://samtools.github.io/hts-specs/)

