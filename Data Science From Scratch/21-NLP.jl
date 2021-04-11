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

	push!(LOAD_PATH, "./src")
	using YaCounter
end

# ╔═╡ 87e5e2ec-8915-11eb-362b-6bf13a36b8e4
md"""
## NLP

ref. from book **"Data Science from Scratch"**, Chap 21

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ cb25501a-8915-11eb-3626-a1ae6d233f92
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ cb0838ae-8915-11eb-082f-3991192a101f
html"""
<style>
  main {
	max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
	background: wheat;
  }
</style>
"""

# ╔═╡ caf03ada-8915-11eb-2935-01e110accba6
html"""
<hr />
"""

# ╔═╡ 09066aa6-9049-11eb-27d6-b10b3120c900
begin
	const Int = Integer
	const T_Int = Tuple{Int, Int}
	const D_TV = Dict{Tuple{Int, Int}, Vector{Int}}
	const F = Float64
	const V_F = Vector{F}
end

# ╔═╡ cad66356-8915-11eb-0173-ada200678f63
md"""
### Gibbs Sampling

Generating samples from some distributions is easy. We can get uniform random variables with: `Uniform()`

and normal random variables with: `Normal(...)`

But some distributions are harder to sample from. 

Gibbs sampling is a technique for generating samples from multidimensional distributions when we only know some of the conditional distributions.

Imagine rolling two dice. Let x be the value of the first die and y be the sum of the dice, and imagine we wanted to generate lots of (x, y) pairs. In this case it is easy to generate the samples directly:
"""

# ╔═╡ c11e47b0-9044-11eb-1f22-9de42ad879f1
Random.seed!(17)

# ╔═╡ dc3b7280-8915-11eb-258a-1789476897b9
function roll_die()::Int
	rand(1:6)
end

# ╔═╡ dc209b9a-8915-11eb-0f63-ab3b7c33793c
function direct_sample()::T_Int
	d1, d2 = roll_die(), roll_die()
	(d1, d1 + d2)
end

# ╔═╡ d7aade44-891b-11eb-00d3-abe7406c4b09
md"""
Imagine that we only knew the conditional distributions. 

The distribution of y conditional on x is easy — if we know the value of x, y is
equally likely to be x + 1, x + 2, x + 3, x + 4, x + 5, or x + 6:
"""

# ╔═╡ 9ae99efe-891c-11eb-3d1f-89182e3f9ff8
function random_y_given_x(x::Integer)::Int
	"""
	Equally likely to be x + 1, x + 2, ... , x + 6
	"""
	x + roll_die()
end

# ╔═╡ ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
md"""
However the other direction is a bit more complicated. For example, if we know that y is
2, then necessarily x is 1 (since the only way two dice can sum to 2 is if
both of them are 1). If we know y is 3, then x is equally likely to be 1 or 2.
Similarly, if y is 11, then x has to be either 5 or 6:
"""

# ╔═╡ 13e3ccb6-8aae-11eb-3a9e-85b5afc74097
function random_x_given_y(y::Integer)::Int
	if y ≤ 7
		## if total is less (or equal) than 7, the first die is equally likely to be
		## 1, 2, ..., (total - 1)
		rand(1:y)
	else
		## if the total is 7+, the first die is equally likely to be
		## (total - 6), (total - 5), ..., 6
		rand(y - 6:7)
	end
end

# ╔═╡ 13c729da-8aae-11eb-29aa-b171020ad8dd
md"""
The way Gibbs sampling works is that we start with any (valid) values for x and y and then repeatedly alternate:
  - replacing x with a random value picked conditional on y and  
  - replacing y with a random value picked conditional on x. 

After a number of iterations, the resulting values of x and y will represent a sample from the unconditional joint distribution:
"""

# ╔═╡ 2e9609b2-9046-11eb-0ac6-7ff568ff8668
function gibbs_sample(;num_iters=100)::T_Int
	x, y = 1, 2 # doesn't really matter
	for _ ∈ 1:num_iters
		x = random_x_given_y(y)
		y = random_y_given_x(x)
	end
	(x, y)
end

# ╔═╡ 13b2940c-8aae-11eb-2dd2-8dec30dd4881
function cmp_distributions(;num_samples=1000)::D_TV
	counts = D_TV()
	for _ ∈ 1:num_samples
		gs = gibbs_sample()
		v_s = get(counts, gs, [0, 0])
		v_s[1] += 1
		counts[gs] = v_s
		ds = direct_sample()
		v_s = get(counts, ds, [0, 0])
		v_s[2] += 1
		counts[ds] = v_s
	end
	counts
end

# ╔═╡ 8aa8bb6a-9047-11eb-1c48-7dfd972d7580
cmp_distributions()

# ╔═╡ dc0c5a5e-8915-11eb-2c62-5328b42add69
html"""
<hr />
"""

# ╔═╡ dbefe77a-8915-11eb-39f1-5d0c84729739
md"""
### Topic Modeling

