### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ bf0e8d60-d704-4c66-ad3f-d372cb2963a2
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ c8b1224e-d1f3-4aaa-8d5b-26a7362af6f5
using HTTP

# ╔═╡ f3b4e922-34fd-432e-b45a-66ec7a4bea87
using Gumbo

# ╔═╡ a9544425-661d-472a-a9b4-67626a88e2ea
using AbstractTrees

# ╔═╡ 9732f467-bd58-4420-81d9-0011fc3d2a4e
using Cascadia

# ╔═╡ 7dba565b-24af-4eaa-ae0e-07e4d33876eb
using OpenAI

# ╔═╡ eb167d46-4631-40b3-8537-bc138cd6bf7e
using Dates

# ╔═╡ a36fa736-120b-4192-9781-0a5d39e3d51a
# include("../Summarize_Papers_with_GPT/support/api_module.jl")
include("../../../NLP_LLM/Summarize_Papers_with_GPT/support/api_module.jl")

# ╔═╡ 59d0b923-435a-4dc8-902f-02a9b5a177db
include("./utils.jl")

# ╔═╡ c94c972e-a75f-11ee-153c-771e07689f95
md"""
## Web Scraping article + synthesis

1. Web extraction
1. Synthesis

ref. "Advanced RAG: Enhancing Retrieval Efficiency through Rerankers using LlamaIndex"
"""

# ╔═╡ f4c27df9-bbc1-4498-b7a0-42da0d049199
const URL = "https://akash-mathur.medium.com/advanced-rag-enhancing-retrieval-efficiency-through-evaluating-reranker-models-using-llamaindex-3f104f24607e"

# ╔═╡ 797e6deb-e014-4609-b0d4-7f3ec670cb1c
const TOPIC = "advanced RAG with LlamaIndex using re-ranking"

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
const INSTRUCT_PROMPT = """Generate a comprehensive and detailed synthesis of the following excerpt (delimited by triple backticks) about $(TOPIC). 

Please provide all the details about the experiment conducted in this article:
- from ingestion to chunking then embedding and storinng,
- retrieval and reranking, taking note of the rerankers used and their performances.

As always, extract all the code snipets.""";

# ╔═╡ ba4e4c0f-2835-4a76-a9d4-7d7ba02becb2
println(INSTRUCT_PROMPT)

# ╔═╡ 27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
println(SYS_PROMPT)

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
	replace(OUTFILE, ".txt" => ".md")
)

# ╔═╡ 96f81b71-da5b-469b-80a6-a9b436491b61
@time req = HTTP.get(URL)

# ╔═╡ 67f54eb2-d985-4a57-a3f4-0d10ae033104
propertynames(req)

# ╔═╡ 4c25bfae-6f3f-4389-b4bf-adc706e64bc8
req.status

# ╔═╡ 2402d947-3e04-4495-9e92-1f59b171dcc8
parsed_doc = parsehtml(String(req.body));

# ╔═╡ dc32f9b1-b270-40a5-9067-4dad5bed40fa
md"""
### Extraction

#### In search of the root element

First we need to locate the node of interest...
"""

# ╔═╡ 791fd5f9-513c-45a6-83b7-0afc2593ef97
begin
  _root = parsed_doc.root[2].children[1].children[1]
  # println(parsed_doc.root[2].children[1].children)
end

# ╔═╡ e951a4d5-47ea-44b6-b3bc-1f4c9d7829b1
for elem ∈ PreOrderDFS(_root.children[1])  # main
    try
        if tag(elem) == :p
			# println(elem.children[1])
        	println(AbstractTrees.children(elem)[1])
			println("\t", AbstractTrees.children(elem)[2])
		end		
    catch
        # Nothing needed here
    end
end

# ╔═╡ 78389e7c-e6a5-4bd2-9274-d1a2c68a4920
rroot = parsed_doc.root[2].children[1].children[1];

# ╔═╡ ece5bc96-b302-4d8e-af5b-e093ab081ce3
function structure_llm_settings(root, selector="p.pw-post-body-paragraph")
	for (ix, element) ∈ enumerate(eachmatch(Selector(selector), rroot))
		print("ix: $(ix)")
		if hasproperty(element, :children)
			println(" current element has $(length(element.children)) child(ren)")
			
			for child ∈ element.children
				print("\t", propertynames(child))
			end
			println()
		end
	end
end

# ╔═╡ 8fdfb225-1475-483e-a81a-5a450b5b0dbd
structure_llm_settings(rroot)

