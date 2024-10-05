### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ bf0e8d60-d704-4c66-ad3f-d372cb2963a2
begin
        using PlutoUI

        using HTTP
        using Gumbo
        using Cascadia
        using OpenAI
        using URIs
        using JSON3
        using BytePairEncoding

        PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 59d0b923-435a-4dc8-902f-02a9b5a177db
include("./support/utils.jl")

# ╔═╡ b61d20de-c1dc-4f88-9266-1062dd9d5cd8
include("./support/ws_extractors.jl");

# ╔═╡ c94c972e-a75f-11ee-153c-771e07689f95
md"""
## Web Scraping article + synthesis

1. Web extraction
1. Synthesis

ref. "Transforming Small Language Models: How rStar Achieved a 411% Accuracy Boost Without Fine-Tuning"
"""

# ╔═╡ f4c27df9-bbc1-4498-b7a0-42da0d049199
const URL = "https://medium.com/@amisha.p/transforming-small-language-models-how-rstar-achieved-a-411-accuracy-boost-without-fine-tuning-d74472c1052f"

# ╔═╡ 797e6deb-e014-4609-b0d4-7f3ec670cb1c
const TOPIC = """rStar: mutual reasoning makes smaller language models (SLMs) stronger problem-solvers"""

# ╔═╡ 7df1d566-a7a8-4a9d-a477-2e2fea683e27
const LLM_PARAMS = Dict{Symbol, Union{String, Real, LLM_Model}}(
        :max_tokens => 8192 * 2,
        :model => DMODELS["o1-mini"],
        # No seed, no temperature for o1 models (for now, Sep. 2024)
        # :temperature => 0.2,
        # :seed => 117,
)

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
# No code block in this article, thus specific instruction about code block extraction and rendering can be omitted. Instead ask LLM to be thorough in the synthesis
# no need to invoke step by step - CoT approach with o1 models
# might have some issue with formatting...

const INSTRUCT_PROMPT = """Generate a comprehensive and detailed section by section synthesis of the following article (delimited by triple backticks) about "$(TOPIC)".

Important:
- Ignore any web links provided in the excerpt and refrain from commenting on them, as they will be addressed separately at a later stage. Consequently, do not include a "Links" section.
- Ensure that the synthesis is accurately structured into coherent sections, capturing every fact, key point, acronym, example, and explanation. Always begin with a section detailing the article's title, publication date, author, and link (when such information is available). Preserve all the original sections from the article for high fidelity. Aim for a synthesis that is exhaustive, without overlooking any significant information.
- Keep section title short (less than 15 words, longer than this eitther shorten it or make it a comment with bold emphasis).
- Avoid making comment while rendering the final synthesis.
- Format your output using markdown, making sure the title sections are separated from their contents by at least one empty line before the content and one empty line after the content - see example below.
- Itemize the first section about title, author, ...

Example of markdown section (delimited by triple backticks uniquely to clarify the boundaries - you do not to need to produce those backticks in your output):
```
## Section

The content paragraph...

## Another section

Another content paragraph...

```

And now here is the excerpt:
""";

# ╔═╡ ba4e4c0f-2835-4a76-a9d4-7d7ba02becb2
println(INSTRUCT_PROMPT)

# ╔═╡ 808c115f-57f6-499d-9c3b-b3dca7279508
# Not use but kept for API compatibility
_SYS_PROMPT = ""

# ╔═╡ 68c8922f-0cb2-41d9-9efe-3ed7a00dd76f
const OUTFILE = split(URL, "/")[end:end] |>
        v -> join(v, "-") |>
        s -> replace(s, r"\W" => "_") |>
        s -> string(s, ".txt") |>
        s -> replace(s, "-_" => "-")

# ╔═╡ 2e10b0e3-66ac-4507-ad7b-a19089b85308
const TXT_FILEPATH = string("text/", OUTFILE)

# ╔═╡ 077c29e0-f912-44aa-ac3a-633b12318fb0
const MD_FILEPATH = string(
        "results/synthesis_",
        replace(OUTFILE, ".txt" => "-$(LLM_PARAMS[:model].name).md")
)

