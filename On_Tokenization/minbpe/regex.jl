#
# Minimal (byte-level) Byte Pair Encoding tokenizer.
# Algorithmically follows along the GPT tokenizer:
# https://github.com/openai/gpt-2/blob/master/src/encoder.py
#
# Unlike BasicTokenizer:
# - RegexTokenizer handles an optional regex splitting pattern.
# - RegexTokenizer handles optional special tokens.

using Base.Iterators: partition
include("base.jl")

const N = 256
const GPT2_SPLIT_PATTERN = r"""'(?:[sdmt]|ll|ve|re)| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"""
const GPT4_SPLIT_PATTERN = r"""'(?i:[sdmt]|ll|ve|re)|[^\r\n\p{L}\p{N}]?+\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]++[\r\n]*|\s*[\r\n]|\s+(?!\S)|\s+"""

mutable struct RegexTokenizer <: AbstractTokenizer
  tokenizer::Tokenizer
  inverse_special_tokens::Dict{INT, String}

  function RegexTokenizer(pattern::Union{Nothing, Regex} = nothing)
    tokenizer = Tokenizer()
    tokenizer.pattern = pattern === nothing ? GPT4_SPLIT_PATTERN : pattern
    new(tokenizer, Dict{INT, String}())
  end
end

merges(self::RegexTokenizer) = self.tokenizer.merges
pattern(self::RegexTokenizer) = self.tokenizer.pattern
special_tokens(self::RegexTokenizer) = self.tokenizer.special_tokens
vocab(self::RegexTokenizer) = self.tokenizer.vocab
inverse_special_tokens(self::RegexTokenizer) = self.inverse_special_tokens

function train(self::RegexTokenizer, text::String, vocab_size::Int, verbose=false)::Nothing
  @assert vocab_size > N
  num_merges = vocab_size - N

  # split the text up into text chunks
  text_chunks = [m.match for m ∈ eachmatch(pattern(self), text)]
  ids = [collect(codeunits(ch)) for ch ∈ text_chunks]

  _merges = Dict{TII, INT}()
  _vocab = Dict{Integer, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:N-1)
  for ix ∈ 1:num_merge
    stats = Dict{Tuple, Integer}()
    for chunk_ids ∈ ids
      get_stats!(stats, chunk_ids)
    end
    pair = argmax(stats)
    idx = N + ix - 1
    # replace all occurrences of pair in ids with idx
    ids = [merge(chunk_ids, pair, idx) for chunk_ids ∈ ids]
    # save the merge
    _merges[pair] = idx
    _vocab[idx] = _vocab[pair[1]] + _vocab[pair[2]]
    verbose && println("merge $(ix)/$(num_merges): $(pair) -> $(idx) ($(vocab[idx])) had $(stats[pair]) occurrences")
  end

  self.tokenizer.merges = _merges
  self.tokenizer.vocab = _vocab
end

"""
   special_tokens is a dictionary of str -> int
   example: {"<|endoftext|>" => 100257}
"""
function register_special_tokens(self::RegexTokenizer, special_tokens::Dict{String, INT})
  self.tokenizer.special_tokens = special_tokens
  self.inverse_special_tokens = Dict{INT, String}(v => k for (k, v) ∈ special_tokens)
end

function decode(self::RegexTokenizer, ids::Vector{UInt8})::String
  part_bytes = Vector{UInt8}()  # Array to hold byte arrays
  for idx ∈ ids
    if haskey(vocab(self), idx)
      append!(part_bytes, vocab(self)[idx])

    elseif haskey(inverse_special_tokens(self), idx)
      token = inverse_special_tokens(self)[idx]
      append!(part_bytes, Vector{UInt8}(token)) # Convert string to bytes

    else
      throw(ArgumentError("invalid token id: $idx"))
    end
  end
  collect(part_bytes) |> String
end

function _encode_chunk(self::RegexTokenizer, text_bytes::Vector{UInt8})::Vector{UInt8}
  ids = collect(text_bytes)
  while length(ids) ≥ 2
    stats = get_stats(ids)
    pair = argmin(stats)
    pair ∉ keys(merges(self)) && break
    idx = merges(self)[pair]
    ids = merge_ids(ids, pair, idx)
  end
  ids
end

"""
   Encoding that ignores any special tokens.
"""
function _encode(self::RegexTokenizer, text::String)::Vector{<: Integer}
  text_chunks = [m.match for m ∈ eachmatch(pattern(self), text)]
  ids = Vector{UInt8}()  # Vector{Integer}()
  for chunk ∈ text_chunks
    chunk_bytes = Vector{UInt8}(chunk) # Raw bytes
    chunk_ids = _encode_chunk(self, chunk_bytes)
    append!(ids, chunk_ids) # `append!` to extend an array with elements of another collection ∼ Python's `extend` method for list
  end
  ids
end

"""
  Unlike previous `encode()`, this function handles special tokens.
  allowed_special: can be "all"|"none"|"none_raise" or a custom set of special tokens
    if none_raise, then an error is raised if any special token is encountered in text
    this is the default tiktoken behavior right now...
"""
function encode(self::RegexTokenizer, text::String; allowed_special="none_raise")::Vector{<: Integer}
  special = if allowed_special == "all"
    special_tokens(self)
  elseif allowed_special == "none"
    Dict{String, INT}()
  elseif allowed_special == "none_raise"
    @assert all(token -> token ∉ text, special_tokens(self))
    Dict{String, INT}()
  elseif allowed_special isa Set
    Dict{String, INT}(k => v for (k, v) ∈ special_tokens(self) if k ∈ allowed_special)
  else
    throw(ArgumentError("allowed_special=$(allowed_special) not understood"))
  end

  isempty(special) && (return _encode(self, text))  # fallback to "standard" encode

  special_pattern = "(" * join(map(re_escape, keys(special)), "|") * ")"  # Concatenate the keys of `special` into a regex pattern
  special_chunks = split(
    text,
    Regex(special_pattern),
    keep=true
  )  # Split `text` based on the occurrence of any exact match with any of the special tokens

  # Now all the special tokens are separated from the rest of the text.
  # All chunks of text are encoded separately, then results are joined.
  ids = Vector{UInt8}()  # Vector{Integer}()  # Int[]
  for part ∈ special_chunks
    if haskey(special, part)
      push!(ids, special[part])  # special token => encode separately as a special case.
    else
      append!(ids, encode(self, part))  # ordinary sequence => encode normally.
    end
  end
  ids
end
