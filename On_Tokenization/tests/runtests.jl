using Test
using JSON

# Assume PythonCall, CondaPkg are installed
# also:
# julia> using CondaPkg
#
# julia> # press ] to enter the Pkg REPL
#
# pkg> conda add tiktoken
#
using PythonCall
const TIKTOKEN = pyimport("tiktoken")

include("../minbpe/gpt4.jl")
include("../minbpe/regex.jl")
include("../minbpe/basic.jl")

const SPECIALS_STRING = """
<|endoftext|>Hello world this is one document
<|endoftext|>And this is another document
<|endoftext|><|fim_prefix|>And this one has<|fim_suffix|> tokens.<|fim_middle|> FIM
<|endoftext|>Last document!!! 👋<|endofprompt|>
""" |> strip |> String

const SPECIAL_TOKENS = Dict{String, INT}(
    "<|endoftext|>" => 100257,
    "<|fim_prefix|>" => 100258,
    "<|fim_middle|>" => 100259,
    "<|fim_suffix|>" => 100260,
    "<|endofprompt|>" => 100276
)

const LLAMA_TEXT = """
<|endoftext|>The llama (/ˈlɑːmə/; Spanish pronunciation: [ˈʎama] or [ˈʝama]) (Lama glama) is a domesticated South American camelid, widely used as a meat and pack animal by Andean cultures since the pre-Columbian era.
Llamas are social animals and live with others as a herd. Their wool is soft and contains only a small amount of lanolin.[2] Llamas can learn simple tasks after a few repetitions. When using a pack, they can carry about 25 to 30% of their body weight for 8 to 13 km (5–8 miles).[3] The name llama (in the past also spelled "lama" or "glama") was adopted by European settlers from native Peruvians.[4]
The ancestors of llamas are thought to have originated from the Great Plains of North America about 40 million years ago, and subsequently migrated to South America about three million years ago during the Great American Interchange. By the end of the last ice age (10,000–12,000 years ago), camelids were extinct in North America.[3] As of 2007, there were over seven million llamas and alpacas in South America and over 158,000 llamas and 100,000 alpacas, descended from progenitors imported late in the 20th century, in the United States and Canada.[5]
<|fim_prefix|>In Aymara mythology, llamas are important beings. The Heavenly Llama is said to drink water from the ocean and urinates as it rains.[6] According to Aymara eschatology,<|fim_suffix|> where they come from at the end of time.[6]<|fim_middle|> llamas will return to the water springs and ponds<|endofprompt|>
""" |> strip |> String

const TEST_STRINGS = [
  "",                                    # empty string
  "?",                                   # single character
  "hello world!!!? (こにちは) lol123 😉", # fun small string
  "FILE:grigori_perelman.txt",           # FILE: is handled as a special string in unpack()
]

const TIKTOKEN_IDS = [
  # mappings from TEST_STRINGS
  Int[],
  Int[30],
  Int[15339, 1917, 12340, 30, 320, 22957, 20230, 86614, 8, 28509, 4513, 57037],
  "FILE:grigori_perelman-tokens.json",
]

function unpack(text::Union{String, Vector{Int}})
  if isa(text, String) && startswith(text, "FILE:")
    dirname_ = dirname(abspath(@__FILE__))
    _file = joinpath(dirname_, text[6:end])
    # assume .txt or .json!
    return endswith(_file, ".txt") ? read(_file, String) :
      endswith(_file, ".json") ? JSON.parsefile(_file) : throw(ArgumentError("fiel extension should be .txt or .json"))
  end
  text
end

@testset "encode/decode" begin
  texts = TEST_STRINGS .|> unpack

  for tokenizer ∈ [RegexTokenizer(), Tokenizer()]
    for text ∈ [texts...]   # make copy
      @test decode(tokenizer, encode(tokenizer, text)) ≡ text
    end
  end
end

@testset "test gpt4 tiktoken equality" begin
  texts = TEST_STRINGS .|> unpack
  tokens =  TIKTOKEN_IDS .|> unpack  # see next testset for using encode from python tiktoken

  tokenizer = GPT4Tokenizer()
  enc = BytePairEncoding.load_tiktoken("cl100k_base")

  for (text, tiktoken_ids) ∈ zip([texts...], tokens)
    gpt4_tokenizer_ids = encode(tokenizer, text)
    @test gpt4_tokenizer_ids == tiktoken_ids
  end
