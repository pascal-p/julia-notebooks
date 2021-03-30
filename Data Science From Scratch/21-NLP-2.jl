### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
    using Pkg; Pkg.activate("MLJ_env", shared=true)
	using Test
	using Random
	using Distributions
	using PlutoUI
	using Printf
	using JSON
	using Plots

	push!(LOAD_PATH, "./src")
	using YaCounter
	using YaDeepLearning
	using YaDistances: cosine_similarity
	using .TensorDT: Tensor
end

# ╔═╡ 87e5e2ec-8915-11eb-362b-6bf13a36b8e4
md"""
## NLP, part 2

ref. from book **"Data Science from Scratch"**, Chap 21
"""

# ╔═╡ 8cf46618-9109-11eb-2094-d99ba49a5b89
begin
  const D_SI = Dict{String, Integer}
  const D_IS = Dict{Integer, String}
  const S_N = Union{String, Nothing}
  const I_N = Union{Integer, Nothing}
  const T_N = Union{Tensor, Nothing}
  const F = Float64
end

# ╔═╡ 83d71b10-90d3-11eb-1c48-1ddf8be8bb57
begin
  import .AbstractLayers: AbstractLayer, forward, backward, parms, ∇parms
  using .Initializations: init_rand_normal

  struct Embedding <: AbstractLayer
    # @add_embedding_fields
    num_embedding::Integer
    embedding_dim::Integer
    embeddings::Tensor
    ∇::Tensor
    last_input_id::Vector{I_N}
    _type::Symbol
    store::Dict # {Any. Any}

    function Embedding(num_embedding::Integer, embedding_dim::Integer)
      shape = (embedding_dim, )
      embeddings = [init_rand_normal(shape) for _ ∈ 1:num_embedding]
      ∇ = [zeros(eltype(embeddings[1]), shape[1]) for _ ∈ 1:num_embedding]
      #
      new(num_embedding, embedding_dim, embeddings, ∇, [nothing], :embedding,
        Dict())
    end
  end

  function forward(self::Embedding, vinput_id::Vector{T})::Tensor where T <: Integer
    input_id = vinput_id[1]           ## only 1 element
    self.store[:input_id] = input_id  ## requires for backprop.
    self.embeddings[input_id]
  end

  function backward(self::Embedding, ∇p::Tensor)
    ## Zero out the gradient corresponding to the last input.
    ## This is cheaper than creating a new all-zero tensor each time.
    if !isnothing(self.last_input_id[1])
      zero_row = zeros(eltype(self.embeddings[1]), self.embedding_dim)
      self.∇[self.last_input_id[1]] = zero_row
    end
    self.last_input_id[1] = self.store[:input_id]
    self.∇[self.store[:input_id]] = vec(∇p)
  end

  parms(self::Embedding) = [self.embeddings]
  ∇parms(self::Embedding) = [self.∇]

  ## Extra internal
  idims(self::Embedding) = self.num_embedding
  odims(self::Embedding) = self.embedding_dim
end

# ╔═╡ cb25501a-8915-11eb-3626-a1ae6d233f92
html"""
<a id='toc'></a>
"""

# ╔═╡ cb0838ae-8915-11eb-082f-3991192a101f
md"""
#### TOC
  - [Word Vectors](#word_vectors)
  - [RNN](#rnn)
  - [Example using a character-level RNN](#character-level-rnn)
"""

