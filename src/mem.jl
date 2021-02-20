function memcpy(dst::Ptr, src::Ptr, n::Int)
    ccall(:memcpy, Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), dst, src, n)
    return nothing
end

function memcmp(p1::Ptr, p2::Ptr, n::Integer)
    return ccall(:memcmp, Cint, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), p1, p2, n)
end

# Check if `str == data[range]`
function isequaldata(str::String, data::Vector{UInt8}, range::UnitRange{Int})
    rlen = length(range)
    return rlen == sizeof(str) && memcmp(pointer(data, first(range)), pointer(str), rlen) == 0
end
