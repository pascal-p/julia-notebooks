# Minimal (byte-level) Byte Pair Encoding tokenizer.

# Algorithmically follows along the GPT tokenizer:
# https://github.com/openai/gpt-2/blob/master/src/encoder.py

# But:
# - Does not handle the regular expression splitting pattern.
# - Does not handle any special tokens.

include("base.jl")

const BasicTokenizer = Tokenizer
const N = 256

function train!(self::BasicTokenizer, text::String, vocab_size::Int, verbose=false)::Nothing
  @assert vocab_size > N
  num_merges = vocab_size - N

  text_bytes = (collect ∘ codeunits)(text)
  ids = map(x -> Int(x), text_bytes) |> collect
  _merges = Dict{TII, INT}()
  _vocab = Dict{Integer, Vector{UInt8}}(idx => UInt8[idx] for idx ∈ 0:N-1)

  for ix ∈ 1:num_merges
    stats = get_stats(ids)
    pair = argmax(stats)        # new pair
    idx = N + ix - 1            # new token value
    ids = merge(ids, pair, idx) # perform merge by replacing co-occ with the new token value for pair

    _merges[pair] = idx
    _vocab[idx] = UInt8[_vocab[pair[1]]..., _vocab[pair[2]]...]
    verbose && println("merge $(ix)/$(num_merges): pair: $(pair) -> idx: $(idx) (vocab: $(_vocab[idx])) had stats: $(stats[pair]) occurrences")
  end

  self.merges = _merges   # used in encode()
  self.vocab = _vocab     # used in decode()
  nothing                 # to align with signature
end

function decode(self::BasicTokenizer, ids::Vector{<: Integer})::String
  v = UInt8[]
  for idx ∈ ids
    append!(v, vocab(self)[idx])
  end
  v |> String
end

function encode(self::BasicTokenizer, text::String)::Vector{<: Integer}
  ids = (collect ∘ codeunits)(text) .|> Int
  while length(ids) ≥ 2
    stats = get_stats(ids)
    # from the candidate pairs in `stats` get the minimal pait in term of value in merges(self)
    pair = findmin(
      Dict{TII, INT}(pair => get(merges(self), pair, INT_INF) for pair ∈ keys(stats))
    )[2]
    pair ∉ keys(merges(self)) && break

    idx = self.merges[pair]  # merges(self)[pair]
    ids = merge(ids, pair, idx)
  end
  ids
end
