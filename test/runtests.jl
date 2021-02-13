module TestVCF

using Test
using VCF

import BioCore: isfilled
import BioCore.Exceptions.MissingFieldException
import BufferedStreams: BufferedInputStream
import BioCore.Testing: get_bio_fmt_specimens
import YAML

# import BioCore.Testing:
#     get_bio_fmt_specimens,
#     random_seq,
#     random_interval
# import BioCore.Exceptions.MissingFieldException
# using BioSequences, GeneticVariation
# import BufferedStreams: BufferedInputStream
# import IntervalTrees: IntervalValue
# import YAML

# function random_seq(::Type{A}, n::Integer) where A <: Alphabet
#     nts = alphabet(A)
#     probs = Vector{Float64}(undef, length(nts))
#     fill!(probs, 1 / length(nts))
#     return BioSequence{A}(random_seq(n, nts, probs))
# end

fmtdir = get_bio_fmt_specimens()

include("vcf.jl")
include("bcf.jl")

end
