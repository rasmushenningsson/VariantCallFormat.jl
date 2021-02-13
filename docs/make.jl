using Documenter, VCF

makedocs(
    modules = [VCF],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "VCF.jl",
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "VCF and BCF formatted files" => "man/vcf-bcf.md"
        ]
    ],
    authors = "Kenta Sato, Ben J. Ward, Rasmus Henningsson, The BioJulia Organisation and other contributors."
)

deploydocs(
    repo = "github.com/rasmushenningsson/VCF.jl.git",
)
