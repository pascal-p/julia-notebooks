#
# Minimal (byte-level) Byte Pair Encoding tokenizer.
# Algorithmically follows along the GPT tokenizer:
# https://github.com/openai/gpt-2/blob/master/src/encoder.py
#
# Unlike BasicTokenizer:
# - RegexTokenizer handles an optional regex splitting pattern.
# - RegexTokenizer handles optional special tokens.

# using Base.Iterators: partition
import Base.split

include("base.jl")

const GPT2_SPLIT_PATTERN = r"""'(?:[sdmt]|ll|ve|re)| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"""
const GPT4_SPLIT_PATTERN = r"""'(?i:[sdmt]|ll|ve|re)|[^\r\n\p{L}\p{N}]?+\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]++[\r\n]*|\s*[\r\n]|\s+(?!\S)|\s+"""

abstract type AbstractTokenizer <: AbstractBaseTokenizer end

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

set_merges!(self::RegexTokenizer, merges::Dict{TII, INT}) = self.tokenizer.merges = merges
set_special_tokens!(self::RegexTokenizer, special_tokens::Dict{String, INT}) = self.tokenizer.special_tokens = special_tokens
set_pattern!(self::RegexTokenizer, pattern::Regex) = self.tokenizer.pattern = pattern
set_vocab!(self::RegexTokenizer) = self.tokenizer.vocab = _build_vocab(self.tokenizer.merges, self.tokenizer.special_tokens)
set_vocab!(self::RegexTokenizer, _vocab::Dict{Integer, Vector{UInt}}) = self.tokenizer.vocab = _vocab

function train!(self::RegexTokenizer, text::String, vocab_size::Int, verbose=false)::Nothing
  @assert vocab_size > N
  num_merges = vocab_size - N

  # split the text up into text chunks
  text_chunks = [m.match for m ∈ eachmatch(pattern(self), text)]
  ids = [collect(codeunits(ch)) for ch ∈ text_chunks]

  _merges = Dict{TII, INT}()
  _vocab = Dict{Integer, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:N-1)

  for ix ∈ 1:num_merges
    stats = Dict{Tuple, Integer}()
    for chunk_ids ∈ ids
      get_stats!(stats, chunk_ids)
    end
    pair = argmax(stats)
    idx = N + ix - 1
    # replace all occurrences of pair in ids with idx
    ids = [merge(chunk_ids, pair, idx) for chunk_ids ∈ ids]
    # save the merge
    _merges[pair .|> Int] = Int(idx)
    _vocab[Int(idx)] = UInt8[_vocab[pair[1]]..., _vocab[pair[2]]...]
    verbose && println("merge $(ix)/$(num_merges): $(pair) -> $(idx) ($(_vocab[idx])) had $(stats[pair]) occurrences")
  end

  self.tokenizer.merges = _merges
  self.tokenizer.vocab = _vocab
  nothing  # to align with signature
end

"""
   special_tokens is a dictionary of str -> int
   example: {"<|endoftext|>" => 100257}
"""
function register_special_tokens!(self::AbstractTokenizer, special_tokens::Dict{String, INT})
  self.tokenizer.special_tokens = special_tokens
  self.inverse_special_tokens = Dict{INT, String}(v => k for (k, v) ∈ special_tokens)
end

function decode(self::AbstractTokenizer, ids::Vector{<: Integer})::String
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

function _encode_chunk(self::RegexTokenizer, text_bytes::Vector{UInt8})::Vector{<: Integer}
  ids = collect(text_bytes)

  while length(ids) ≥ 2
    stats = get_stats(ids)
    pair = findmin(
      Dict{TII, INT}(pair => get(merges(self), pair, INT_INF) for pair ∈ keys(stats))
    )[2]
    pair ∉ keys(merges(self)) && break
    idx = merges(self)[pair]
    ids = merge(ids, pair, idx) .|> Int
  end

  ids
end

"""
   Encoding that ignores any special tokens.
"""
function _encode(self::AbstractTokenizer, text::String)::Vector{<: Integer}
  text_chunks = [m.match for m ∈ eachmatch(pattern(self), text)]

  ids = Vector{Integer}()
  for chunk ∈ text_chunks
    chunk_bytes = Vector{UInt8}(chunk) # Raw bytes
    chunk_ids = _encode_chunk(self, chunk_bytes)
    append!(ids, chunk_ids .|> Int) # `append!` to extend array with elements of another collection ∼ Python's `extend` method for list
  end

  ids
end

"""
  Unlike previous `encode()`, this function handles special tokens.
  allowed_special: can be "all"|"none"|"none_raise" or a custom set of special tokens
    if none_raise, then an error is raised if any special token is encountered in text
    this is the default tiktoken behavior right now...
"""
function encode(self::AbstractTokenizer, text::String; allowed_special="none_raise")::Vector{<: Integer}
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
  special_chunks = split(text, special)

  # Now all the special tokens are separated from the rest of the text.
  # All chunks of text are encoded separately, then results are joined.
  ids = Vector{Integer}()
  for part ∈ special_chunks
    if haskey(special, part)
      push!(ids, special[part] .|> Int)  # special token => encode separately as a special case.
    else
      append!(ids, _encode(self, part |> String) .|> Int)  # ordinary sequence => encode normally.
    end
  end

  ids
end

function split(text::String, special::Dict{String, Integer})::Vector{String}
  special_pattern = "(" * join(map(re_escape, collect(keys(special))), "|") * ")"  # Concatenate the keys of `special` into a regex pattern
  regex = Regex(special_pattern)
  special_chunks = String[]
  last_end = 1

  for m ∈ eachmatch(regex, text)
    start_pos, end_pos = m.offset, m.offset + length(m.match) - 1

    # Append text preceding the current match
    if start_pos > last_end
      safe_start = prevind(text, start_pos) # instead start_pos - 1 => StringIndexError: invalid index`
      push!(special_chunks, text[last_end:safe_start])
    end

    # Append the match itself
    push!(special_chunks, m.match)
    last_end = end_pos + 1
  end

  # Append any remaining text after the last match
  last_end ≤ length(text) && (push!(special_chunks, text[last_end:end]))
  special_chunks
end

function re_escape(str::String)::String
  # Implement re.escape equivalent if necessary, for Julia 1.5 and later, this is typically not needed as Regex does it.
  escape_string(str, "\\.+*?()|[]{}^\$") # This line is a simplified placeholder.
end
