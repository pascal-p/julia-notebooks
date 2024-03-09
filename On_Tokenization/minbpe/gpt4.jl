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

function bpe(mergeable_ranks, token, max_rank)::Vector{Vector{UInt}}
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

  parts  # String.(parts)
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
    for ((p₀, p₁), ix) ∈ sort(merges(tokenizer) |> collect, by=pair -> pair[2], rev=false)
      _vocab[Int(ix)] = UInt[_vocab[p₀]..., _vocab[p₁]...]
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

merges(self::GPT4Tokenizer) = merges(self.tokenizer)
pattern(self::GPT4Tokenizer) = pattern(self.tokenizer)
special_tokens(self::GPT4Tokenizer) = special_tokens(self.tokenizer)
vocab(self::GPT4Tokenizer) = vocab(self.tokenizer)
byte_shuffle(self::GPT4Tokenizer) = self.byte_shuffle
inverse_byte_shuffle(self::GPT4Tokenizer) = self.inverse_byte_shuffle


function _encode_chunk(self::GPT4Tokenizer, text_bytes::Vector{UInt8})::Vector{<: Integer}
  permuted_bytes = [text_bytes[byte_shuffle(self)[b] + 1] for b ∈ text_bytes]
  _encode_chunk(self.tokenizer, permuted_bytes)
end

encode(self::GPT4Tokenizer, text::String; allowed_special="none_raise")::Vector{<: Integer} = encode(self.tokenizer, text; allowed_special)
# or = encode(self.tokenizer, text; allowed_special=allowed_special)

function decode(self::GPT4Tokenizer, ids::Vector{<: Integer})::String
  text_bytes = Vector{UInt8}()  # Array to hold byte arrays

  for idx ∈ ids
    append!(text_bytes, vocab(self)[idx])
  end

  # Adjust this if `inverse_byte_shuffle` expects 0-based indexing.
  shuffled_bytes = [text_bytes[inverse_byte_shuffle(self)[b] + 1] for b ∈ 1:length(text_bytes)]

  copy(shuffled_bytes) |> String # collect(shuffled_bytes) |> String
end

"""
  train() disabled
   this is a pretrained tokenizer, it is not intended to be trained
"""
train!(::RegexTokenizer, ::String, ::Int, verbose=false) = throw(ArgumentError("Not implemented because not a pretrained tokenizer"))

# save/load would require some thoughts (thus disabled ...)
#  - change save/load of base to add support for byte_shuffle...
#  - alternatively, we could move byte_shuffle to base type, but that would mean some uglyness
#    just to support the GPT-4 tokenizer and its weird historical quirks around byte_shuffle.
save(::GPT4Tokenizer, ::String) = throw(ArgumentError("Not implemented"))
load!(::GPT4Tokenizer, ::String) = throw(ArgumentError("Not implemented"))

function save_vocab(self::GPT4Tokenizer, vocab_file::String)
  _vocab = Dict{INT, Vector{UInt8}}()

  # Build vocab considering the byte shuffle
  for ix ∈ 0:255
    _vocab[ix + 1] = [inverse_byte_shuffle(self)[ix + 1]]
  end

  for ((p₀, p₁), ix) in self.merges
    _vocab[Int(ix)] = UInt8[_vocab[p₀]..., _vocab[p₁]...]
  end

  # Prepare the inverted merges for traceability
  inverted_merges = Dict(value => key for (key, value) ∈ merges(self))

  # Open the vocab file for writing (enc"UTF-8")
  open(vocab_file, "w") do f
    for (idx, token) ∈ sort(collect(vocab))  # Sort by index to maintain order
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
        write(f, "[$s₀][$s₁] -> [$s] $idx\n")  # @printf(f, "[%s][%s] -> [%s] %d\n", s0, s1, s, idx)
      else
        write(f, "[$s] $idx\n")  # @printf(f, "[%s] %d\n", s, idx)
      end
    end
  end
end


# Example:
# julia> tokenizer = GPT4Tokenizer()
# GPT4Tokenizer(RegexTokenizer(Tokenizer(Dict{Tuple{Integer, Integer}, Integer}((0x0000000000000158, 0x0000000000000116) => 4023, (0x00000000000065dd, 0x0000000000000251) => 79071, (0x000000000000026f, 0x0000000000001ace) => 45121, (0x000000000000012c, 0x00000000000004e2) => 5948, (0x0000000000000398, 0x00000000000001cc) => 3417, (0x000000000000029a, 0x0000000000000105) => 23258, (0x000000000000850f, 0x000000000000083e) => 72104, (0x000000000000406e, 0x00000000000098d7) => 92091, (0x0000000000000134, 0x000000000000015b) => 16387, (0x0000000000000056, 0x00000000000030bf) => 26372…), r"'(?i:[sdmt]|ll|ve|re)|[^\r\n\p{L}\p{N}]?+\p{L}+|\p{N}{1,3}| ?[^\s\p{L}\p{N}]++[\r\n]*|\s*[\r\n]|\s+(?!\S)|\s+", Dict{String, Integer}("<|fim_suffix|>" => 100260, "<|fim_prefix|>" => 100258, "<|endofprompt|>" => 100276, "<|endoftext|>" => 100257, "<|fim_middle|>" => 100259), Dict{Integer, Vector{UInt8}}(92533 => [0x8c, 0x7a, 0x8c, 0x76, 0x8d, 0xe1, 0x8c, 0x78, 0x8c, 0x71, 0x8c, 0x79, 0x8d, 0xe0], 76914 => [0xdc, 0x52, 0x48, 0x4d, 0x54, 0x52], 45120 => [0xdc, 0x24, 0x31, 0x20], 1703 => [0xdc, 0x19, 0x1c], 37100 => [0xdc, 0x51, 0x44, 0x42, 0x51, 0x44, 0x40, 0x53, 0x48, 0x4e, 0x4d, 0x40, 0x4b], 90240 => [0x3e, 0x34, 0x2d, 0x32, 0x34, 0x2f, 0x2f, 0x2e, 0x31, 0x33, 0x24, 0x23], 60540 => [0xc5, 0x44, 0x57, 0x4f, 0x4e, 0x51, 0x53], 91393 => [0x48, 0x52, 0x48, 0x45, 0x58], 59930 => [0x3e, 0x28, 0x2f, 0x35], 3406 => [0x07, 0x49]…)), Dict{Integer, String}(100258 => "<|fim_prefix|>", 100257 => "<|endoftext|>", 100276 => "<|endofprompt|>", 100259 => "<|fim_middle|>", 100260 => "<|fim_suffix|>")), Dict{UInt8, Int64}(0x38 => 23, 0x23 => 2, 0x6e => 77, 0x3c => 27, 0xdc => 152, 0x1e => 218, 0x06 => 194, 0x43 => 34, 0xea => 166, 0xd7 => 147…), Dict{Int64, UInt8}(56 => 0x59, 35 => 0x44, 110 => 0xb2, 60 => 0x5d, 220 => 0x20, 30 => 0x3f, 6 => 0x27, 67 => 0x64, 234 => 0x8c, 215 => 0x1b…))