# ╔═╡ dbbf22a2-8915-11eb-00eb-4b0278c0283d
html"""
<p style="text-align: right;">
  <a id='word_vectors'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

## ================================

# ╔═╡ 5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
md"""
### Word Vectors
"""

# ╔═╡ c1cb6562-90c8-11eb-2095-cbf63bb8b59d
md"""
We will start wit h a toy dataset to learn some word vectors.
"""

# ╔═╡ 073f6442-892e-11eb-0fc2-bbeb1d12619e
begin
  const colors = ["red", "green", "blue", "yellow", "black", ""]
  const nouns = ["bed", "car", "boat", "cat"]
  const verbs = ["is", "was", "seems"]
  const adverbs = ["very", "quite", "extremely", ""]
  const adjectives = ["slow", "fast", "soft", "hard"]

  const Num_Sentences = 50
  Random.seed!(70);
end

# ╔═╡ 2ec41c48-8a95-11eb-13b6-61f4a07a31db
function make_sentences()::String
  λ = coll -> coll[rand(1:length(coll))]
  [
    "The",
    λ(colors),
    λ(nouns),
    λ(verbs),
    λ(adverbs),
    λ(adjectives),
    "."
  ] |> a -> join(a, " ")
end

# ╔═╡ 045023be-8aac-11eb-29c1-3f4da066ff9b
const Sentences = [make_sentences() for _ in 1:Num_Sentences];

# ╔═╡ 04ab0ce8-90d3-11eb-3567-7f8f35e74e6a
md"""
We will want to one-hot-encode our words, which means we will need to convert them to IDs. We will introduce a Vocabulary struct to keep track of this mapping:
"""

# ╔═╡ b1c0a416-8aba-11eb-140a-9f3c4eb93346
begin
  const JSON_DATA_DIR = "./vocab_data"

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

  ## Public API

  function get_id(self::Vocabulary, w::String)::I_N
    !haskey(self.word2ix, w) && (return nothing)
    self.word2ix[w]
  end

  function get_word(self::Vocabulary, ix::Integer)::S_N
    !(1 ≤ ix ≤ length(self.word2ix)) && (return nothing)
    self.ix2word[ix]
  end

  size(self::Vocabulary) = length(self.word2ix)

  function one_hot_encode(self::Vocabulary, w::String)::T_N
    !haskey(self.word2ix, w) && (return nothing)
    w_ix = self.word2ix[w]
    [ix == w_ix ? 1. : 0. for ix ∈ 1:length(self.word2ix)]
    # FIXME: use a BitArray?
  end

  function add(self::Vocabulary, word::String)
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

  ## Internal

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
end

# ╔═╡ 65ec8554-8953-11eb-3973-b56039754312
begin
  const vlst = ["B", "A", "G", "E", "A", "M", "P", "M"]
  vocab = Vocabulary(vlst)

  @test size(vocab) == (length ∘ unique)(vlst)
  @test get_id(vocab, "A") == 2
  @test one_hot_encode(vocab, "B") == [1., 0., 0., 0., 0., 0.]
  @test isnothing(get_id(vocab, "z"))
  @test get_word(vocab, 6) == "P"
  @test isnothing(get_word(vocab, 10))

  add(vocab, "Y")
  @test size(vocab) == (length ∘ unique)(vlst) + 1
  @test one_hot_encode(vocab, "B") == [1., 0., 0., 0., 0., 0., 0.]
  @test one_hot_encode(vocab, "Y") == [0., 0., 0., 0., 0., 0., 1.]
  @test isnothing(one_hot_encode(vocab, "z"))
end

# ╔═╡ 0c8055b8-89b2-11eb-3046-331119a0dc9b
begin
  # use previous example to test save / load JSON
  save_vocab(vocab, "vocab.json")

  l_vocab = load_vocab("vocab.json")

  @test size(l_vocab) == (length ∘ unique)(vlst) + 1
  @test one_hot_encode(l_vocab, "B") == [1., 0., 0., 0., 0., 0., 0.]
  @test get_id(l_vocab, "A") == 2
  @test one_hot_encode(l_vocab, "Y") == [0., 0., 0., 0., 0., 0., 1.]
  @test isnothing(one_hot_encode(l_vocab, "z"))
end

# ╔═╡ d728d526-8956-11eb-3c22-e788d025e8b4
md"""
We will be using a word vector model called *skip-gram) that takes as input a word and generates probabilities for what words are likely to be seen near it.

We will feed this model training pairs (word, nearby_word) and try to minimize the SoftmaxCrossEntropy loss.

Let us design our neural network to achieve this. At its heart will be an embedding layer that takes as input a word ID and returns a word vector. Under the covers we can just use a lookup table for this (yes, an embedding is a lookup table).

Then we will pass the word vector to a Linear layer with the same number of outputs as we have words in our vocabulary.
As before, we will use softmax to convert these outputs to probabilities over nearby words. As we use gradient descent to train the model, we will be updating the vectors in the lookup table. Once we have finished the training, that lookup table gives us our word vectors.

