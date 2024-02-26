#
# Minimal (byte-level) Byte Pair Encoding tokenizer.
# Algorithmically follows along the GPT tokenizer:
# https://github.com/openai/gpt-2/blob/master/src/encoder.py
#
# Unlike BasicTokenizer:
# - RegexTokenizer handles an optional regex splitting pattern.
# - RegexTokenizer handles optional special tokens.

include("base.jl")

const N = 256
const GPT2_SPLIT_PATTERN = r"""'(?:[sdmt]|ll|ve|re)| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"""
const GPT4_SPLIT_PATTERN = r"""'(?i:[sdmt]|ll|ve|re)|[^\r\n\p{L}\p{N}]?+\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]++[\r\n]*|\s*[\r\n]|\s+(?!\S)|\s+"""

mutable struct RegexTokenizer <: AbstractTokenizer
  tokenizer::Tokenizer
  inverse_special_tokens::Dict{INT, String}

  function RegexTokenizer(pattern::Union{Nothing, String} = nothing)
    tokenizer = Tokenizer()
    tokenizer.pattern = pattern === nothing ? GPT4_SPLIT_PATTERN : pattern
    new(tokenizer, Dict{INT, String}())
  end
end

function train(self::RegexTokenizer, text::String, vocab_size::Int, verbose=false)::Nothing
  @assert vocab_size > N
  num_merges = vocab_size - N

  # split the text up into text chunks
  text_chunks = [m.match for m ∈ eachmatch(pattern(self), text)]
  ids = [collect(codeunits(ch)) for ch ∈ text_chunks]

  _merges = Dict{TII, INT}()
  _vocab = Dict{Integer, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:N-1)
  for ix ∈ 1:num_merge
    # ...
  end
  self.merges = _merges
  self.vocab = _vocab 
end