An approach to understanding our users’ interests might try to identify the topics
that underlie those interests. A technique called latent Dirichlet allocation (LDA) is commonly used
to identify common topics in a set of documents.
We’ll apply it to documents that consist of each user’s interests.

LDA has some similarities to the Naive Bayes classifier we built previously in that it assumes a probabilistic
model for documents. For our purposes the model assumes that:

  - There is some fixed number K of topics.

  - There is a random variable that assigns each topic an associated probability distribution over words.
    Think of this distribution as the probability of seeing word w given topic k.

  - There is another random variable that assigns each document a probability distribution over topics.
    Think of this distribution as the mixture of topics in document d.

  - Each word in a document was generated by first randomly picking a topic (from the document’s distribution
    of topics) and then randomly picking a word (from the topic’s distribution of words).

In particular, we have a collection of documents, each of which is a list of words. And we have a corresponding
collection of document_topics that assigns a topic (here a number between 0 and K – 1) to each word in each
document.

So, the fifth word in the fourth document is: documents[4][5]
and the topic from which that word was chosen is: document_topics[4][5]

This very explicitly defines each document’s distribution over topics, and it implicitly defines each topic’s distribution over words.

We can estimate the likelihood that topic 1 produces a certain word by comparing how many times topic 1 produces that word with how many
times topic 1 produces any word. (Similarly, when we built a spam filter, we compared how many times each word appeared in spams with the
total number of words appearing in spams.)

Although these topics are just numbers, we can give them descriptive names by looking at the words on which they put the heaviest weight.
We just have to somehow generate the document_topics. This is where Gibbs sampling comes into play.

  We start by assigning every word in every document a topic completely at random.

  Now we go through each document one word at a time. For that word and document, we construct weights for each topic that depend on the
  (current) distribution of topics in that document and the (current) distribution of words for that topic.

  We then use those weights to sample a new topic for that word.

  If we iterate this process many times, we will end up with a joint sample from the topic-word distribution and the document-topic distribution.

