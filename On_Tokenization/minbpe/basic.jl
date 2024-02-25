# Minimal (byte-level) Byte Pair Encoding tokenizer.

# Algorithmically follows along the GPT tokenizer:
# https://github.com/openai/gpt-2/blob/master/src/encoder.py

# But:
# - Does not handle the regular expression splitting pattern.
# - Does not handle any special tokens.

include("base.jl")

const BasicTokenizer = Tokenizer
const N = 256

function train(self::BasicTokenizer, text::String, vocab_size::Int, verbose=false)::Nothing
  @assert vocab_size > N
  num_megres = vocab_size - N
  text_bytes = (collect ∘ codeunits)(text)
  ids = map(x -> Int(x), text_bytes) |> collect
  for ix ∈ 1:num_merges
    stats = get_stats(ids)
    pair = argmax(stats₁)  # new pair
    idx = N + ix - 1       # new token value
    global ids = merge(ids, pair, idx)  # perform merge by replacing co-occ with the new token value for pair
    merges[pair] = idx
    vocab[idx] = vocab[pair[1]] + vocab[pair[2]]
    verbose && println("merge $(ix)/$(num_merges): $(pair) -> $(idx) ($(vocab[idx])) had $(stats[pair]) occurrences")
  end
  self.merges = merges
  self.vocab = vocab
end

function decode(self::BasicTokenizer, ids::Vector{UInt8})::String
  collect(
    self.vocab[idx][1] for idx ∈ ids
  ) |> String
end

function encode(self::BasicTokenizer, text::String)::Vector{<: Integer}
  tokens = (collect ∘ codeunits)(text)
  while length(tokens) ≥ 2
    stats = get_stats(tokens)
    pair = argmin(stats)
    pair ∉ keys(self.merges) && break
    idx = self.merges[pair]
    tokens = merge(tokens, pair, idx)
  end
  tokens
end