Let us create that embedding layer. In practice we might want to embed things other than words, so we will construct a more general Embedding laye (later we will write a TextEmbedding layer that ss specifically for word vectors). In its constructor we will provide the number and dimension of our embedding vectors, so it can create the embeddings (which will be standard random normals, initially):
"""

# ╔═╡ c228148c-90e0-11eb-1007-43a7de1d22ee
# ## define a macro which build a macro to define fieldnames that can be added
# ## across several structs

# macro def(name, definition)
#   quote
#       macro $(esc(name))()
#           esc($(Expr(:quote, definition)))
#       end
#   end
# end

# ╔═╡ e6634800-90e0-11eb-2d3d-c58c08564720
# @def add_embedding_fields begin
#   num_embedding::Integer
#   embedding_dim::Integer
#   embeddings::Tensor
#   ∇::Tensor
#   last_input_id::I_N
#   _type::Symbol
#   store::Dict # {Any. Any}
# end

# ╔═╡ ec95a8d0-90d6-11eb-3713-9febeeceb15c
md"""
Remarks:
  - In our case we will only be embedding one word at a time.
  - For the backward pass we will get a gradient corresponding to the chosen embedding vector, and we will need to construct the corresponding gradient for self.embeddings, which is zero for every embedding other than the chosen one.
"""

# ╔═╡ f3fa0216-90da-11eb-157a-e3941af7117b
md"""
Now let us create a specific struct for `TextEmbdding`
"""

# ╔═╡ 17768334-8a98-11eb-1172-3d5079435dcf
begin
  struct TextEmbedding <: AbstractLayer
    # @add_embedding_fields
    vocab::Vocabulary
    embedding::Embedding
    _type::Symbol

    function TextEmbedding(vocab::Vocabulary, embedding_dim::Integer)
      embedding = Embedding(size(vocab), embedding_dim)
      new(vocab, embedding, :embedding)
    end
  end

  ## delegate
  for (fn, type_) ∈ [
      (:forward, Vector{Int64}),
      (:backward, Tensor),
      (:parms, nothing),
      (:∇parms, nothing),
      (:idims, nothing),
      (:odims, nothing)]

    @eval begin
      if isnothing($(type_))
        ($fn)(self::TextEmbedding) = ($fn)(self.embedding)
      else
        ($fn)(self::TextEmbedding, p::$(type_)) = ($fn)(self.embedding, p)
      end
    end
  end

  ## Specific TextEmbedding
  function Base.getindex(self::TextEmbedding, word::String)::Tensor
    """
    to allow us to call something like: embedding["black"]
    """
    w_id = get_id(self.vocab, word)
    isnothing(w_id) && (return nothing)
    self.embedding.embeddings[w_id]
  end

  get_embeddings(self::TextEmbedding) = self.embedding.embeddings

  function closest(self::TextEmbedding, word::String; n=5)::Vector{Tuple{F, String}}
    """
    returns the n closest words based on cosine similarity
    """
    vect = self[word]  ## getindex

    scores = [
      (cosine_similarity(vect, get_embeddings(self)[ix]), o_word)
      for (o_word, ix) ∈ self.vocab.word2ix
    ]
    sort(scores, rev=true)[1:n]
  end
end

# ╔═╡ e27e6ed6-90e7-11eb-17a7-79104767ea17
md"""
Our embedding layer is outputting vectors which can be fed into a linear(dense) layer.

