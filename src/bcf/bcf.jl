module BCF

import VariantCallFormat: VCF, isfilled, header
import BioGenerics
import BGZFStreams
import BufferedStreams

include("record.jl")
include("reader.jl")
include("writer.jl")

end
