#
# Contains the base Tokenizer type and a few common helper functions.
#
using Unicode
using Printf

const INT = Integer
TII = Tuple{<: Integer, <: Integer}      # ERROR: LoadError: invalid redefinition of constant Main.TII
const INT_INF = Base.typemax(Int64)      # ∞ for Integer
const INT_NEG_INF = Base.typemax(Int64)  # -∞ for Integer
const N = 256

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
function merge(ids::Vector{<: Integer}, pair::TII, idx::Integer)
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

"""
Note: many tokens may be partial utf-8 sequences and cannot be decoded into valid strings.
=> replace them with the replacement char �.
This also means that we couldn't possibly use .vocab in load() because decoding in this way
is a lossy operation!
"""
function replace_control_characters(text::String)::String
  chars = Char[]

  for ch ∈ text
    # Check if the character is a control character
    if iscntrl(ch) # This is more accurate for checking control characters
      hexcode = lpad(string(UInt32(ch), base=16), 4, '0')  # Convert character code to hexadecimal
      append!(chars, collect("\\u$hexcode")...)  # Escape the control character
    else
      push!(chars, ch)  # This character is okay
    end
  end

  # or:
  # for ch ∈ text
  #   # Check if the character is a control character
  #   if iscntrl(ch)
  #     codepoint = Int(ch)  # Get the Unicode code point of the character
  #     hexcode = lpad(string(codepoint, base=16), 4, '0')  # Convert to hexadecimal with padding
  #     append!(chars, collect("\\u$hexcode")...)  # Escape the control character
  #   else
  #     push!(chars, ch)  # This character is okay
  #   end
  # end

  # or:
  # for ch ∈ text
  #   if iscntrl(ch)
  #     # Safely convert character to its code point integer representation
  #     codepoint = UInt32(ch)
  #     # Convert the code point to hexadecimal and ensure proper padding
  #     hexcode = lpad(string(codepoint, base = 16), 4, '0')
  #     # Append the escape sequence to the chars array
  #     for escape_char in collect("\\u$hexcode")
  #       push!(chars, escape_char)
  #     end
  #   else
  #     push!(chars, ch) # This character is okay
  #   end
  # end

  # or:
  # chars = String[]
  # for ch ∈ text
  #   # println("-- Processing ch: <$(ch)> | iscntrl(ch): $(iscntrl(ch))")
  #   if iscntrl(ch) && ch != '\xb9'
  #     # ch = '\xb9'
  #     # '\xb9': Malformed UTF-8 (category Ma: Malformed, bad data)
  #
  #     # Collect each byte of the character.
  #     # Then each byte is converted to its hexadecimal representation.
  #     hexcode = join(["\\u", lpad(string(UInt32(ch), base = 16), 4, "0")], "")
  #     push!(chars, hexcode)
  #   else
  #     push!(chars, string(ch))  # This character is okay
  #   end
  # end
  # join(chars)

  String(chars)
end

function render_token(t::Vector{UInt8})::String
  # Decode bytes to string, replacing invalid sequences
  # In Julia, directly decoding bytes to string assumes UTF-8 and replaces invalid with \ufffd
  String(copy(t)) |>
    s_ -> replace_control_characters(s_)
end

abstract type AbstractBaseTokenizer end

mutable struct Tokenizer <: AbstractBaseTokenizer
  merges::Dict{TII, INT}
  pattern::Regex
  special_tokens::Dict{String, INT}
  vocab::Dict{INT, Vector{UInt8}}

  function Tokenizer(; merges = Dict{TII, INT}(), pattern = r"", special_tokens = Dict{String, INT}())
    vocab = _build_vocab(merges, special_tokens)
    new(merges, pattern, special_tokens, vocab)
  end
end

merges(self::Tokenizer) = self.merges
pattern(self::Tokenizer) = self.pattern
special_tokens(self::Tokenizer) = self.special_tokens
vocab(self::Tokenizer) = self.vocab

set_merges!(self::Tokenizer, merges::Dict{TII, INT}) = self.merges = merges
set_special_tokens!(self::Tokenizer, special_tokens::Dict{String, INT}) = self.special_tokens = special_tokens
set_pattern!(self::Tokenizer, pattern::Regex) = self.pattern = ppatern
set_vocab!(self::Tokenizer) = self.vocab = _build_vocab(self.merges, self.special_tokens)