But first we need to tokenize the sentences:
"""

# ╔═╡ f3d7e0be-90f3-11eb-00c7-036c1168da05
tokenized_sentences =  split.(Sentences) |>
  vvs -> [lowercase.(vs) for vs ∈ vvs] |>
  vvs -> filter.(w -> occursin(r"\A(?:[a-z]+|\.)\z", w), vvs)

# ╔═╡ e5532350-90e9-11eb-2e60-591759fb2f28
# Create a vocabulary (that is, a mapping word -> word_id) based on our text.
the_vocab = tokenized_sentences |>
  vvs -> reduce((rv, vs) -> rv = [rv..., vs...], vvs; init=[]) |>
  Vocabulary

# ╔═╡ ba364aec-90f5-11eb-3093-71206176896b
begin
  using .Layers

  Random.seed!(42)
  const EMBEDDING_DIM = 5
  embedding_layer = TextEmbedding(the_vocab, EMBEDDING_DIM)

  the_model = Layers.Sequential([
      ## 1. Given a word (vector of word_ids), look up its embedding.
      embedding_layer,

      ## 2. Use a linear layer to compute scores for "nearby" words
      Layers.Linear(EMBEDDING_DIM, size(the_vocab))
  ]);
end

# ╔═╡ d6b82be6-9112-11eb-110c-036fa8880c8a
begin
  using YaWorkingData: pca, transform

  comps = pca(embedding_layer.embedding.embeddings, 2)  # first 2 components
  transfo = transform(embedding_layer.embedding.embeddings, comps);

  coll = collect(zip(transfo...));

  v = []
  for (word, ix) ∈ the_vocab.word2ix
    (x, y) = transfo[ix]
    push!(v,
      (x, y, Plots.text(word, :red, :left, 8)))
  end
end

# ╔═╡ bb601544-90f3-11eb-1f6a-9758edfa0c59
md"""
From which we can create the training data:
"""

# ╔═╡ bb3fa48a-90f3-11eb-184e-7b04752115c1
begin
  # using .TensorDT: Tensor

  inputs = Vector{Int}()
  targets = Vector{Tensor}()

  for sentence ∈ tokenized_sentences, (ix, word) ∈ enumerate(sentence)
    for jx ∈ ix-2:ix+2
      jx == 0 && continue
      if 0 ≤ jx < length(sentence)
        nearby_word = sentence[jx]
        push!(inputs, get_id(the_vocab, word))
        push!(targets, one_hot_encode(the_vocab, nearby_word))
      end
    end
  end
end

# ╔═╡ ba1677d2-90f5-11eb-1779-05df1ee68db6
begin
  using .Loss
  using .Optimizers

  the_loss_fn = Loss.SoftmaxXEntropy()
  the_opt_fn = Optimizers.GD(0.01)

  for epoch ∈ 1:500
    epoch_loss = 0.
    for (x, y) ∈ zip(inputs, targets)
      ŷ = forward(the_model, [x])
      epoch_loss += Loss.loss(the_loss_fn, ŷ, y)
      ∇p = Loss.∇loss(the_loss_fn, ŷ, y)
      Layers.backward(the_model, ∇p)
      Optimizers.astep(the_opt_fn, the_model)
    end
    if epoch % 50 == 0
      @printf("%3d => %7.5f\n", epoch, epoch_loss) ## Print the loss
      println(closest(embedding_layer, "black"))   ## and also a few nearest words
      println(closest(embedding_layer, "slow"))    ## so we can see what's being
      println(closest(embedding_layer, "car"))     ## learned
    end
  end
end

# ╔═╡ bb248f9c-90f3-11eb-3766-e9c5cfae3920
length(inputs), length(targets)

# ╔═╡ bb0b45c8-90f3-11eb-2087-dd660f4305d4
md"""
And now we can build our model:
"""

# ╔═╡ da063a92-9110-11eb-1613-f51d8744fd95
begin
  pairs = [
    (cosine_similarity(embedding_layer[w1], embedding_layer[w2]), w1, w2)
    for (w1,) ∈ the_vocab.word2ix for (w2,) ∈ the_vocab.word2ix if w1 < w2
  ]
  sort!(pairs, rev=true)
  with_terminal() do
    for p ∈ pairs[1:7]
      println(p)
    end
  end
end

# ╔═╡ 78e07c8c-9133-11eb-2721-cdb8c99043b5
md"""
Let us extract the first two principal components and plot them:
"""

# ╔═╡ 8153d3ac-9113-11eb-1e9c-5dabd3012046
begin
  scatter(F[coll[1]...], F[coll[2]...], color=:lightgreen, marker=:circle,
    markersize=2, size=(600, 500), legend=false)
  annotate!(v...)
end

# ╔═╡ c484c36e-9133-11eb-22ef-dfdcfa0d75ec
md"""
This shows that similar words tends to cluster together (almost...)
"""

# ╔═╡ 432cd594-89b9-11eb-2d4a-6f46f08a511d
html"""
<p style="text-align: right;">
  <a id='rnn'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 48db121e-8a8e-11eb-189f-d9f41e4b1d9d
