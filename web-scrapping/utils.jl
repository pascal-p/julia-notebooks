# focus on synthesis rather than summary

# include("../../../NLP_LLM/Summarize_Papers_with_GPT/support/api_module.jl")

const SYS_PROMPT = """```markdown
You are a smart AI research assistant tasked with analyzing, and synthesizing articles. You are thorough and deliberate in your approach before drafting your answers. You excel at organizing the provided articles into coherent sections, with introductions and conclusions that highlight the main ideas, reasoning, and contributions.

You proceed methodically, step by step, ensuring that the synthesis is accurately structured into coherent sections, capturing every fact, key point, acronym, example, and explanation. You always begin with a section detailing the article's title, publication date, author, and link (when such information is available). You preserve all the original sections from the article for high fidelity. Aim for a synthesis that is exhaustive, without overlooking any significant information.

Your style is highly formal, logical, and precise. You value consistency and completeness.

Always render all code snippets delimited by "```code" and "```" verbatim and in full, unless explicitly told otherwise. Most of the time, those snippets are in `python`, however, apply your reasoning and expertise to tag them with the appropriate programming language. When indenting Python code, please use an indent of 2 space characters.

Your synthesis is formatted in Markdown to maintain a clear and organized presentation."""

# GPT-4 is inconsistent with the links, (NOTE: those are almost always provided by the "web extractor", but for errors) but ofthen GPT-4 will state that numerous links are provided throughout the article without rendering them!
# Moreover, you meticulously extract and render all pertinent external links and references (including but not limited to GitHub repositories) cited within the source article.

function make_timed_chat_request(instruct_prompt::String, data::String; kwargs...)
  timeit(
    make_openai_request_chat,
    SYS_PROMPT,
    instruct_prompt,
    data;
    kwargs...
  )
end

function dft(v_elt::Vector{<: Any})::String
  """
  depth first traversal
  """
  vtext = String[]

  function _dft(v_elt::Vector{<: Any})
    for elt ∈ v_elt
      if hasproperty(elt, :children)
	_dft(elt.children)
      elseif hasproperty(elt, :text)
	push!(vtext, strip(elt.text))
      end
    end
    vtext
  end

  _dft(v_elt) |> v -> join(v, "\n")
end

function save_text(filepath::String, text::String)
  open(filepath, "w") do fh
    write(fh, text)
  end
end

function extract_links(root; selectors=["a"], verbose=true, restrict_to=["github", "LinkedIn"])::Vector{Tuple{String, String}}
  links = Tuple{String, String}[] # String[]
  sel_vec = vcat(
    (eachmatch(Selector(selector), rroot) for selector ∈ selectors)...
      )
  for element ∈ sel_vec
    if hasproperty(element, :attributes)
      if match(join(restrict_to, "|") |> p -> Regex(p, "i"), element.attributes["href"]) !== nothing
	# println("1. ", element, "\n")
	push!(
	  links,
	  (element.attributes["href"], dft(element.children))
	)
      end
    end
  end
  # remove if link contains "signin?" or "policy..."
  filter(
    tupl -> match(r"signin\?|policy\.medium\.com|followers\?|help\.medium|work\-at\-medium|com/about"i,
                  tupl[1]) === nothing,
    links
  )
end

function tag_link(tupl::Tuple{String, String})::String
  link, tag = tupl
  # @assert length(tag) == 0 "Expect the tag to be empty, when this function is called"

  chunks = split(link, "/")
  tag = length(tag) == 0 ? chunks[3] : tag
  (endswith(chunks[end], ".html") || endswith(chunks[end], ".pynb")) &&
    (tag = string(tag, " - ", replace(chunks[end], ".html" => "")))
  tag
end

function handle_duplicate_tag(links::Vector{Tuple{String, String}})::Vector{Tuple{String, String}}
  tags = Dict{String, Int}()
  nlinks = Vector{Tuple{String, String}}()
  for (link, tag) ∈ links
    if haskey(tags, tag)
      tags[tag] += 1
    else
      tags[tag] = 1
    end
  end
  for (link, tag) ∈ links
    tags[tag] > 1 && (tag = tag_link((link, tag)))
    push!(nlinks, (link, tag))
  end
  nlinks
end

# synthesis_links = string(
# 	join(synthesis, "\n"),
# 	"\n#### Links:\n",
# 	join(
# 		# map(tupl -> string("""  - [$(length(tupl[2]) > 0 ? tupl[2] : split(tupl[1], "/")[3])]""", "($(tupl[1]))"), links),
# 		map(tupl -> string("""  - [$(length(tupl[2]) > 0 ? tupl[2] : tag_link(tupl))]""", "($(tupl[1]))"), handle_duplicate_tag(links)),
# 		"\n"
# 	)
# )