function _build_vocab(merges::Dict{TII, INT}, special_tokens::Dict{String, INT})::Dict{INT, Vector{UInt8}}
  vocab = Dict{INT, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:255)

  # And now we extend the dictionary, but we need to do in order from 256..278
  for ((p₀, p₁), idx) ∈ sort(merges |> collect, by=pair -> pair[2], rev=false)
    vocab[Int(idx)] = UInt8[vocab[p₀]..., vocab[p₁]...]  # vocab[UInt8(idx)] = UInt8[vocab[p₀]..., vocab[p₁]...]
  end

  # + Special tokens
  for (spec_tok, idx) ∈ sort(special_tokens |> collect, by=p -> p[2], rev=false)
    vocab[idx] = Vector{UInt8}(spec_tok)
  end

  vocab
end

"""
Tokenizer can train a vocabulary of size vocab_size from text
"""
train!(::AbstractBaseTokenizer, _text::String, _vocab_size::Int, _verbose=false) = throw(ArgumentError("Not implemented"))

"""
Tokenizer can encode a string into a list of integers
"""
encode(::AbstractBaseTokenizer, _text::String)::Vector{<: Integer} = throw(ArgumentError("Not implemented"))

"""
Tokenizer can decode a list of integers into a string
"""
decode(::AbstractBaseTokenizer, _ids::Vector{UInt8})::String = throw(ArgumentError("Not implemented"))

"""
  Saves two files: file_prefix.vocab and file_prefix.model
  This is inspired (but not equivalent to!) sentencepiece's model saving:
  - `model` file is the critical one, intended for load()
  - `vocab` file is just a pretty printed version for human inspection only
"""
function save(self::AbstractBaseTokenizer, file_prefix::String)
  model_file = file_prefix * ".model"
  open(model_file, "w") do f
    write(f, "minbpe v1\n")
    write(f, "$(pattern(self).pattern)\n")  # export the Regex as a String
    write(f, string(length(special_tokens(self))) * "\n")
    for (special, idx) ∈ special_tokens(self)
      write(f, "$special $idx\n")
    end

    # careful here, we need to save the keys in order! (by values)
    # ex. Dict{Tuple{Integer, Integer}, Integer}((271, 109) => 256, (105, 294) => 257, (309, 114) => 258, ...)
    for ((idx₀, idx₁), _) ∈ sort(collect(merges(self)), by = x -> x[2])
      write(f, "$idx₀ $idx₁\n")
    end
  end

  vocab_file = file_prefix * ".vocab"
  inverted_merges = Dict(value => key for (key, value) ∈ merges(self))
  open(vocab_file, "w") do f
    for (idx, token) ∈ vocab(self)
      # Handle UTF-8 safely
      s = ""
      try
        s = render_token(token)

      catch ex
        if isa(ex, Base.InvalidCharError)
          # Replace invalid UTF-8 character representations if needed.
          s = "�"
        else
          rethrow(ex)
        end
      end

      if haskey(inverted_merges, idx)
        idx₀, idx₁ = inverted_merges[idx]
        s₀ = render_token(vocab(self)[idx₀])
        s₁ = render_token(vocab(self)[idx₁])
        write(f, "[$s₀][$s₁] -> [$s] $idx\n")
      else
        write(f, "[$s] $idx\n")
      end

    end
  end
end

"""
  Inverse of save() but only for the model file
"""
function load!(self::AbstractBaseTokenizer, model_file::String)::Nothing
  @assert endswith(model_file, ".model")
  _merges = Dict{TII, INT}()
  _special_tokens = Dict{String, INT}()
  idx = N

  open(model_file, "r") do file
    # Read the version
    version = strip(readline(file))
    @assert version == "minbpe v1"

    # Read the pattern and turn it into a Regex
    set_pattern!(self, strip(readline(file)) |> Regex)

    # Read the special tokens
    num_special = parse(Int, strip(readline(file)))

    for _ ∈ 1:num_special
      special_line = strip(readline(file))
      special, special_idx = Base.split(special_line)
      _special_tokens[special] = parse(Int, special_idx)
    end

    # Read the merges
    while !eof(file)
      line = readline(file)
      idx₁, idx₂ = Base.split(strip(line)) .|>
        vs -> parse.(Int, vs)
      _merges[(idx₁, idx₂)] = idx
      idx += 1
    end
  end

  # NO: self = Tokenizer(;merges=_merges, pattern=pattern(self), special_tokens=_special_tokens)
  set_merges!(self, _merges)
  set_special_tokens!(self, _special_tokens)
  set_vocab!(self)

  nothing  # to align with signature
end