md"""
### RNN

"""

# ╔═╡ dd9487fa-9035-11eb-174b-fdc642e5f518
# TODO...

# ╔═╡ fe725b62-9134-11eb-159f-9d6cdc91e798


# ╔═╡ 985e4192-9134-11eb-2676-8f6e2a79de43
html"""
<p style="text-align: right;">
  <a id='character-level-rnn'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 983f0df4-9134-11eb-0b3c-c1503a7a838b
md"""
### Example using a character-level RNN
"""

# ╔═╡ f21e8240-8ab9-11eb-1223-cbc0f2b1aa8c
# TODO...

# ╔═╡ Cell order:
# ╟─87e5e2ec-8915-11eb-362b-6bf13a36b8e4
# ╠═5eebac68-891b-11eb-37ba-c1d9481c6134
# ╠═8cf46618-9109-11eb-2094-d99ba49a5b89
# ╟─cb25501a-8915-11eb-3626-a1ae6d233f92
# ╟─cb0838ae-8915-11eb-082f-3991192a101f
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╟─5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╟─c1cb6562-90c8-11eb-2095-cbf63bb8b59d
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═2ec41c48-8a95-11eb-13b6-61f4a07a31db
# ╠═045023be-8aac-11eb-29c1-3f4da066ff9b
# ╟─04ab0ce8-90d3-11eb-3567-7f8f35e74e6a
# ╠═b1c0a416-8aba-11eb-140a-9f3c4eb93346
# ╠═65ec8554-8953-11eb-3973-b56039754312
# ╠═0c8055b8-89b2-11eb-3046-331119a0dc9b
# ╟─d728d526-8956-11eb-3c22-e788d025e8b4
# ╠═c228148c-90e0-11eb-1007-43a7de1d22ee
# ╠═e6634800-90e0-11eb-2d3d-c58c08564720
# ╠═83d71b10-90d3-11eb-1c48-1ddf8be8bb57
# ╟─ec95a8d0-90d6-11eb-3713-9febeeceb15c
# ╟─f3fa0216-90da-11eb-157a-e3941af7117b
# ╠═17768334-8a98-11eb-1172-3d5079435dcf
# ╟─e27e6ed6-90e7-11eb-17a7-79104767ea17
# ╠═f3d7e0be-90f3-11eb-00c7-036c1168da05
# ╠═e5532350-90e9-11eb-2e60-591759fb2f28
# ╟─bb601544-90f3-11eb-1f6a-9758edfa0c59
# ╠═bb3fa48a-90f3-11eb-184e-7b04752115c1
# ╠═bb248f9c-90f3-11eb-3766-e9c5cfae3920
# ╟─bb0b45c8-90f3-11eb-2087-dd660f4305d4
# ╠═ba364aec-90f5-11eb-3093-71206176896b
# ╠═ba1677d2-90f5-11eb-1779-05df1ee68db6
# ╠═da063a92-9110-11eb-1613-f51d8744fd95
# ╟─78e07c8c-9133-11eb-2721-cdb8c99043b5
# ╠═d6b82be6-9112-11eb-110c-036fa8880c8a
# ╠═8153d3ac-9113-11eb-1e9c-5dabd3012046
# ╟─c484c36e-9133-11eb-22ef-dfdcfa0d75ec
# ╟─432cd594-89b9-11eb-2d4a-6f46f08a511d
# ╟─48db121e-8a8e-11eb-189f-d9f41e4b1d9d
# ╠═dd9487fa-9035-11eb-174b-fdc642e5f518
# ╠═fe725b62-9134-11eb-159f-9d6cdc91e798
# ╟─985e4192-9134-11eb-2676-8f6e2a79de43
# ╟─983f0df4-9134-11eb-0b3c-c1503a7a838b
# ╠═f21e8240-8ab9-11eb-1223-cbc0f2b1aa8c
