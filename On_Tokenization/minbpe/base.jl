#
# Contains the base Tokenizer type and a few common helper functions.
#
using Unicode
using Printf

"""
   Given a list of integers, return a dictionary of counts of consecutive pairs
   Example: [1, 2, 3, 1, 2] -> Dict{Tuple, Integer}((1, 2) => 2, (3, 1) => 1, (2, 3) => 1)
   Optionally allows to update an existing dictionary of counts
"""
function get_stats(ids::Vector{<: Integer})::Dict{Tuple, Integer}
  counts = Dict{Tuple, Integer}()
  for pair ∈ zip(ids, ids[2:end])
    counts[pair] = get(counts, pair, 0) + 1
  end
  counts
end

function get_stats!(counts::Union{Dict{Tuple, Integer}, Nothing}, ids::Vector{<: Integer})::Dict{Tuple, Integer}
  counts = (counts === nothing) ? Dict{Tuple, Integer}() : counts
  for pair ∈ zip(ids, ids[2:end])
    counts[pair] = get(counts, pair, 0) + 1
  end
  counts
end

"""
  In the list of integers (ids), replace all consecutive occurrences
  of pair with the new integer token idx
  Example: ids=[1, 2, 3, 1, 2], pair=(1, 2), idx=4 -> Integer[4, 3, 4]
"""
function merge(ids::Vector{<: Integer}, pair::Tuple{<: Integer, <: Integer}, idx::Integer)
  newids = Vector{Integer}()  # == Integer[]
  ix = 1
  while ix ≤ length(ids)
    if ix < length(ids) && ids[ix] == pair[1] && ids[ix + 1] == pair[2]
      push!(newids, idx)
      ix += 2
    else
      push!(newids, ids[ix])
      ix += 1
    end
  end
  newids
end

function replace_control_characters(s::String)::String
  chars = Char[]
  for ch ∈ s
    cat = Unicode.category_code(ch)
    if cat[1] == 'C'
      append!(
        chars,
        '\\', 'u',
        collect(string(Int(ch), base=16, pad=4))
      )
    else
      push!(chars, ch) # This character is ok
    end
  end
  String(chars)
end

function render_token(t::Vector{UInt8}) :: String
  # Decode bytes to string, replacing invalid sequences
  # In Julia, directly decoding bytes to string assumes UTF-8 and replaces invalid with \ufffd
  String(copy(t)) |>
    s -> replace_control_characters(s)
end

const TII = Tuple{Integer, Integer}
const INT = Integer

abstract type AbstractTokenizer end

mutable struct Tokenizer <: AbstractTokenizer
  merges::Dict{TII, INT}
  pattern::Union{String, Regex}
  special_tokens::Dict{String, INT}
  vocab::Dict{INT, Vector{UInt8}}

  function Tokenizer(merges = Dict{TII, INT}(), pattern = "", special_tokens = Dict{String, INT}())
    vocab = _build_vocab(merges, special_tokens)
    new(merges, pattern, special_tokens, vocab)
  end
end

merges(self::Tokenizer) = self.merges
pattern(self::Tokenizer) = self.pattern
special_tokens(self::Tokenizer) = self.special_tokens
vocab(self::Tokenizer) = self.vocab

function _build_vocab(merges::Dict{TII, INT}, special_tokens::Dict{String, INT})::Dict{INT, Vector{UInt8}}
  vocab = Dict{INT, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:255)

  # And now we extend the dictionary, but we need to do in order from 256..278
  for ((p₀, p₁), idx) ∈ sort(merges |> collect, by=p -> p[2], rev=false)
    vocab[idx] = vocab[p₀] + vocab[p₁]  # ≡ vcat(vocab[p₀], vocab[p₁])
  end

  # + Special tokens
  for (spec_tok, idx) ∈ sort(special_tokens |> collect, by=p -> p[2], rev=false)
    vocab[idx] = Vector{UInt8}(special)
  end

  vocab
end

"""
Tokenizer can train a vocabulary of size vocab_size from text
"""
train(::AbstractTokenizer, _text::String, _vocab_size::Int, _verbose=false) = throw(ArgumentError("Not implemented"))

"""
Tokenizer can encode a string into a list of integers
"""
encode(::AbstractTokenizer, _text::String)::Vector{<: Integer} = throw(ArgumentError("Not implemented"))

"""
Tokenizer can decode a list of integers into a string
"""
decode(::AbstractTokenizer, _ids::Vector{UInt8})::String = throw(ArgumentError("Not implemented"))

"""
  Saves two files: file_prefix.vocab and file_prefix.model
  This is inspired (but not equivalent to!) sentencepiece's model saving:
  - `model` file is the critical one, intended for load()
  - `vocab` file is just a pretty printed version for human inspection only
"""
function save(self::AbstractTokenizer, file_prefix::String)::Nothing
  model_file = string(file_prefix, ".model")
  open(model_file, "w") do f
    # write the version, pattern, and merges
    write(f, "minbpe v1\n")
    write(f, "$(pattern(self))\n")
    # write the special tokens, first the number of them, then each one
    @printf(f, "%d\n", special_tokens(self) |> length)
    for (special, idx) ∈ special_token(self)
      write(f, "$special $idx\n")
    end
    # the merges dict
    for (idx1, idx2) ∈ merges(self)
      write(f, "$idx1 $idx2\n")
    end
  end

  vocab_file = string(file_prefix, ".vocab")
  inverted_merges = Dict(idx => pair for (pair, idx) ∈ merges(self))
  open(vocab_file, "w") do f  # , enc="utf-8"
    for (idx, token) ∈ vocab(self)
      # Handle token rendering and error replacement
      s = render_token(token)
      # Find the children of this token, if any
      if haskey(inverted_merges, idx)
        # if this token has children, render it nicely as a merge
        (idx0, idx1) = inverted_merges[idx]
        s0 = render_token(vocab(self)[idx0])
        s1 = render_token(vocab(self)[idx1])
        write(f, "[$s0][$s1] -> [$s] $idx\n")
      else
        # otherwise this is a leaf token, just print it
        write(f, "[$s] $idx\n")
      end
    end
  end
end

"""
  Inverse of save() but only for the model file
"""
function load(self::AbstractTokenizer, model_file::String)::Nothing
  @assert endswith(model_file, ".model")
  _merges = Dict{TII, INT}()
  _special_tokens = Dict{String, INT}()
  idx = 256

  open(model_file, "r") do file
    # Read the version
    version = strip(readline(f))
    @assert version == "minbpe v1"
    # Read the pattern
    self.pattern = strip(readline(f))
    # Read the special tokens
    num_special = parse(Int, strip(readline(f)))
    for _  ∈ 1:num_special
      special_line = strip(readline(f))
      special, special_idx = split(special_line)
      _special_tokens[special] = parse(Int, special_idx)
    end
    # Read the merges
    while !eof(f)
      line = readline(f)
      # idx1_str, idx2_str = split(strip(line))
      # idx1, idx2 = parse(Int, idx1_str), parse(Int, idx2_str)
      idx1, idx2 = split(strip(line)) .|>
        vs -> parse.(Int, vs)
      _merges[(idx1, idx2)] = idx
      idx += 1
    end
  end
  self = Tokenizer(merges=_merges, pattern=pattern(self), special_tokens=_special_tokens)
end
