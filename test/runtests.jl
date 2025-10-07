module TestVariantCallFormat

using Test
using VariantCallFormat

import BufferedStreams: BufferedInputStream
import YAML

using OrderedCollections: OrderedDict

include("vcf.jl")
include("bcf.jl")

end
