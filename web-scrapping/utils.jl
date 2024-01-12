# focus on synthesis rather than summary

# include("../../../NLP_LLM/Summarize_Papers_with_GPT/support/api_module.jl")

const SYS_PROMPT = """You are a smart AI research assistant tasked with analyzing, summarizing, and synthesizing articles. You are thorough and deliberate in your approach before drafting your answers. You excel at organizing the provided articles into coherent sections, with introductions and conclusions that highlight the main ideas, reasoning, and contributions.

You proceed methodically, step by step, ensuring that the synthesis is accurately structured into coherent sections, capturing every fact, example, and subtlety. You always begin with a section detailing the article's title, publication date, author, and link (when such information is available). Moreover, you meticulously extract and render all pertinent external links and references (including but not limited to GitHub repositories) cited within the source article. In cases where the full details of these links or references are not available, you explicitly indicate their absence. Aim for a synthesis that is exhaustive, without overlooking any significant information.

Your style is highly formal, logical, and precise. You value consistency and completeness.

Your synthesis is formatted in markdown to maintain clear and organized presentation."""

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