Let us start with a function to randomly choose an index based on an arbitrary set of weights:
"""

# ╔═╡ dbd86924-8915-11eb-351f-8362f09ba984
function sample_from(weights::V_F)::Int
	"""
	returns ix (index) with probability weights[ix] / sum(weights)
	"""
	total = sum(weights)
	rnd = total * rand()       ## uniform between 0 and total
	for (ix, w) ∈ enumerate(weights)
		rnd -= w
		rnd ≤ 0. && (return ix) ## return the smallest i such that
		#                       ## weights[0] + ... + weights[i] ≥ rnd
	end
end

# ╔═╡ d32b86e0-8928-11eb-193c-e3d7c85d23dd
md"""
if we give it weights [1, 1, 3] , then one-fifth of the time it will return 0, one-fifth of the time it will return 1, and three-fifths of the time it will return 2.
"""

# ╔═╡ 4a92cc8e-904a-11eb-11de-e77d09365187
begin
	draws = Counter([sample_from([.1, .1, .8]) for _ ∈ 1:1000])

	@test 10 < draws[1] < 190    ## should be ~10%, this is a really loose test
	@test 10 < draws[2] < 190    ## should be ~10%, this is a really loose test
	@test 650 < draws[3] < 950   ## should be ~80%, this is a really loose test
	@test sum(values(draws)) == 1000
end

# ╔═╡ f1bc0f20-904a-11eb-394e-23d1ee736caf
begin
	const Documents = [
    	["Hadoop", "Big Data", "HBase", "Java", "Spark", "Storm", "Cassandra"],
    	["NoSQL", "MongoDB", "Cassandra", "HBase", "Postgres"],
    	["Python", "scikit-learn", "scipy", "Julia",  "numpy", "statsmodels", "pandas"],
    	["R", "Python", "Julia", "statistics", "regression", "probability"],
    	["machine learning", "regression", "decision trees", "libsvm"],
    	["Python", "R", "Java", "C++", "Julia", "programming languages"],
    	["statistics", "probability", "mathematics", "theory"],
    	["machine learning", "scikit-learn", "Mahout", "neural networks"],
    	["neural networks", "deep learning", "Flux", "Big Data", "artificial intelligence"],
    	["Hadoop", "Java", "MapReduce", "Big Data"],
    	["statistics", "R", "statsmodels"],
    	["C++", "deep learning", "artificial intelligence", "probability"],
    	["pandas", "DataFrames", "Julia", "R", "Python"],
    	["databases", "HBase", "Postgres", "MySQL", "MongoDB"],
    	["libsvm", "regression", "support vector machines"],
		["Julia", "MLJ", "Flux", "DataFrames"]
	]

	const K = 4;
end

# ╔═╡ f1a241d0-904a-11eb-06cc-fda025d4f3b5
begin
	## a list of Counters, one for each document
	doc_topic_counts = [Counter() for _ ∈ Documents]

	## a list of Counters, one for each  topic
	topic_word_counts = [Counter() for _ ∈ 1:K] 

	topic_counts = zeros(Int, K)     # a vector of numbers, one for each topic
	doc_lengths = length.(Documents) # a vector of numbers, one for each document
	
	unique_words = [w for doc ∈ Documents for w ∈ doc] |> unique
	const W, D = length(unique_words), length(Documents);
end

# ╔═╡ d1f14cce-904e-11eb-27c9-4353466db275
md"""
Now we are ready to define our conditional probability functions. Each Will have  smoothing term that ensures every topic has a nonzero chance of being chosen in any document and that every word has a nonzero chance of being chosen for any topic:
"""

# ╔═╡ d1b8b198-904e-11eb-0a40-27d960d3b303
function p_topic_given_doc(topic::Int, d::Int; ϵ=.1)::F
	"""
	A closure calculating the fraction of words in document 'd' that are assigned 
	to 'topic' (plus some smoothing)
	"""
	(doc_topic_counts[d][topic] + ϵ) / (doc_lengths[d] + K * ϵ)
end

# ╔═╡ 60b8d5ca-905d-11eb-1238-43d2ed28bdfc
function p_word_given_topic(word::String, topic::Int; ϵ=.1)::F
	"""
	The fraction of words assigned to 'topic' that equal 'word' (plus some smoothing)
	"""
	(topic_word_counts[topic][word] + ϵ) / (topic_counts[topic] + W * ϵ)
end

# ╔═╡ 4ae5db5e-904f-11eb-2073-b17993b09f0f
function topic_weight(d::Int, word::String, k::Int)::F
	"""
	Given a document and a word in that document, return the weight for the kth topic
	"""
	p_word_given_topic(word, k) * p_topic_given_doc(k, d)
end

# ╔═╡ ea0dcb42-905e-11eb-25df-05704be5e114
function choose_new_topic(d::Int, word::String)::Int
	sample_from([topic_weight(d, word, k) for k ∈ 1:K])
end

# ╔═╡ 584b4fbc-905f-11eb-0631-ad00a20dc881
md"""
Given a word and its document, the likelihood of any topic choice depends on both how likely that topic is for the document and how likely that word is for the topic.

Now let us start assigning every word to a random topic and populating our counters appropriately:
"""

# ╔═╡ 4aca19be-904f-11eb-26af-bd9f21c61a0c
begin
	Random.seed!(42)
	
	doc_topics = [[rand(1:K) for w ∈ doc] for doc ∈ Documents]
	
	for d ∈ 1:D
		for (w, topic) ∈ zip(Documents[d], doc_topics[d])
			doc_topic_counts[d][topic] += 1
			topic_word_counts[topic][w] += 1
			topic_counts[topic] += 1
		end
	end
end

# ╔═╡ 4ed6af9a-905e-11eb-1b8a-152f021dabf4
md"""
The goal is to get a joint sample of the topics-word distribution and the documents-topic distribution. We do this using a form of Gibbs sampling that uses the conditional probabilities defined previously:
"""

# ╔═╡ 4a928fa8-904f-11eb-2f47-4d319a1a6e58
for iter ∈ 1:1000
	for d ∈ 1:D, (ix, (word, topic)) ∈ enumerate(zip(Documents[d], doc_topics[d]))
		## Remove this word-topic from the counts so that it does not 
		## influence the weigths
		doc_topic_counts[d][topic] -= 1
		topic_word_counts[topic][word] -= 1
		topic_counts[topic] -= 1
		doc_lengths[d] -= 1

		## Choose new topic based on the weigths
		new_topic = choose_new_topic(d, word)
		doc_topics[d][ix] = new_topic

		## Update new topic 
		doc_topic_counts[d][new_topic] += 1
		topic_word_counts[new_topic][word] += 1
		topic_counts[new_topic] += 1
		doc_lengths[d] += 1
	end
end

# ╔═╡ df809854-9071-11eb-0bed-1f9e8c66b023
md"""
The topics are just numbers (from 1 to 4), if we want names we have to find by ourselves. 
"""

# ╔═╡ f3d142e2-906f-11eb-1a04-37c8d25ac050
with_terminal() do
	# 7 items per topic
	for (k, word_cnts) ∈ enumerate(topic_word_counts)
		for (ix, (w, cnt)) ∈ enumerate(most_common(word_cnts, 7))
			cnt > 0 && @printf("%3d/%2d - %-25s %4d\n", k, ix, w, cnt)
		end
		println()
	end
end

# ╔═╡ 4f708e46-9070-11eb-2e90-45e2e028bbdb
md"""
We may define the following topics:
  1. Big Data & Databases
  2. AI and Languages
  3. ML
  4. Statistics and Dynamic Languages
