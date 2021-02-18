@testset "BCF" begin
    record = BCFRecord()
    @test !isfilled(record)
    @test occursin(r"^VariantCallFormat.BCFRecord: <not filled>", repr(record))
    @test_throws ArgumentError BCF.chrom(record)

    record = BCFRecord()
    record.sharedlen = 0x1c
    record.indivlen = 0x00
    # generated from bcftools 1.3.1 (htslib 1.3.1)
    record.data = parsehex("00 00 00 00 ff ff ff ff 01 00 00 00 01 00 80 7f 00 00 01 00 00 00 00 00 07 17 2e 00")
    record.filled = 1:lastindex(record.data)
    @test BCF.chrom(record) == 1
    record = BCFRecord(record)
    @test isa(record, BCFRecord)
    record = BCFRecord(record, chrom=4)
    @test BCF.chrom(record) == 4
    record = BCFRecord(record, pos=1234)
    @test BCF.pos(record) == 1234
    record = BCFRecord(record, qual=12.3)
    @test BCF.qual(record) == 12.3f0
    record = BCFRecord(record, id="rs1234")
    @test BCF.id(record) == "rs1234"
    record = BCFRecord(record, ref="AT")
    @test BCF.ref(record) == "AT"
    record = BCFRecord(record, alt=["ATT", "ACT"])
    @test BCF.alt(record) == ["ATT", "ACT"]
    record = BCFRecord(record, filter = [2, 3])
    @test BCF.filter(record) == [2, 3]
    record = BCFRecord(record, info=Dict(1 => Int8[42]))
    @test BCF.info(record) == [(1, 42)]
    @test BCF.info(record, simplify=false) == [(1, [42])]
    @test BCF.info(record, 1) == 42
    @test BCF.info(record, 1, simplify=false) == [42]

    bcfdir = joinpath(fmtdir, "BCF")
    reader = BCFReader(open(joinpath(bcfdir, "example.bcf")))
    let header = header(reader)
        @test length(findall(header, "fileformat")) == 1
        @test findall(header, "fileformat")[1] == VCF.MetaInfo("##fileformat=VCFv4.2")
        @test length(findall(header, "FORMAT")) == 4
    end
    record = BCFRecord()
    @test read!(reader, record) === record
    @test BCF.chrom(record) == 1
    @test BCF.pos(record) == 14370
    @test BCF.rlen(record) == 1
    @test BCF.id(record) == "rs6054257"
    @test BCF.ref(record) == "G"
    @test BCF.alt(record) == ["A"]
    @test BCF.qual(record) == 29.0
    @test BCF.filter(record) == [1]
    @test BCF.info(record) == [(1,3),(2,14),(3,0.5),(5,nothing),(6,nothing)]
    @test BCF.info(record, simplify = false) == [(1,[3]),(2,[14]),(3,[0.5]),(5,[]),(6,[])]
    @test BCF.genotype(record) == [(9,[[2,3],[4,3],[4,4]]),(10,[[48],[48],[43]]),(2,[[1],[8],[5]]),(11,[[51,51],[51,51],[-128,-128]])]
    @test BCF.genotype(record, 1) == [(9, [2,3]), (10, [48]), (2, [1]), (11, [51,51])]
    @test BCF.genotype(record, 1, 9) == [2,3]
    @test BCF.genotype(record, 1, 10) == [48]
    @test BCF.genotype(record, 2, 9) == [4,3]
    @test BCF.genotype(record, :, 9) == [[2,3],[4,3],[4,4]]
    @test occursin(r"^VariantCallFormat.BCFRecord:\n.*", repr(record))
    close(reader)

    # round-trip test
    for specimen in YAML.load_file(joinpath(bcfdir, "index.yml"))
        filepath = joinpath(bcfdir, specimen["filename"])
        records = BCFRecord[]
        reader = open(BCFReader, filepath)
        output = IOBuffer()
        writer = BCFWriter(output, header(reader))
        for record in reader
            write(writer, record)
            push!(records, record)
        end
        # HACK: take the data buffer before closing the writer
        data = output.data
        close(reader)
        close(writer)

        records2 = BCFRecord[]
        for record in BCFReader(IOBuffer(data))
            push!(records2, record)
        end
        @test records == records2
    end
end
