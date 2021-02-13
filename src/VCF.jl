module VCF

import Automa
import Automa.RegExp: @re_str
import BioCore
import BioCore: isfilled, metainfotag, metainfoval, header
import BioCore.Exceptions: missingerror
import BufferedStreams

export
    BCF,
    header,
    metainfotag,
    metainfoval,
    isfilled,
    MissingFieldException

include("record.jl")
include("metainfo.jl")
include("header.jl")
include("reader.jl")
include("writer.jl")


include("bcf/bcf.jl")

end