# ╔═╡ f1dd1b92-b841-414b-8cca-d3bcdda675dd
md"""
#### Get the text
"""

# ╔═╡ b1309566-ded6-4f9f-a7b5-76e892991e65
function extract_llm_settings(root; selectors = ["p.nx-mt-6"], detect_code=false, verbose=true)::String
	fulltext = String[]
	sel_vec = vcat(
		(eachmatch(Selector(selector), rroot) for selector ∈ selectors)...
	)
	iscode = false
	for (ix, element) ∈ enumerate(sel_vec)
		verbose &&  println("$(ix) - [$(element)] /// [$(element.attributes["class"])]")

		iscode = detect_code && hasproperty(element, :attributes) && !occursin("pw-post-body-paragraph", element.attributes["class"])

		if hasproperty(element, :children)
			text = dft(element.children)
			text = iscode ? string("```code\n", text, "\n```") : text
			push!(fulltext, text)
		end

		iscode = false
	end

	join(
		filter(
			l -> length(strip(l)) > 0,
			fulltext
		),
		"\n"
	)
end

# ╔═╡ a76cd62d-98dc-4043-8a44-6b2020625f8f
function extract_links(
	root; 
	selector="a", verbose=true, restrict_to=["github", "LinkedIn"]
)::Vector{String}
	links = String[]
	for element ∈ eachmatch(Selector(selector), rroot)
		if hasproperty(element, :attributes)
			if match(join(restrict_to, "|") |> p -> Regex(p, "i"), element.attributes["href"]) !== nothing
				push!(links, element.attributes["href"])
			end
		end
	end
	links
end

# ╔═╡ 8fe89775-2853-49e4-885a-f3bdb1e792db
md_title = extract_llm_settings(rroot; selectors=[".pw-post-title"], verbose=false)  # Title

# ╔═╡ 72d4f892-2bd2-43af-b71e-5252a666ce0c
md = extract_llm_settings(rroot; selectors=[".bm"], verbose=false)  # other metadata

# ╔═╡ 67fd72dc-5540-440d-a8f3-8324914553b8
text = extract_llm_settings(
	rroot; 
	selectors=["p.pw-post-body-paragraph", "pre.ba.bj"],  #  "pre.ba.bj": for code snipet or "pre"
	detect_code=true,
	verbose=false
)
# html body div#root div.a.b.c div.l.c div.l div.fr.fs.ft.fu.fv.l article div.l div.l section div div.gk.gl.gm.gn.go div.ab.ca div.ch.bg.fw.fx.fy.fz pre.pr.ps.pt.pu.pv.pw.px.py.bo.pz.ba.bj span#4a9d.qa.op.gr.px.b.bf.qb.qc.l.qd.qe

# ╔═╡ ed56ba67-5e5a-43e9-9a5f-8e63597725f7
links = extract_links(
	rroot;
	selector="a", 
	verbose=false, 
	restrict_to=["github", "LinkedIn", "huggingface", "arxiv", "medium", "edu", "llamaindex", "langchain", "wikipedia", "cohere"]
)
# "towardsdatascience", "medium",
# https://docs.llamaindex.ai/en/stable/examples/retrievers/recursive_retriever_nodes.html

# ╔═╡ 0110956d-424d-4c7c-87ef-eda4a2cfc291
full_text = string(
	"- Title: ",  md_title, 
	"\n- Author and date: ", md, 
	"\n- Link: ", URL,
	"\nMain:\n", text, 
	"\n Links:\n", map(s -> string(" - ", s), links) |> links -> join(links, "\n")
)

# ╔═╡ 0df8719c-a91d-4449-8dac-337a832eb065
save_text(TXT_FILEPATH, full_text)

# ╔═╡ 0883ae28-a94f-4bed-abce-39841605d29b
md"""
### Synthesis
"""

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
 synthesis = make_timed_chat_request(
	 INSTRUCT_PROMPT,
	 full_text;
	 max_tokens=4096,
	 model="gpt-4-1106-preview",
	 temperature=0.1,
	 seed=117,
)
# Elapsed time for call to `make_openai_request_chat`: 39207 milliseconds

# ╔═╡ c4f7a724-fe95-45cb-94af-656cc5fbebb5
md"""
$(join(synthesis, "\n"))
"""

