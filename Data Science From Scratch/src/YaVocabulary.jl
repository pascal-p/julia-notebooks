module YaVocabulary

import Base: size, length

export Vocabulary, get_id, get_word, size, length, one_hot_encode,
  add!, save_vocab, load_vocab


include("./tensor_dt.jl")
using ..TensorDT: Tensor

const JSON_DATA_DIR = "./vocab_data"
const D_SI = Dict{String, Integer}
const D_IS = Dict{Integer, String}
const S_N = Union{String, Nothing}
const I_N = Union{Integer, Nothing}
const T_N = Union{Tensor, Nothing}


struct Vocabulary
  word2ix::D_SI
  ix2word::D_IS

  Vocabulary() = new(D_SI(), D_IS())

  Vocabulary(w2ix::D_SI, ix2w::D_IS) = new(w2ix, ix2w)

  function Vocabulary(words::Vector{String})
    @assert length(words) > 0
    new(_add(words)...)
  end
end

##
## Public API
##

function get_id(self::Vocabulary, w::String)::I_N
  !haskey(self.word2ix, w) && (return nothing)
  self.word2ix[w]
end

function get_word(self::Vocabulary, ix::Integer)::S_N
  !(1 ≤ ix ≤ length(self.word2ix)) && (return nothing)
  self.ix2word[ix]
end

size(self::Vocabulary) = length(self.word2ix)
length(self::Vocabulary) = length(self.word2ix)

function one_hot_encode(self::Vocabulary, w::String)::T_N
  !haskey(self.word2ix, w) && (return nothing)
  w_ix = self.word2ix[w]
  [ix == w_ix ? 1. : 0. for ix ∈ 1:length(self.word2ix)]
  # FIXME: use a BitArray?
end

function add!(self::Vocabulary, word::String)
  if !haskey(self.word2ix, word)
    w_ix = length(self.word2ix) + 1
    self.word2ix[word] = w_ix
    self.ix2word[w_ix] = word
  end
end

function save_vocab(self::Vocabulary, filename::String)
  open(string(JSON_DATA_DIR, "/", filename), "w") do f
    JSON.print(f, self.word2ix)
  end
end

function load_vocab(filename::String)
  word2ix = open(string(JSON_DATA_DIR, "/", filename), "r") do f
    JSON.parse(f)
  end |> h -> D_SI(h)
  ix2word = D_IS(ix => w for (w, ix) ∈ word2ix)
  Vocabulary(word2ix, ix2word)
end

##
## Internal
##

function _add(words::Vector{String})
  w2ix = D_SI()
  ix2w = D_IS()
  for w ∈ words
    haskey(w2ix, w) && continue
    w_ix = length(w2ix) + 1
    w2ix[w] = w_ix
    ix2w[w_ix] = w
  end
  (w2ix, ix2w)
end


end ## Module
