module BCF

import BioCore: BioCore
# import BioCore: BioCore, isfilled, header
import VariantCallFormat: VCF, AbstractIO, isfilled, header
import BGZFStreams
import BufferedStreams

include("record.jl")
include("reader.jl")
include("writer.jl")

end
