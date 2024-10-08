using Dates
# using OpenAI  # called in pluto

# include("../../../../NLP_LLM/Summarize_Papers_with_GPT/support/llm_models.jl")

# include("../../Summarize_Papers_with_GPT/support/api_module.jl") # Mac OS
include("../../../../NLP_LLM/Summarize_Papers_with_GPT/support/api_module.jl")


# focus on synthesis rather than summary
const SYS_PROMPT = """
You are a smart AI research assistant tasked with analyzing and synthesizing articles. You are thorough and deliberate in your approach before drafting your answers. You excel at organizing the provided article into coherent sections, with introduction and conclusion that highlight the main ideas, reasoning, and contributions.

Proceed methodically, step by step, ensuring that the synthesis is accurately structured into coherent sections, capturing every fact, key point, acronym or abbreviation, example, and explanation. Always begin with a section detailing the article's title, publication date, author, and web link (when such information is available). Preserve all the original sections from the article for high fidelity. Aim for a synthesis that is exhaustive, without overlooking any significant information.

Render all code blocks, as delimited by "```code" and "```", verbatim, in full, and exactly once, including the code explanation from the original article unless explicitly instructed otherwise. Although most of these snippets are in Python, use your reasoning and expertise in coding to correctly identify and tag them with the appropriate programming language. If no programming language can be inferred, treat those code blocks as programming output and render them verbatim as text. When dealing with Python or Julia code blocks, apply proper formatting by using an indent of two space characters and vertical spacing between logical units such as loops, functions, methods and classes...

Your style is formal, logical, and precise. Refrain from making comments about your synthesis. You value consistency and completeness. You format the synthesis with Markdown, clearly separating sections, subsections, lists etc...
"""

# GPT-4 is inconsistent with the links, (NOTE: those are almost always provided by the "web extractor", but for errors) but ofthen GPT-4 will state that numerous links are provided throughout the article without rendering them!
# Moreover, you meticulously extract and render all pertinent external links and references (including but not limited to GitHub repositories) cited within the source article.
# Your synthesis is formatted in Markdown to maintain a clear and organized presentation.

function make_timed_chat_request(sys_prompt::String, instruct_prompt::String, data::String; kwargs...)
  timeit(
    make_openai_request_chat,
    sys_prompt,
    instruct_prompt,  # aka user_prompt
    data;
    kwargs...
  )
end

function make_timed_chat_request(instruct_prompt::String, data::String; kwargs...)
  timeit(
    make_openai_request_chat,
    SYS_PROMPT,
    instruct_prompt,  # aka user_prompt
    data;
    kwargs...
  )
end

function save_text(filepath::String, text::String)
  open(filepath, "w") do fh
    write(fh, text)
  end
end

function tag_link(tupl::Tuple{String, String})::String
  link, tag = tupl
  # @assert length(tag) == 0 "Expect the tag to be empty, when this function is called"
  chunks = split(link, "/")

  tag = if length(tag) == 0
    chunks[3]

  elseif lowercase(tag) == "here"
    join(chunks[2:end], " ")

  elseif length(split(tag, r"\s+")) == 1
    # one word => extend
    string(tag, "+", join(chunks[2:end], " ") |> strip)

  elseif chunks[3] ∈ split(tag, r"\s+")
    # chunks[3] already present in tag - no need to extend
    tag
  else
    string(tag, " - ", chunks[3])
  end

  (endswith(chunks[end], ".html") || endswith(chunks[end], ".ipynb")) &&
    (tag = string(tag, " - ", replace(chunks[end], ".html" => "")))

  tag |> strip
end

# [
#   ("https://python.langchain.com/docs/expression_language/how_to/routing?ref=blog.langchain.dev", "here"),
#   ("https://github.com/langchain-ai/langchain/blob/master/cookbook/multi_modal_RAG_chroma.ipynb?ref=blog.langchain.dev", "cookbook"),
#   ("https://github.com/langchain-ai/langchain/tree/master/templates/sql-pgvector?ref=blog.langchain.dev", "template"),
#   ("https://github.com/langchain-ai/langchain/tree/master/templates/neo4j-advanced-rag?ref=blog.langchain.dev", "here")
# ]

function handle_duplicate_tag(links::Vector{Tuple{String, String}}; tag_lim=50)::Vector{Tuple{String, String}}
  """
  add tag to a link, and normalize tag
  """
  tags = Dict{String, Int}()
  nlinks = Vector{Tuple{String, String}}()
  processed_links = Set{String}()

  for (link, tag) ∈ links
    if haskey(tags, tag)
      tags[tag] += 1
    else
      tags[tag] = 1
    end
  end

  for (link, tag) ∈ links
    (link ∈ processed_links) && continue
    push!(processed_links, link)

    tags[tag] ≥ 1 && (tag = tag_link((link, tag)))

    # limit length of tag (avoid kilometric! tag)
    tag = join(split(tag, "\n"), " ") # some tag contains "\n"
    n_tag = length(tag)
    tag = tag[1:min(tag_lim, n_tag)]

    push!(nlinks, (link, tag))
  end

  nlinks
end

# synthesis_links = string(
#       join(synthesis, "\n"),
#       "\n#### Links:\n",
#       join(
#               # map(tupl -> string("""  - [$(length(tupl[2]) > 0 ? tupl[2] : split(tupl[1], "/")[3])]""", "($(tupl[1]))"), links),
#               map(tupl -> string("""  - [$(length(tupl[2]) > 0 ? tupl[2] : tag_link(tupl))]""", "($(tupl[1]))"), handle_duplicate_tag(links)),
#               "\n"
#       )
# )
