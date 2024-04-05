module TestVariantCallFormat

using Test
using VariantCallFormat

# import BioCore: isfilled
import BioCore.Exceptions.MissingFieldException
import BufferedStreams: BufferedInputStream
import YAML

include("vcf.jl")
include("bcf.jl")

end
