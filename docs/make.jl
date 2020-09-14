using DFUtils
using Documenter

makedocs(;
    modules=[DFUtils],
    authors="Daniel Winkler <danielw2904@disroot.org> and contributors",
    repo="https://github.com/danielw2904/DFUtils.jl/blob/{commit}{path}#L{line}",
    sitename="DFUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://danielw2904.github.io/DFUtils.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/danielw2904/DFUtils.jl",
)