end

@testset "test_gpt4_tiktoken_equality_special_tokens" begin
  tokenizer = GPT4Tokenizer()
  py_enc = TIKTOKEN.get_encoding("cl100k_base")

  tiktoken_ids = py_enc.encode(SPECIALS_STRING, allowed_special="all") |>
    py_v -> pyconvert(Vector{Integer}, py_v)
  gpt4_tokenizer_ids = encode(tokenizer, SPECIALS_STRING, allowed_special="all")
  @test gpt4_tokenizer_ids == tiktoken_ids
end

#
# Quick unit test, following along the Wikipedia example:
# https://en.wikipedia.org/wiki/Byte_pair_encoding
#
# According to Wikipedia, running bpe on the input string:
# "aaabdaaabac"
#
# for 3 merges will result in string:
# "XdXac"
#
# where:
#   X=ZY
#   Y=ab
#   Z=aa
#
# Keep in mind that for us a=97, b=98, c=99, d=100 (ASCII values)
# so Z will be 256, Y will be 257, X will be 258.
#
# So we expect the output list of ids to be [258, 100, 258, 97, 99]
@testset "test_wikipedia_example" begin
  N = 256
  text = "aaabdaaabac"

  for tokenizer ∈ [Tokenizer(), RegexTokenizer()]
    train!(tokenizer, text, N + 3)
    ids = encode(tokenizer, text)

    @test ids .|> Int == [258, 100, 258, 97, 99]
    @test decode(tokenizer, encode(tokenizer, text)) ≡ text
  end
end

@testset "test_save_load" begin
  test_tokenizer_tmp = tempname()

  try
    # N = 256 - defined in `base.jl`
    # take a bit more complex piece of text and train the tokenizer, chosen at random
    text = LLAMA_TEXT

    # create a Tokenizer and do 64 merges
    tokenizer = RegexTokenizer()
    train!(tokenizer, text, N + 64)
    register_special_tokens!(tokenizer, SPECIAL_TOKENS)

    ids = encode(tokenizer, text; allowed_special="all")
    # println(" ==> ids: $(ids) | len ids: $(length(ids))")
    # println(" ==> merges: $(merges(tokenizer))")
    @test decode(tokenizer, ids) ≡ LLAMA_TEXT # text

    ## verify that save/load work as expected
    ## save the tokenizer (TODO use a proper temporary directory)
    save(tokenizer, test_tokenizer_tmp)

    ## re-load the tokenizer
    _tokenizer = RegexTokenizer()
    load!(_tokenizer, "$(test_tokenizer_tmp).model") # "test_tokenizer_tmp.model")

    # println("- tokenizer.merges (mem ): $(merges(tokenizer))")
    # println("- tokenizer.merges (load): $(merges(_tokenizer))")

    # println("- 1.1 tokenizer.pattern (mem ): $(pattern(tokenizer)) | $(typeof(pattern(tokenizer)))")
    # println("- 1.2 tokenizer.pattern (load): $(pattern(_tokenizer)) | $(typeof(pattern(tokenizer)))")

    # println("- 2.1 tokenizer.special_tokens (mem ): $(special_tokens(tokenizer))")
    # println("- 2.2 tokenizer.special_tokens (load): $(special_tokens(_tokenizer))")

    # println("- 3.1 tokenizer.vocab (mem ): $(vocab(tokenizer)) | len: $(length(vocab(tokenizer)))\n")
    # println("- 3.2 tokenizer.vocab (load): $(vocab(_tokenizer)) | len: $(length(vocab(_tokenizer)))\n")

    _ids =  encode(_tokenizer, text; allowed_special="all")
    # println(" ==> _ids: $(_ids) | len ids: $(length(_ids))")
    @test decode(_tokenizer, _ids) ≡ LLAMA_TEXT # text

    @test encode(_tokenizer, text; allowed_special="all") == _ids

  finally
    rm("$(test_tokenizer_tmp).model")
    rm("$(test_tokenizer_tmp).vocab")
  end
end
