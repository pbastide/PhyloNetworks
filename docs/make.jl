using Documenter, PhyloNetworks

makedocs()

deploydocs(
    deps   = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo = "github.com/pbastide/PhyloNetworks.jl.git",
    julia  = "0.6",
    osname = "linux",
    latest = "weave_doc"
)