# ╔═╡ e4d711be-c885-404b-a51a-fda50c9d43c7
save_text(
	MD_FILEPATH,
	join(synthesis, "\n") # |> s -> replace(s, "```markdown" => "", "```" => "")
)

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
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
Cascadia = "54eefc05-d75b-58de-a785-1a3403f0919f"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
OpenAI = "e9f21f70-7185-4079-aca2-91159181367c"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractTrees = "~0.4.4"
Cascadia = "~1.0.2"
Gumbo = "~0.8.2"
HTTP = "~1.10.1"
OpenAI = "~0.9.0"
PlutoUI = "~0.7.54"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "0a481d0eecee663aff8ea9fc7e22e4eb9f375300"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.Cascadia]]
deps = ["AbstractTrees", "Gumbo"]
git-tree-sha1 = "c0769cbd930aea932c0912c4d2749c619a263fc1"
uuid = "54eefc05-d75b-58de-a785-1a3403f0919f"
version = "1.0.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

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

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenAI]]
deps = ["Dates", "HTTP", "JSON3"]
git-tree-sha1 = "c66f597044ac6cd41cbf4b191d59abbaf2003d9f"
uuid = "e9f21f70-7185-4079-aca2-91159181367c"
version = "0.9.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

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

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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
"""

# ╔═╡ Cell order:
# ╟─c94c972e-a75f-11ee-153c-771e07689f95
# ╠═bf0e8d60-d704-4c66-ad3f-d372cb2963a2
# ╠═c8b1224e-d1f3-4aaa-8d5b-26a7362af6f5
# ╠═f3b4e922-34fd-432e-b45a-66ec7a4bea87
# ╠═a9544425-661d-472a-a9b4-67626a88e2ea
# ╠═9732f467-bd58-4420-81d9-0011fc3d2a4e
# ╠═7dba565b-24af-4eaa-ae0e-07e4d33876eb
# ╠═eb167d46-4631-40b3-8537-bc138cd6bf7e
# ╠═a36fa736-120b-4192-9781-0a5d39e3d51a
# ╠═59d0b923-435a-4dc8-902f-02a9b5a177db
# ╠═f4c27df9-bbc1-4498-b7a0-42da0d049199
# ╠═797e6deb-e014-4609-b0d4-7f3ec670cb1c
# ╠═2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
# ╠═ba4e4c0f-2835-4a76-a9d4-7d7ba02becb2
# ╠═27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
# ╠═68c8922f-0cb2-41d9-9efe-3ed7a00dd76f
# ╠═2e10b0e3-66ac-4507-ad7b-a19089b85308
# ╠═077c29e0-f912-44aa-ac3a-633b12318fb0
# ╠═96f81b71-da5b-469b-80a6-a9b436491b61
# ╠═67f54eb2-d985-4a57-a3f4-0d10ae033104
# ╠═4c25bfae-6f3f-4389-b4bf-adc706e64bc8
# ╠═2402d947-3e04-4495-9e92-1f59b171dcc8
# ╟─dc32f9b1-b270-40a5-9067-4dad5bed40fa
# ╠═791fd5f9-513c-45a6-83b7-0afc2593ef97
# ╠═ece5bc96-b302-4d8e-af5b-e093ab081ce3
# ╠═e951a4d5-47ea-44b6-b3bc-1f4c9d7829b1
# ╠═78389e7c-e6a5-4bd2-9274-d1a2c68a4920
# ╠═8fdfb225-1475-483e-a81a-5a450b5b0dbd
# ╟─f1dd1b92-b841-414b-8cca-d3bcdda675dd
# ╠═b1309566-ded6-4f9f-a7b5-76e892991e65
# ╠═a76cd62d-98dc-4043-8a44-6b2020625f8f
# ╠═8fe89775-2853-49e4-885a-f3bdb1e792db
# ╠═72d4f892-2bd2-43af-b71e-5252a666ce0c
# ╠═67fd72dc-5540-440d-a8f3-8324914553b8
# ╠═ed56ba67-5e5a-43e9-9a5f-8e63597725f7
# ╠═0110956d-424d-4c7c-87ef-eda4a2cfc291
# ╠═0df8719c-a91d-4449-8dac-337a832eb065
# ╟─0883ae28-a94f-4bed-abce-39841605d29b
# ╠═e2ffe835-65dc-4c85-aa9a-d98867da2ff5
# ╟─c4f7a724-fe95-45cb-94af-656cc5fbebb5
# ╠═e4d711be-c885-404b-a51a-fda50c9d43c7
# ╟─322ecf98-5694-42a1-84f2-caf8a5fa58ad
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
