module TestVariantCallFormat

using Test
using VariantCallFormat

import BufferedStreams: BufferedInputStream
import YAML

include("vcf.jl")
include("bcf.jl")

end
