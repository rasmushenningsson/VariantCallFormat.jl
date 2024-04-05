module BCF

import VariantCallFormat: VCF, AbstractIO, isfilled, header
import BGZFStreams
import BufferedStreams

include("record.jl")
include("reader.jl")
include("writer.jl")

end
