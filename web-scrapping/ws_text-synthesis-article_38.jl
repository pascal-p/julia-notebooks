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
include("./support/ws_extractors.jl")

# ╔═╡ c94c972e-a75f-11ee-153c-771e07689f95
md"""
## Web Scraping article + synthesis

1. Web extraction
1. Synthesis

ref. "Automating Prompt Engineering with DSPy and Haystack"
"""

# ╔═╡ f4c27df9-bbc1-4498-b7a0-42da0d049199
const URL = "https://towardsdatascience.com/automating-prompt-engineering-with-dspy-and-haystack-926a637a3f43"

# ╔═╡ 797e6deb-e014-4609-b0d4-7f3ec670cb1c
const TOPIC = "LLM (Large Language Models) and automating prompt engineering"

# ╔═╡ 7df1d566-a7a8-4a9d-a477-2e2fea683e27
const LLM_PARAMS = Dict{Symbol, Union{String, Real, LLM_Model}}(
	:max_tokens => 8192,
	:model => DMODELS["gpt-4o-2024-08-06"],
	:temperature => 0.2,
	:seed => 117,
)

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
const INSTRUCT_PROMPT = """Generate a comprehensive and detailed section-by-section synthesis of the following article (delimited by triple backticks) about "$(TOPIC)". In particular, include all the examples with their associated output code blocks.

Important:
- Ignore any web links provided in the excerpt and refrain from commenting on them, as they will be addressed separately at a later stage. Consequently, do not include a "Links" section.
- Render all code blocks, as delimited by "```code" and "```", verbatim, in full, and exactly once, including the code explanation from the original article. 
  - For the Python code blocks, apply proper formatting by using an indent of two space characters and vertical spacing between logical units such as loops, functions, methods and classes... 
  - The output code blocks which represent program outputs must be rendered pre-formatted. 

Here is the excerpt:
""";

# ╔═╡ ba4e4c0f-2835-4a76-a9d4-7d7ba02becb2
println(INSTRUCT_PROMPT)

# ╔═╡ 808c115f-57f6-499d-9c3b-b3dca7279508
# for some reason SYS_PROMPT as defined `support/utils.jl` is not entierly followed by the LLM.
# therefore shorten it amd move section about code block isnto USER_PROMPT...
# ..and redefining `SYS_PROMPT` as `_SYS_PROMPT`

_SYS_PROMPT = """You are a smart AI research assistant tasked with analyzing and synthesizing articles. You are thorough and deliberate in your approach before drafting your answers. You excel at organizing the provided articles into coherent sections, with introductions and conclusions that highlight the main ideas, reasoning, and contributions.

Proceed methodically, step by step, ensuring that the synthesis is accurately structured into coherent sections, capturing every fact, key point, acronym, example, and explanation. Always begin with a section detailing the article's title, publication date, author, and link (when such information is available). Preserve all the original sections from the article for high fidelity. Aim for a synthesis that is exhaustive, without overlooking any significant information.

Your style is formal, logical, and precise. Refrain from making comments about your synthesis. You value consistency and completeness. You format the synthesis with Markdown, clearly separating sections, subsections, lists etc..."""

# ╔═╡ 27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
println(_SYS_PROMPT)

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
parsed_doc = Gumbo.parsehtml(String(req.body));

# ╔═╡ dc32f9b1-b270-40a5-9067-4dad5bed40fa
md"""
### Extraction

#### In search of the root element

First we need to locate the node of interest...
"""

# ╔═╡ 78389e7c-e6a5-4bd2-9274-d1a2c68a4920
rroot = parsed_doc.root[2].children[1].children[1];

# ╔═╡ f496d90f-b390-442e-b809-86e4c19f34e6
rroot |> propertynames, tag(rroot.parent)

# ╔═╡ 8fdfb225-1475-483e-a81a-5a450b5b0dbd
# traverse_article_structure(rroot; selector="p.pw-post-body-paragraph")

