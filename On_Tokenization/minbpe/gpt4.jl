#
# Implements the GPT-4 Tokenizer as a light wrapper around the RegexTokenizer.
# Note that this is a pretrained tokenizer. By default and inside init(), it
# loads the pretrained tokenizer from the `cl100k_base` tokenizer of tiktoken
#

using BytePairEncoding

include("regex.jl")

# julia> enc = BytePairEncoding.load_tiktoken("cl100k_base")
#   Downloaded artifact: cl100k_base
# BPETokenizer(MatchTokenization(BPETokenization(Cl100kBaseTokenization, bpe = TikTokenBPE(100256 merges)), 5 patterns))

# julia> propertynames(enc)
# (:tokenization,)

# julia> enc.tokenization
# MatchTokenization(BPETokenization(Cl100kBaseTokenization, bpe = TikTokenBPE(100256 merges)), 5 patterns)

# julia>

# julia> enc.tokenization |> propertynames
# (:base, :patterns)

# julia> enc.tokenization.base
# BPETokenization(Cl100kBaseTokenization, bpe = TikTokenBPE(100256 merges))

# julia> enc.tokenization.base |> propertynames
# (:base, :bpe)

# julia> enc.tokenization.base.bpe
# TikTokenBPE(100256 merges)

# julia> enc.tokenization.base.bpe |> propertynames
# (:encoder,)

# julia> enc.tokenization.base.bpe
# TikTokenBPE(100256 merges)

# julia> enc.tokenization.base.bpe.encoder
# Dict{Vector{UInt8}, Int64} with 100256 entries:
#   [0x20, 0x65, 0x61, 0x72, 0x6e, 0x69, 0x6e, 0x67, 0x73]                               => 24608
#   [0x64, 0x69, 0x6d, 0x73]                                                             => 55590
#   [0x20, 0x43, 0x61, 0x73, 0x63]                                                       => 96106
#   [0x20, 0x70, 0x72, 0x6f, 0x76, 0x69, 0x64]                                           => 2104
#   [0x20, 0x6e, 0xc3, 0xa5]                                                             => 43235
#   [0x20, 0x73, 0x70, 0x69, 0x6b, 0x65, 0x64]                                           => 93342
#   [0x20, 0x46, 0x6c, 0x6f, 0x72]                                                       => 8956

#   [0x28, 0x73, 0x74, 0x75, 0x64, 0x65, 0x6e, 0x74]                                     => 40104
#   ⋮                                                                                     => ⋮

function bpe(mergeable_ranks, token, max_rank)  # ::Tuple
  parts = [UInt[b] for b in token] # Convert token into an array of UInt
  while true
    min_idx, min_rank = nothing, nothing

    for ix ∈ 1:length(parts) - 1
      pair = vcat(parts[ix], parts[ix + 1])  # Concatenate two adjacent bytes
      rank = get(mergeable_ranks, pair, nothing)

      if rank !== nothing && (min_rank === nothing || rank < min_rank)
        min_idx = ix
        min_rank = rank
      end
    end

    (min_rank === nothing || (max_rank !== nothing && min_rank ≥ max_rank)) && break

    @assert min_idx !== nothing
    parts =  vcat(parts[1:min_idx-1], [vcat(parts[min_idx], parts[min_idx + 1])], parts[min_idx+2:end])
  end

  # Convert parts back to strings if necessary, then wrap into a Tuple
  parts  # String.(parts) # |> Tuple
end

function recover_merges(mergeable_ranks::Dict{Vector{UInt8}, Int})::Dict{Tuple{<: Integer, <: Integer}, Integer}
  # the `merges` are already the byte sequences in their merged state.
  # so we have to recover the original pairings. We can do this by doing
  # a small BPE training run on all the tokens, in their order.
  # also see https://github.com/openai/tiktoken/issues/60
  # also see https://github.com/karpathy/minbpe/issues/11#issuecomment-1950805306
  merges = Dict{Tuple{<: Integer, <: Integer}, Int}()  # merges = Dict{Vector{UInt}, Int}()

  # Need top sort mergeable_ranks
  for (token, rank) ∈ sort(collect(mergeable_ranks), by = x -> x[2])
    length(token) == 1 && continue
    pair = bpe(mergeable_ranks, token, rank)
    @assert length(pair) == 2

    # recover the integer ranks of the pair
    ix₀ = UInt(mergeable_ranks[pair[1]])
    ix₁ = UInt(mergeable_ranks[pair[2]])
    merges[tuple(ix₀, ix₁)] = rank
  end

  merges
end

# get it from `minbpe/regex.jl`
# const GPT4_SPLIT_PATTERN = r"""'(?i:[sdmt]|ll|ve|re)|[^\r\n\p{L}\p{N}]?+\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]++[\r\n]*|\s*[\r\n]|\s+(?!\S)|\s+"""

const GPT4_SPECIAL_TOKENS = Dict{String, Integer}(
  "<|endoftext|>" => 100257,
  "<|fim_prefix|>" => 100258,
  "<|fim_middle|>" => 100259,
  "<|fim_suffix|>" => 100260,
  "<|endofprompt|>" => 100276
)

mutable struct GPT4Tokenizer <: AbstractTokenizer
  tokenizer::RegexTokenizer
  byte_shuffle
  inverse_byte_shuffle

  function GPT4Tokenizer(pattern::Union{Nothing, Regex} = GPT4_SPLIT_PATTERN)
    tokenizer = RegexTokenizer(pattern)
    enc = BytePairEncoding.load_tiktoken("cl100k_base")
    mergeable_ranks = enc.tokenization.base.bpe.encoder
    _merges = recover_merges(mergeable_ranks)  # the merges are those of gpt4, but we have to recover them
    set_merges!(tokenizer, _merges)
    _vocab = Dict{Integer, Vector{UInt}}(idx => UInt[idx] for idx ∈ 0:N-1)
    for ((p₀, p₁), idx) ∈ sort(merges(tokenizer) |> collect, by=pair -> pair[2], rev=false)
      _vocab[Int(idx)] = UInt[_vocab[p₀]..., _vocab[p₁]...]
    end
    set_vocab!(tokenizer, _vocab)

    # now here is another tricky part.
    # for some reason, the tokens corresponding to individual bytes
    # are permuted in a different order. This is completely non-sensical
    # and probably historical, but therefore we have to deal with it here.
    # println("==> keys(mergeable_ranks): $(keys(mergeable_ranks))[1:5]")
    byte_shuffle = Dict{UInt8, Int}(UInt8(ix) => mergeable_ranks[UInt8[ix]] for ix ∈ 0:N-1)
    inverse_byte_shuffle = Dict{Int, UInt8}(v => k for (k, v) ∈ byte_shuffle)
    register_special_tokens!(tokenizer, GPT4_SPECIAL_TOKENS)

    new(tokenizer, byte_shuffle, inverse_byte_shuffle)
  end
end