# ╔═╡ e4e8ad7f-7ce3-489e-be50-3b04da063c44
begin
        full_text = nothing
        if isfile(TXT_FILEPATH)
                open(TXT_FILEPATH, "r") do fh
                        full_text = readlines(fh) |>
                                a -> join(a, "")
                end
        end
end

# ╔═╡ 96f81b71-da5b-469b-80a6-a9b436491b61
isnothing(full_text) && (@time req = HTTP.get(URL))

# ╔═╡ 67f54eb2-d985-4a57-a3f4-0d10ae033104
isnothing(full_text) && propertynames(req)

# ╔═╡ 4c25bfae-6f3f-4389-b4bf-adc706e64bc8
isnothing(full_text) && req.status

# ╔═╡ 2402d947-3e04-4495-9e92-1f59b171dcc8
isnothing(full_text) && (parsed_doc = Gumbo.parsehtml(String(req.body)));

# ╔═╡ dc32f9b1-b270-40a5-9067-4dad5bed40fa
md"""
### Extraction

#### In search of the root element

First we need to locate the node of interest...
"""

# ╔═╡ 78389e7c-e6a5-4bd2-9274-d1a2c68a4920
isnothing(full_text) && (rroot = parsed_doc.root[2].children[1].children[1]);

# ╔═╡ f496d90f-b390-442e-b809-86e4c19f34e6
isnothing(full_text) && (rroot |> propertynames, tag(rroot.parent))

# ╔═╡ 8fdfb225-1475-483e-a81a-5a450b5b0dbd
# traverse_article_structure(rroot; selector="p.pw-post-body-paragraph")

# ╔═╡ 67fd72dc-5540-440d-a8f3-8324914553b8
text = isnothing(full_text) ? extract_content(
        rroot;
        # selectors=["div.ch.bg.fy.fz.ga.gb"],
        selectors=["div.gn.go.gp.gq.gr"],
        verbose=true,
        only_tags=[:div, :p, :h1, :h2, :h3, :li, :ul, :ol, :span, :pre]  # include :pre for code snipet
) : ""

# ╔═╡ f1dd1b92-b841-414b-8cca-d3bcdda675dd
md"""
#### Get the content

- article's content
- code snipets (if present)
- web links
"""

# ╔═╡ 8fe89775-2853-49e4-885a-f3bdb1e792db
md_title = isnothing(full_text) ? extract_content(
        rroot;
        selectors=[".pw-post-title", "div.hv.hw"],  # good selector for the title, but may  miss author!
        # selectors=["div.ci.bh"]
        verbose=true,
        only_tags=[:h1, :h2],
) : ""  # Title

# ╔═╡ 72d4f892-2bd2-43af-b71e-5252a666ce0c
# metadata: author, date
md = isnothing(full_text) ? extract_content(
        rroot;
        selectors=["div.bn.bh.l"],
        # selectors=["p.pw-post-body-paragraph"],
        verbose=false,
        only_tags=[:div, :p, :span, :a]
) : ""  # other metadata

# ╔═╡ ed56ba67-5e5a-43e9-9a5f-8e63597725f7
links = isnothing(full_text) ? extract_links(
        rroot;
        selectors=["a"],
        verbose=false,
        restrict_to=["github", "LinkedIn", "huggingface", "arxiv", "medium", "edu", "llamaindex", "langchain", "wikipedia", "cohere"]
) : []

# ╔═╡ 0110956d-424d-4c7c-87ef-eda4a2cfc291
if isnothing(full_text)
        full_text₁ = string(
        "- Title: ",  md_title,
        "\n\n- Author and date: ", md,
        "\n\n- Link: ", URL,
        "\n\nMain:\n", text,
        "\n\n Links:\n", map(s -> string(" - ", s), links) |> links -> join(links, "\n")
        )
else
        full_text₁ = nothing
end

# ╔═╡ b80c155d-5ec2-4b3e-ac8d-6ee5cb18376b
# println(full_text)

# ╔═╡ 0df8719c-a91d-4449-8dac-337a832eb065
if !isfile(MD_FILEPATH)
        save_text(TXT_FILEPATH, full_text₁)
end

# ╔═╡ cea8ce05-77bb-452d-b0b5-2610ff38a3c2
text_for_synthesis = isnothing(full_text₁) ? full_text : full_text₁