# ╔═╡ 67fd72dc-5540-440d-a8f3-8324914553b8
text = extract_content( 
	rroot;
	# selectors=["div.ch.bg.fy.fz.ga.gb"],  # 
	# selectors=["p.pw-post-body-paragraph"],
	selectors=["div.gn.go.gp.gq.gr"],
	verbose=true,
	only_tags=[:div, :p, :h1, :h2, :h3, :li, :ul, :ol, :span, :pre]  # include :pre for code snipet
)

# ╔═╡ f1dd1b92-b841-414b-8cca-d3bcdda675dd
md"""
#### Get the content

- article's content
- code snipets
- web links
"""

# ╔═╡ 8fe89775-2853-49e4-885a-f3bdb1e792db
md_title = extract_content(
	rroot;
	selectors=[".pw-post-title"],
	verbose=false,
	only_tags=[:h1, :h2]
)  # Title

# ╔═╡ 72d4f892-2bd2-43af-b71e-5252a666ce0c
md = extract_content(
	rroot; 
	# selectors=[".hz.ia"],
	selectors=["p.pw-post-body-paragraph"],
	verbose=false,
	only_tags=[:div, :p, :span, :a]
)  # other metadata

# ╔═╡ ed56ba67-5e5a-43e9-9a5f-8e63597725f7
links = extract_links(
	rroot;
	selectors=["a"], 
	verbose=false, 
	restrict_to=["github", "LinkedIn", "huggingface", "arxiv", "medium", "edu", "llamaindex", "langchain", "wikipedia", "cohere"]
)

# ╔═╡ 0110956d-424d-4c7c-87ef-eda4a2cfc291
full_text = string(
	"- Title: ",  md_title, 
	"\n- Author and date: ", md, 
	"\n- Link: ", URL,
	"\nMain:\n", text, 
	"\n Links:\n", map(s -> string(" - ", s), links) |> links -> join(links, "\n")
)

# ╔═╡ b80c155d-5ec2-4b3e-ac8d-6ee5cb18376b
# println(full_text)

# ╔═╡ 0df8719c-a91d-4449-8dac-337a832eb065
save_text(TXT_FILEPATH, full_text)

# ╔═╡ 0883ae28-a94f-4bed-abce-39841605d29b
md"""
### Synthesis
"""

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
synthesis = make_timed_chat_request(
	 _SYS_PROMPT,
	 INSTRUCT_PROMPT,
	 full_text;
	 LLM_PARAMS...
)
## rather than default, which uses `SYS_PROMPT`
# synthesis = make_timed_chat_request(
# 	 INSTRUCT_PROMPT,
# 	 full_text;
# 	 LLM_PARAMS...
# )

# ╔═╡ 9b661918-23b6-46fb-9af1-53454d750d5f
synthesis_links = string(
	join(synthesis, "\n"),
	"\n#### Links:\n",
	join(
		map(tupl -> string("""  - [$(length(tupl[2]) > 0 ? tupl[2] : tag_link(tupl))]""", "($(tupl[1]))"), handle_duplicate_tag(links)),
		"\n"
	)
)

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
# ╠═27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
# ╠═68c8922f-0cb2-41d9-9efe-3ed7a00dd76f
# ╠═2e10b0e3-66ac-4507-ad7b-a19089b85308
# ╠═077c29e0-f912-44aa-ac3a-633b12318fb0
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
# ╟─0883ae28-a94f-4bed-abce-39841605d29b
# ╠═e2ffe835-65dc-4c85-aa9a-d98867da2ff5
# ╠═9b661918-23b6-46fb-9af1-53454d750d5f
# ╠═e4d711be-c885-404b-a51a-fda50c9d43c7
# ╟─cdb9c685-050a-430e-bde4-cd18c496f2a8
# ╟─be4996ad-0379-495b-bb00-2eb3c0847227
# ╠═c4f7a724-fe95-45cb-94af-656cc5fbebb5
# ╟─fe39ac9a-88fc-4b35-9e91-e4d93b2187b3
# ╟─322ecf98-5694-42a1-84f2-caf8a5fa58ad
