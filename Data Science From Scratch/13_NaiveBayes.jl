### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
  using Test
  using Random

  # push!(LOAD_PATH, "./src")
  # using YaLinearAlgebra
end

# ╔═╡ 87e5e2ec-8915-11eb-362b-6bf13a36b8e4
md"""
## Naive Bayes

ref. from book **"Data Science from Scratch"**, Chap 13
"""

# ╔═╡ cb25501a-8915-11eb-3626-a1ae6d233f92
html"""
<a id='toc'></a>
"""

# ╔═╡ cb0838ae-8915-11eb-082f-3991192a101f
md"""
#### TOC
  - [Implementation](#implementation)
  - [Testing our Model](#testing-model)
  - [Using our Model](#using_model)
"""

# ╔═╡ caf03ada-8915-11eb-2935-01e110accba6
html"""
<p style="text-align: right;">
  <a id='implementation'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ cad66356-8915-11eb-0173-ada200678f63
md"""
### The model

First we will create a function to tokenize messages into tokens.
"""

# ╔═╡ dc3b7280-8915-11eb-258a-1789476897b9
function tokenize(text::String)::Set{String}
	lowercase(text) |>
		split |>
	 	a -> filter(s -> occursin(r"\A[\w']+.?\z", s), a) |>
		a -> map(s -> replace(s, r"\A([\w']+)[^w]?\z" => s"\1"), a) |>
		Set
end

# ╔═╡ dc209b9a-8915-11eb-0f63-ab3b7c33793c
begin
	test_msg₀ = "Machine Leaning isn't that fun, if all one does is Data Munging!"
	test_set₀ = tokenize(test_msg₀)
	
	@test typeof(test_set₀) == Set{String}
	@test length(test_set₀) == 12
	@test test_set₀ == Set{String}(["is", "data", "munging", "one", 
		"that", "leaning", "if", "machine", "all", "fun", "isn't", "does"
	])
end

# ╔═╡ 5a207b90-89d3-11eb-2a3e-655804b5bc8b
md"""
Second, let us define a structure for our messages:
"""

# ╔═╡ 6a8e15fc-89d3-11eb-3c28-43b3d0ad0e23
struct Message
	text::String
	is_spam::Bool
	
	Message(text::String; is_spam::Bool=false) = new(text, is_spam)
end

# ╔═╡ d7aade44-891b-11eb-00d3-abe7406c4b09
md"""
As our classifier needs to keep track of tokens, counts, and labels from the training
data, we will create a (mutable) struct for this and a collection of related functions.
"""

# ╔═╡ 6dc9648a-89d6-11eb-35d0-e30bf7e3d3fc
const TF = Float64

# ╔═╡ 9ae99efe-891c-11eb-3d1f-89182e3f9ff8
mutable struct NaiveBayes
	k::TF
	tokens::Set{String}
	token_spam_cnt::Dict{String, Integer}
	token_ham_cnt::Dict{String, Integer}
	n_spam_msg::Integer
	n_ham_msg::Integer
	
	function NaiveBayes(;k::TF=0.4)
		@assert k > zero(TF)
		new(k, Set{String}(), Dict{String, Integer}(), Dict{String, Integer}(),
			0, 0)
	end
end

# ╔═╡ d7931368-891b-11eb-2899-f5e5a3f4bd35
md"""
Next, let us define a function to train it on a collection of messages.
"""

# ╔═╡ ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
function train(nb::NaiveBayes, messages::Vector{Message})
	for msg ∈ messages
		if msg.is_spam 
			nb.n_spam_msg += 1
		else
			nb.n_ham_msg += 1
		end
		for token ∈ tokenize(msg.text)
			push!(nb.tokens, token)
			if msg.is_spam
				nb.token_spam_cnt[token] = get(nb.token_spam_cnt, token, 0) + 1
			else
				nb.token_ham_cnt[token] = get(nb.token_ham_cnt, token, 0) + 1
			end
		end
	end
end

# ╔═╡ 50fe5114-891e-11eb-18ee-35d98ad32b7b
md"""
We will want to predict $P(spam | token)$. In order to apply Bayes’s theorem we need to know $P(token | spam)$ and $P(token | ham)$ for each token in the vocabulary.
"""

# ╔═╡ 4ffc3b48-895a-11eb-1ed2-f78b522d0ae9
function probabilities(nb::NaiveBayes, token::String)::Tuple{Float64, Float64}
	# exception if token not defined...
	spam, ham = nb.token_spam_cnt[token], nb.token_ham_counts[token]
	#
	p_token_spam = (spam + nb.k) / (nb.n_spam_msg + 2 * nb.k)
	p_token_ham = (ham + self.k) / (nb.n_ham_msg + 2 * nb.k)
	#
	(p_token_spam, p_token_ham)
end

# ╔═╡ 90f58d04-8958-11eb-170e-0f17904c9f2c
md"""
Finally our predict function, where to avoid numerical underflow, we will sum up the log of probabilites instead of multiplying probabilities, before converting them back using exponentiaL.
"""

# ╔═╡ 123bcdb0-89d6-11eb-18f2-7f1acdb57a51
function predict(nb::NaiveBayes, text::String)::TF
	tokens = tokenize(text)
	log_prob_spam = log_prob_ham = zero(TF) 
	#
	for token ∈ tokens
		prob_spam, prob_ham = probabilities(nb, token)
		if token ∈ nb.tokens
			log_prob_spam += log(prob_spam)
			log_prob_ham += log(prob_ham)
		else
			# otherwise add the log probability of _not_ seeing token in message
			log_prob_spam += log(one(TF) - prob_spam)
			log_prob_ham += log(one(TF) - prob_ham)
		end
	end
	
	prob_spam, prob_spam = exp(log_prob_spam), exp(log_prob_ham)
	prob_spam / (prob_spam + prob_ham)
end

# ╔═╡ dc0c5a5e-8915-11eb-2c62-5328b42add69
html"""
<p style="text-align: right;">
  <a id='testing-model'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ dbefe77a-8915-11eb-39f1-5d0c84729739
