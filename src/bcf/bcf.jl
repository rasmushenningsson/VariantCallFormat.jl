module BCF

import BioCore: BioCore, isfilled, header
import VariantCallFormat: VCF
import BGZFStreams
import BufferedStreams

include("record.jl")
include("reader.jl")
include("writer.jl")

end