# ╔═╡ 7f2b05e0-5058-408d-9a37-45bda8773d32
 match(r"(?<=Links:\s)(.*)"s, full_text).match

# ╔═╡ 0883ae28-a94f-4bed-abce-39841605d29b
md"""
### Synthesis
"""

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
synthesis = make_timed_chat_request(
         _SYS_PROMPT,
         INSTRUCT_PROMPT,
         text_for_synthesis;
         LLM_PARAMS...
)

# ╔═╡ 9b661918-23b6-46fb-9af1-53454d750d5f
begin
        found_links = links

        if length(links) == 0
                regex = r"(?<=Links:\s)(.*)"s
                matched = match(regex, full_text)
                found_links = Vector{Tuple{String, String}}()

                if matched !== nothing
                        links_section = matched.match
                link_regex = r"""- \("([^,]+)", "([^,]+)"\)"""  # r"- \[(.*?)\]\((.*?)\)"
                for m ∈ eachmatch(link_regex, links_section)
                        # Capture groups: first is link text, second is URL
                        link_text = m.captures[1]
                        url = m.captures[2]
                        push!(found_links, (string(link_text), string(url)))
                end
                end
                println("Found links:", found_links, " | length: ", length(found_links))
        end

        synthesis_links = length(found_links) > 0 ? string(
        join(synthesis, "\n"),
        "\n#### Links:\n",
        join(
            map(
                                tupl -> string("  - [", length(tupl[2]) > 0 ? tupl[2] : tag_link(tupl), "]", "($(tupl[1]))"),
                                handle_duplicate_tag(found_links)
                        ),
            "\n"
        )
        ) : join(synthesis, "\n")
end

# ╔═╡ e4d711be-c885-404b-a51a-fda50c9d43c7
save_text(
        MD_FILEPATH,
        synthesis_links
        # join(synthesis_links, "\n")
)

# ╔═╡ cdb9c685-050a-430e-bde4-cd18c496f2a8
md"""
---
"""

# ╔═╡ be4996ad-0379-495b-bb00-2eb3c0847227
md"""
### Resulting synthesis
"""

# ╔═╡ c4f7a724-fe95-45cb-94af-656cc5fbebb5
Markdown.parse(join(synthesis, "\n"))

# ╔═╡ fe39ac9a-88fc-4b35-9e91-e4d93b2187b3
md"""
---
"""