md"""
### Testing Our Model
"""

# ╔═╡ dbd86924-8915-11eb-351f-8362f09ba984
begin
	test_msgs = [Message("spam rules", is_spam=true),
		Message("ham rules", is_spam=false),
		Message("hello ham", is_spam=false)
               ]
	test_model = NaiveBayes(;k=0.5)
	train(test_model, test_msgs)
	
	@test test_model.tokens == Set{String}(["spam", "ham", "rules", "hello"])
	@test test_model.n_spam_msg == 1
	@test test_model.n_ham_msg == 2
	@test test_model.token_spam_cnt == Dict("spam" => 1, "rules" => 1)
	@test test_model.token_ham_cnt == Dict("ham" => 2, "rules" => 1, "hello" => 1)
end

# ╔═╡ c7410266-89d6-11eb-36b2-71e5df086e52
md"""
Ok, now let’s make a prediction.
"""

# ╔═╡ d32b86e0-8928-11eb-193c-e3d7c85d23dd
begin
  # @test ...
end

# ╔═╡ 5809f59e-8916-11eb-1c09-6fa00c043e7a
md"""
Now let’s make a prediction. We’ll also (laboriously) go through our Naive Bayes
logic by hand, and make sure that we get the same result:
"""

# ╔═╡ 90d83cae-8958-11eb-2d5c-bd298437f953
begin
  # @test ...
end


# ╔═╡ ab9ac56e-8969-11eb-3340-337957fd81b7
md"""
Comment on tests...
"""

