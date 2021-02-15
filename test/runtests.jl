module TestVariantCallFormat

using Test
using VariantCallFormat

import BioCore: isfilled
import BioCore.Exceptions.MissingFieldException
import BufferedStreams: BufferedInputStream
import BioCore.Testing: get_bio_fmt_specimens
import YAML

fmtdir = get_bio_fmt_specimens()

include("vcf.jl")
include("bcf.jl")

end