# ╔═╡ 322ecf98-5694-42a1-84f2-caf8a5fa58ad
html"""
<style>
  main {
    max-width: calc(1000px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BytePairEncoding = "a4280ba5-8788-555a-8ca8-4a8c3d966a71"
Cascadia = "54eefc05-d75b-58de-a785-1a3403f0919f"
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
OpenAI = "e9f21f70-7185-4079-aca2-91159181367c"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[compat]
BytePairEncoding = "~0.5.2"
Cascadia = "~1.0.2"
Gumbo = "~0.8.2"
HTTP = "~1.10.8"
JSON3 = "~1.14.0"
OpenAI = "~0.9.0"
PlutoUI = "~0.7.59"
URIs = "~1.5.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "1710a94bd9ca71da00d3d1501c548b2f5b408482"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.BytePairEncoding]]
deps = ["Artifacts", "Base64", "DataStructures", "DoubleArrayTries", "LRUCache", "LazyArtifacts", "StructWalk", "TextEncodeBase", "Unicode"]
git-tree-sha1 = "b8d2edaf190d01d6a1c30b80d1db2d866fbe7371"
uuid = "a4280ba5-8788-555a-8ca8-4a8c3d966a71"
version = "0.5.2"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.Cascadia]]
deps = ["AbstractTrees", "Gumbo"]
git-tree-sha1 = "c0769cbd930aea932c0912c4d2749c619a263fc1"
uuid = "54eefc05-d75b-58de-a785-1a3403f0919f"
version = "1.0.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "71acdbf594aab5bbb2cec89b208c41b4c411e49f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.24.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "a33b7ced222c6165f624a3f2b55945fac5a598d9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.7"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "Scratch", "p7zip_jll"]
git-tree-sha1 = "8ae085b71c462c2cb1cfedcb10c3c877ec6cf03f"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.13"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DoubleArrayTries]]
deps = ["OffsetArrays", "Preferences", "StringViews"]
git-tree-sha1 = "78dcacc06dbe5eef9c97a8ddbb9a3e9a8d9df7b7"
uuid = "abbaa0e5-f788-499c-92af-c35ff4258c82"
version = "0.1.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.FuncPipelines]]
git-tree-sha1 = "6484a27c35ecc680948c7dc7435c97f12c2bfaf7"
uuid = "9ed96fbb-10b6-44d4-99a6-7e2a3dc8861b"
version = "0.2.3"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.Gumbo]]
deps = ["AbstractTrees", "Gumbo_jll", "Libdl"]
git-tree-sha1 = "a1a138dfbf9df5bace489c7a9d5196d6afdfa140"
uuid = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
version = "0.8.2"

[[deps.Gumbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "29070dee9df18d9565276d68a596854b1764aa38"
uuid = "528830af-5a63-567c-a44a-034ed33b8444"
version = "0.10.2+0"

[[deps.HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "MacroTools", "PrecompileTools", "Requires", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "35ceea58aa34ad08b1ae00a52622c62d1cfb8ce2"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.24"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"
    LinearAlgebraExt = "LinearAlgebra"
    SparseArraysExt = "SparseArrays"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "b351d72436ddecd27381a07c242ba27282a6c8a7"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "9.0.0"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "f42bec1e12f42ec251541f6d0482d520a4638b17"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.33+0"

[[deps.LRUCache]]
git-tree-sha1 = "b3cc6698599b10e652832c2f23db3cab99d51b59"
uuid = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637"
version = "1.6.1"
weakdeps = ["Serialization"]

    [deps.LRUCache.extensions]
    SerializationExt = ["Serialization"]

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "ae52c156a63bb647f80c26319b104e99e5977e51"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.22"

    [deps.NNlib.extensions]
    NNlibAMDGPUExt = "AMDGPU"
    NNlibCUDACUDNNExt = ["CUDA", "cuDNN"]
    NNlibCUDAExt = "CUDA"
    NNlibEnzymeCoreExt = "EnzymeCore"
    NNlibFFTWExt = "FFTW"

    [deps.NNlib.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
    cuDNN = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenAI]]
deps = ["Dates", "HTTP", "JSON3"]
git-tree-sha1 = "c66f597044ac6cd41cbf4b191d59abbaf2003d9f"
uuid = "e9f21f70-7185-4079-aca2-91159181367c"
version = "0.9.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a028ee3cb5641cccc4c24e90c36b0a4f7707bdf5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.14+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.PartialFunctions]]
deps = ["MacroTools"]
git-tree-sha1 = "47b49a4dbc23b76682205c646252c0f9e1eb75af"
uuid = "570af359-4316-4cb7-8c74-252c00c2016b"
version = "1.2.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrimitiveOneHot]]
deps = ["Adapt", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "NNlib"]
git-tree-sha1 = "bbf8e986a586300ed8fd929db1f62bd158452b90"
uuid = "13d12f88-f12b-451e-9b9f-13b97e01cc85"
version = "0.2.1"

    [deps.PrimitiveOneHot.extensions]
    PrimitiveOneHotGPUArraysExt = "GPUArrays"
    PrimitiveOneHotMetalExt = ["Metal", "GPUArrays"]
    PrimitiveOneHotOneHotArraysExt = "OneHotArrays"

    [deps.PrimitiveOneHot.weakdeps]
    GPUArrays = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    OneHotArrays = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RustRegex]]
deps = ["rure_jll"]
git-tree-sha1 = "16be5e710d7b980678ec0d8c61d4c00e9a5591e3"
uuid = "cdf36688-0c6d-42c6-a883-5d2df16e9e88"
version = "0.1.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[deps.StringViews]]
git-tree-sha1 = "f7b06677eae2571c888fd686ba88047d8738b0e3"
uuid = "354b36f9-a18e-4713-926e-db85100087ba"
version = "1.3.3"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.StructWalk]]
deps = ["ConstructionBase"]
git-tree-sha1 = "ef626534f40a9d99b3dafdbd54cfe411ad86e3b8"
uuid = "31cdf514-beb7-4750-89db-dda9d2eb8d3d"
version = "0.2.1"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TextEncodeBase]]
deps = ["DataStructures", "DoubleArrayTries", "FuncPipelines", "PartialFunctions", "PrimitiveOneHot", "RustRegex", "StaticArrays", "StructWalk", "Unicode", "WordTokenizers"]
git-tree-sha1 = "66f827fa54c38cb7a7b174d3a580075b10793f5a"
uuid = "f92c20c0-9f2a-4705-8116-881385faba05"
version = "0.8.3"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "2d17fabcd17e67d7625ce9c531fb9f40b7c42ce4"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.2.1"

[[deps.WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.rure_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a24449573502225e7833277f99a8e2c19801f5a7"
uuid = "2a13b4fb-3cbe-5d55-9db2-86fcb16976f1"
version = "0.2.2+0"
"""