# ╔═╡ dbbf22a2-8915-11eb-00eb-4b0278c0283d
html"""
<p style="text-align: right;">
  <a id='using_model'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

## ================================

# ╔═╡ 5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
md"""
A popular (if somewhat old) dataset is the SpamAssassin public corpus. We’ll look
at the files prefixed with 20021010.
"""

# ╔═╡ 073f6442-892e-11eb-0fc2-bbeb1d12619e
begin
  # code to download and untar spam/ham datafiles
end

# ╔═╡ 25fb8f9a-8952-11eb-35bb-b173ac466835
md"""
It’s possible the location of the files will change (this happened between the first
and second editions of this book), in which case adjust the script accordingly.
...
"""

# ╔═╡ 65ec8554-8953-11eb-3973-b56039754312
begin
  # load the messages... subject
end

# ╔═╡ 0c8055b8-89b2-11eb-3046-331119a0dc9b
md"""
split data...
"""

# ╔═╡ d728d526-8956-11eb-3c22-e788d025e8b4
# split data function...

# ╔═╡ ad388bba-8955-11eb-34ee-4db60fb0db8a
md"""
Generate predictions
"""

# ╔═╡ ad036de6-89b1-11eb-3973-b56039754312
# code for predictions

## ================================

# ╔═╡ dba976a2-8915-11eb-0ff0-b38952cbc38b
md"""
This gives 84 true positives (spam classified as “spam”), 25 false positives (ham
classified as “spam”), 703 true negatives (ham classified as “ham”), and 44 false
negatives (spam classified as “ham”). This means our precision is 84 / (84 + 25) =
77%, and our recall is 84 / (84 + 44) = 65%, which are not bad numbers for such a
simple model. (Presumably we’d do better if we looked at more than the subject
lines.)
"""

# ╔═╡ ca91a0d6-8915-11eb-36cc-a18fc8efaf40
# p_spam_given_token


# ╔═╡ 194958a6-89b4-11eb-3340-337957fd81b7
md"""
The spammiest words include things like sale, mortgage, money, and rates...
"""

# ╔═╡ fa1fe202-89b7-11eb-34ee-4db60fb0db8a
md"""
using stemmer...
"""

# ╔═╡ 432cd594-89b9-11eb-2d4a-6f46f08a511d
# TODO ...

# ╔═╡ Cell order:
# ╟─87e5e2ec-8915-11eb-362b-6bf13a36b8e4
# ╠═5eebac68-891b-11eb-37ba-c1d9481c6134
# ╟─cb25501a-8915-11eb-3626-a1ae6d233f92
# ╟─cb0838ae-8915-11eb-082f-3991192a101f
# ╟─caf03ada-8915-11eb-2935-01e110accba6
# ╟─cad66356-8915-11eb-0173-ada200678f63
# ╠═dc3b7280-8915-11eb-258a-1789476897b9
# ╠═dc209b9a-8915-11eb-0f63-ab3b7c33793c
# ╟─5a207b90-89d3-11eb-2a3e-655804b5bc8b
# ╠═6a8e15fc-89d3-11eb-3c28-43b3d0ad0e23
# ╟─d7aade44-891b-11eb-00d3-abe7406c4b09
# ╠═6dc9648a-89d6-11eb-35d0-e30bf7e3d3fc
# ╠═9ae99efe-891c-11eb-3d1f-89182e3f9ff8
# ╟─d7931368-891b-11eb-2899-f5e5a3f4bd35
# ╠═ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
# ╟─50fe5114-891e-11eb-18ee-35d98ad32b7b
# ╠═4ffc3b48-895a-11eb-1ed2-f78b522d0ae9
# ╟─90f58d04-8958-11eb-170e-0f17904c9f2c
# ╠═123bcdb0-89d6-11eb-18f2-7f1acdb57a51
# ╟─dc0c5a5e-8915-11eb-2c62-5328b42add69
# ╟─dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╟─c7410266-89d6-11eb-36b2-71e5df086e52
# ╠═d32b86e0-8928-11eb-193c-e3d7c85d23dd
# ╟─5809f59e-8916-11eb-1c09-6fa00c043e7a
# ╠═90d83cae-8958-11eb-2d5c-bd298437f953
# ╟─ab9ac56e-8969-11eb-3340-337957fd81b7
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╠═5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═25fb8f9a-8952-11eb-35bb-b173ac466835
# ╠═65ec8554-8953-11eb-3973-b56039754312
# ╠═0c8055b8-89b2-11eb-3046-331119a0dc9b
# ╠═d728d526-8956-11eb-3c22-e788d025e8b4
# ╠═ad388bba-8955-11eb-34ee-4db60fb0db8a
# ╟─ad036de6-89b1-11eb-3973-b56039754312
# ╟─dba976a2-8915-11eb-0ff0-b38952cbc38b
# ╠═ca91a0d6-8915-11eb-36cc-a18fc8efaf40
# ╠═194958a6-89b4-11eb-3340-337957fd81b7
# ╠═fa1fe202-89b7-11eb-34ee-4db60fb0db8a
# ╠═432cd594-89b9-11eb-2d4a-6f46f08a511d
