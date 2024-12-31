using Dates
using Printf

const PATH_ = "../../../NLP_LLM/Summarize_Papers_with_GPT/"

include("../$(PATH_)/support/api_module.jl")
include("../$(PATH_)/support/convert_md_to_pdf.jl")


const TEMPLATE = "$(PATH_)/support/md2pdf_alt.tpl"  # for podcast synthesis


# system prompt with a given TOC provided
const SYS_PROMPT_WITH_TOC_TMPL = """
You are a smart AI research assistant tasked with analyzing and synthesizing podcast transcripts... \
You are thorough and deliberate in your approach before drafting your answers. \
You excel at organizing the provided podcast transcript into a set of coherent sections, with introductions and conclusions that highlight all the ideas, reasoning, arguments and examples. \
You use the markdown format for your output.

Here is the raw transcript of a <<PODCAST_TITLE>>
<<PODCAST_CONTEXT>>

The provided transcript contains mistakes/misspelled words, onomatopoeia for sound/hesitation that should not be rendered in the resulting synthesis. \
This transcript is also structured into parts which you will need to follow precisely. You will proceed with the detailed synthesis, section by section - pausing between each section for feedback.
Some sections are short, some sections are longer - the synthesis should be short for the corrsponding section and longer for the longer section.
Precision, Accuracy, Fidelity and Faithfullness are paramount here.

Here is the Table of Content, for reference:
```
<<PODCAST_TOC>>
```

And now the transcript:
```
<<PODCAST_RAW_TRANSCRIPT>>
```
"""

# system prompt without a given TOC => need to generate one
const SYS_PROMPT_NO_TOC_TMPL = """
You are a smart AI research assistant tasked with analyzing and synthesizing podcast transcripts... \
You are thorough and deliberate in your approach before drafting your answers. \
You excel at organizing the provided podcast transcript into a set of coherent sections, with introductions and conclusions that highlight all the ideas, reasoning, arguments and examples. \

You use the markdown format for your output, section should start at level 3: '###'.
Make sure each section title is preceeded and followed by at least one empty line.

Here is the raw transcript of a <<PODCAST_TITLE>>
<<PODCAST_CONTEXT>>

The provided transcript contains mistakes/misspelled words, onomatopoeia for sound/hesitation that should not be rendered in the resulting synthesis. \
Before producing the synthesis and turning this first person transcript into a third person point of view, you need to \
identify first the main sections, then we will proceed with the synthesis, section by section - pausing between each section for feedback.
Precision, Accuracy, Fidelity and Faithfullness are paramount here.

And now the transcript:
```
<<PODCAST_RAW_TRANSCRIPT>>
```
"""

const SYS_PROMPT_4REFOR_TMPL = """
You are a smart AI research assistant tasked with analyzing and synthesizing podcast transcripts. You are thorough and deliberate in your approach before drafting your answers.

Your task here is given the transcript restitute it eliminating all mistakes/misspelled words, onomatopoeia for hesitation, clearly separating the intervention from the different speakers within the section boundaries.

You proceed one section at a time, allowing for revision and feedback. The final result of this re-transcriptin is to allow questions answering with the best possible version of the transcript.
You use the markdown format for your output.

Here is the Table of Content, for reference:
```
<<PODCAST_TOC>>
```

And now the transcript:
```
<<PODCAST_RAW_TRANSCRIPT>>
```
"""


struct Podcast
  title::String
  url::String
  context::String
  toc::Vector{String}
  raw_transcript::String

  function Podcast(title::String, url::String, context::String, toc::Vector{String}, raw_transcript::String)
    @assert length(title) > 0 "podcast title must be defined"
    @assert length(context) > 0 "podcast context must be defined"
    @assert length(raw_transcript) > 0 "podcast raw_transcript must be defined"

    new(title, url, context, toc, raw_transcript)
  end
end

has_toc(podcast::Podcast)::Bool = length(podcast.toc) > 0

function itemize_toc(vtoc::Vector{String})::String
  join(
    map(s -> length(strip(s))> 0 ? string(" - ", strip(s)) : "", vtoc),
    "\n"
  )
end

function resolve_sys_prompt(podcast::Podcast)::String
  sys_prompt_tmpl = has_toc(podcast) ? SYS_PROMPT_WITH_TOC_TMPL : SYS_PROMPT_NO_TOC_TMPL

  sys_prompt = replace(sys_prompt_tmpl, "<<PODCAST_TITLE>>" => podcast.title) |>
      sys_prompt -> replace(sys_prompt, "<<PODCAST_CONTEXT>>" => podcast.context) |>
      sys_prompt -> replace(sys_prompt, "<<PODCAST_RAW_TRANSCRIPT>>" => podcast.raw_transcript)

  has_toc(podcast) && (sys_prompt = replace(sys_prompt, "<<PODCAST_TOC>>" => itemize_toc(podcast.toc)))
  sys_prompt
end

"Assume TOC is gvien - at least for now."
function resolve_sys_prompt(podcast::Podcast, sys_prompt_tmpl::String)::String
  sys_prompt = replace(sys_prompt_tmpl, "<<PODCAST_TITLE>>" => podcast.title) |>
      sys_prompt -> replace(sys_prompt, "<<PODCAST_CONTEXT>>" => podcast.context) |>
      sys_prompt -> replace(sys_prompt, "<<PODCAST_RAW_TRANSCRIPT>>" => podcast.raw_transcript)

  has_toc(podcast) && (sys_prompt = replace(sys_prompt, "<<PODCAST_TOC>>" => itemize_toc(podcast.toc)))
  sys_prompt
end


function generate_toc(sys_prompt::String, podcast::Podcast, fh::IOStream; kwargs...)
  """
  make LLM call to get TOC,
  then update mardown synthesis file, update sys_prompt and podcast object
  """
  instruct_prompt = "Proceed with identifying and producing the main section of this podcast."
  toc = make_timed_chat_request(
    sys_prompt,
    instruct_prompt;
    kwargs...
  )

  save_toc(fh, string(toc))

  # modify podcast with toc
  upd_podcast = Podcast(
    podcast.title, podcast.url, podcast.context,
    map(x -> strip(x), split(toc, "\n")),
    podcast.raw_transcript
  )

  # use sys_prompt_with_toc
  upd_sys_prompt = resolve_sys_prompt(upd_podcast)

  [upd_sys_prompt, upd_podcast]
end


save_toc(fh::IOStream, content::String) = write(fh, string("## TOC\n", content, "\n"))  # MAY need to fix itemization...

function save_synthesis(fh::IOStream, content::String; with_flush=true)
  write(fh, content * "\n\n")
  with_flush && (flush(fh))
end

function convert_to_pdf(md_filepath::String, template::String = TEMPLATE)
  outpath = replace(md_filepath, r"\.md$" => ".pdf")
  @info @sprintf "source filepath %s => converted pdf file will be saved under %s" md_filepath outpath

  gen_pdf(md_filepath, outpath; template=template)

  @info @sprintf "source filepath %s converted to pdf" md_filepath
end

function make_timed_chat_request(sys_prompt::String, instruct_prompt::String; kwargs...)
  timeit(
    make_openai_request_chat,
    sys_prompt,
    instruct_prompt;  # aka user_prompt
    kwargs...
  )
end