"""

# ╔═╡ 4b449308-9070-11eb-2aed-65775ffabadb
topic_names = [
	"Big Data & Databases",
	"AI and Languages",
	"ML",
	"Statistics and Dynamic Languages"
]

# ╔═╡ 89f83412-9073-11eb-11bf-e7a77ea377ab
with_terminal() do
	for (doc, topic_cnts) ∈ zip(Documents, doc_topic_counts)
		println(doc)
		for (topic, cnt) ∈ most_common(topic_cnts)
			cnt > 0. && @printf(" - %-20s => %2d\n", topic_names[topic], cnt)
		end
		println()
	end
end

# ╔═╡ Cell order:
# ╟─87e5e2ec-8915-11eb-362b-6bf13a36b8e4
# ╠═5eebac68-891b-11eb-37ba-c1d9481c6134
# ╟─cb25501a-8915-11eb-3626-a1ae6d233f92
# ╟─cb0838ae-8915-11eb-082f-3991192a101f
# ╟─caf03ada-8915-11eb-2935-01e110accba6
# ╠═09066aa6-9049-11eb-27d6-b10b3120c900
# ╟─cad66356-8915-11eb-0173-ada200678f63
# ╠═c11e47b0-9044-11eb-1f22-9de42ad879f1
# ╠═dc3b7280-8915-11eb-258a-1789476897b9
# ╠═dc209b9a-8915-11eb-0f63-ab3b7c33793c
# ╟─d7aade44-891b-11eb-00d3-abe7406c4b09
# ╠═9ae99efe-891c-11eb-3d1f-89182e3f9ff8
# ╟─ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
# ╠═13e3ccb6-8aae-11eb-3a9e-85b5afc74097
# ╟─13c729da-8aae-11eb-29aa-b171020ad8dd
# ╠═2e9609b2-9046-11eb-0ac6-7ff568ff8668
# ╠═13b2940c-8aae-11eb-2dd2-8dec30dd4881
# ╠═8aa8bb6a-9047-11eb-1c48-7dfd972d7580
# ╟─dc0c5a5e-8915-11eb-2c62-5328b42add69
# ╟─dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╟─d32b86e0-8928-11eb-193c-e3d7c85d23dd
# ╠═4a92cc8e-904a-11eb-11de-e77d09365187
# ╠═f1bc0f20-904a-11eb-394e-23d1ee736caf
# ╠═f1a241d0-904a-11eb-06cc-fda025d4f3b5
# ╟─d1f14cce-904e-11eb-27c9-4353466db275
# ╠═d1b8b198-904e-11eb-0a40-27d960d3b303
# ╠═60b8d5ca-905d-11eb-1238-43d2ed28bdfc
# ╠═4ae5db5e-904f-11eb-2073-b17993b09f0f
# ╠═ea0dcb42-905e-11eb-25df-05704be5e114
# ╟─584b4fbc-905f-11eb-0631-ad00a20dc881
# ╠═4aca19be-904f-11eb-26af-bd9f21c61a0c
# ╟─4ed6af9a-905e-11eb-1b8a-152f021dabf4
# ╠═4a928fa8-904f-11eb-2f47-4d319a1a6e58
# ╟─df809854-9071-11eb-0bed-1f9e8c66b023
# ╠═f3d142e2-906f-11eb-1a04-37c8d25ac050
# ╟─4f708e46-9070-11eb-2e90-45e2e028bbdb
# ╠═4b449308-9070-11eb-2aed-65775ffabadb
# ╠═89f83412-9073-11eb-11bf-e7a77ea377ab