# ╔═╡ Cell order:
# ╟─c94c972e-a75f-11ee-153c-771e07689f95
# ╠═bf0e8d60-d704-4c66-ad3f-d372cb2963a2
# ╠═59d0b923-435a-4dc8-902f-02a9b5a177db
# ╠═b61d20de-c1dc-4f88-9266-1062dd9d5cd8
# ╠═f4c27df9-bbc1-4498-b7a0-42da0d049199
# ╠═797e6deb-e014-4609-b0d4-7f3ec670cb1c
# ╠═7df1d566-a7a8-4a9d-a477-2e2fea683e27
# ╠═2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
# ╠═ba4e4c0f-2835-4a76-a9d4-7d7ba02becb2
# ╟─808c115f-57f6-499d-9c3b-b3dca7279508
# ╠═68c8922f-0cb2-41d9-9efe-3ed7a00dd76f
# ╠═2e10b0e3-66ac-4507-ad7b-a19089b85308
# ╠═077c29e0-f912-44aa-ac3a-633b12318fb0
# ╠═e4e8ad7f-7ce3-489e-be50-3b04da063c44
# ╠═96f81b71-da5b-469b-80a6-a9b436491b61
# ╠═67f54eb2-d985-4a57-a3f4-0d10ae033104
# ╠═4c25bfae-6f3f-4389-b4bf-adc706e64bc8
# ╠═2402d947-3e04-4495-9e92-1f59b171dcc8
# ╟─dc32f9b1-b270-40a5-9067-4dad5bed40fa
# ╠═78389e7c-e6a5-4bd2-9274-d1a2c68a4920
# ╠═f496d90f-b390-442e-b809-86e4c19f34e6
# ╠═8fdfb225-1475-483e-a81a-5a450b5b0dbd
# ╠═67fd72dc-5540-440d-a8f3-8324914553b8
# ╟─f1dd1b92-b841-414b-8cca-d3bcdda675dd
# ╠═8fe89775-2853-49e4-885a-f3bdb1e792db
# ╠═72d4f892-2bd2-43af-b71e-5252a666ce0c
# ╠═ed56ba67-5e5a-43e9-9a5f-8e63597725f7
# ╠═0110956d-424d-4c7c-87ef-eda4a2cfc291
# ╠═b80c155d-5ec2-4b3e-ac8d-6ee5cb18376b
# ╠═0df8719c-a91d-4449-8dac-337a832eb065
# ╠═cea8ce05-77bb-452d-b0b5-2610ff38a3c2
# ╠═7f2b05e0-5058-408d-9a37-45bda8773d32
# ╟─0883ae28-a94f-4bed-abce-39841605d29b
# ╠═e2ffe835-65dc-4c85-aa9a-d98867da2ff5
# ╠═9b661918-23b6-46fb-9af1-53454d750d5f
# ╠═e4d711be-c885-404b-a51a-fda50c9d43c7
# ╟─cdb9c685-050a-430e-bde4-cd18c496f2a8
# ╟─be4996ad-0379-495b-bb00-2eb3c0847227
# ╠═c4f7a724-fe95-45cb-94af-656cc5fbebb5
# ╟─fe39ac9a-88fc-4b35-9e91-e4d93b2187b3
# ╟─322ecf98-5694-42a1-84f2-caf8a5fa58ad
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
