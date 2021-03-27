### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
  	using Pkg; Pkg.activate("MLJ_env", shared=true)
	using Test
	using Random
	using PlutoUI
	using Printf
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

	function NaiveBayes(;k::TF=0.5)
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
function probabilities(nb::NaiveBayes, token::String)::Tuple{TF, TF}
	spam = get(nb.token_spam_cnt, token, 0) 
	ham = get(nb.token_ham_cnt, token, 0)
	#
	p_token_spam = (spam + nb.k) / (nb.n_spam_msg + 2. * nb.k)
	p_token_ham = (ham + nb.k) / (nb.n_ham_msg + 2. * nb.k)
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
	for token ∈ nb.tokens
		prob_spam, prob_ham = probabilities(nb, token)
		if token ∈ tokens
			log_prob_spam += log(prob_spam)
			log_prob_ham += log(prob_ham)
		else
			# otherwise add the log probability of _not_ seeing token in message
			log_prob_spam += log(one(TF) - prob_spam)
			log_prob_ham += log(one(TF) - prob_ham)
		end
	end
	prob_spam, prob_ham = exp(log_prob_spam), exp(log_prob_ham)
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
	#
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
	test_text = "hello spam"
	d_s = (1. + 2. * .5)
	probs_spam = [
		(1. + .5) / d_s,       # 'spam' present
		1. - (0. + .5) / d_s,  # 'ham' not present
		1. - (1. + .5) / d_s,  # 'rules' not present
		(0. + .5) / d_s,       # 'hello' present
	]
	d_h = (2. + 2. * .5)
	probs_ham = [
		(0. + .5) / d_h,       # 'spam' present
		1. - (2. + .5) / d_h,  # 'ham' not present
		1. - (1. + .5) / d_h,  # 'rules' not present
		(1. + .5) / d_h,       # 'hello' present
	]
	p_spam = exp(sum(log.(probs_spam)))
	p_ham = exp(sum(log.(probs_ham)))
	#
	@test predict(test_model, test_text) ≈ p_spam / (p_spam + p_ham)
end

# ╔═╡ ab9ac56e-8969-11eb-3340-337957fd81b7
md"""
And next let us try on some real data.
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
### Using our Model

A popular dataset is the SpamAssassin public corpus. We will look at the files prefixed with 20021010.

First let us download and untar the files
"""

# ╔═╡ 073f6442-892e-11eb-0fc2-bbeb1d12619e
begin
	const BASE_URL = "https://spamassassin.apache.org/old/publiccorpus"
	const FILE_SDIRS = [
		("20021010_easy_ham.tar.bz2", "easy_ham"),
		("20021010_hard_ham.tar.bz2", "hard_ham"),
		("20021010_spam.tar.bz2", "spam")
	]
	const OUTPUT_DIR = "./spam_data/"
end

# ╔═╡ 6a454512-89e8-11eb-303a-ad5920ec581d
begin
	prepdir() = !isdir(OUTPUT_DIR) && mkdir(OUTPUT_DIR)

	function download_files()
		for (file, _sdir) ∈ FILE_SDIRS
			fp = string(OUTPUT_DIR, "/", file)
			isfile(fp) && continue
			## Note that this function relies on the availability of external tools
			## such as curl, wget or fetch to download the file and is provided
			## for convenience.
			res = download(string(BASE_URL, "/", file), fp)
		end
	end

	function untar_files()
		"""
		Create 3 subdirs: spam, easy_ham, hard_ham unless already created...
		"""
		for (file, sdir) ∈ FILE_SDIRS
			isdir(sdir) && continue
			cmd = Cmd(`tar xjf $(file)`, ignorestatus=false, detach=false,
				dir=OUTPUT_DIR)
			run(cmd, wait=true)
		end
	end

	function doit()
		prepdir()
		download_files()
		untar_files()
	end
end

# ╔═╡ aa4dae40-89ed-11eb-2cb6-9734911ab226
doit()

# ╔═╡ 2be56d9e-89ee-11eb-0e39-bd2174d78266
md"""
Next we need to load the files and to keep things simple (for now) we will just load the subject of the email...
"""

# ╔═╡ 21668a04-8a02-11eb-07b7-0f83275b0ad6
function cleanup_entry(line::String)::String
	try
	line |>
		s -> replace(s, r"[^\w^\s^']+" => "") |>
		strip |>
		s -> filter(c -> isvalid(c), collect(s)) |>   ## pass invalid char
		join |>                                       ## re-create string
		split |>                                      ## drop word with less...
		a -> filter(s -> 2 < length(s) < 11, a) |>    ## than 2 letters and nore
		#                                             ## than 11 
		a -> filter(s -> !occursin(r"\d+", s), a) |>  ## drop word with digit
		a -> join(a, " ") |>
		strip

	catch
		@warn "problem with line: <$(line)>"
		return ""
	end
end

# ╔═╡ aa3808b2-8a0e-11eb-32e8-e70ec61b55c7
function load_data()
	"""
	Select only the Subject line from the message 
	"""
	data = Vector{Message}()
	for (root, dirs, files) ∈ walkdir(OUTPUT_DIR;
		topdown=true, follow_symlinks=false)

		for file in files
			fp = joinpath(root, file)
			is_spam = occursin(r"ham", fp)

			open(fp) do fh
				for line ∈ readlines(fh)
					!occursin(r"\ASubject:", line) && continue
					subject = replace(line, "Subject: " => "") |>
						cleanup_entry
					push!(data, Message(string(subject); is_spam))
					break  # we are done, next
				end
			end
		end
	end
	data
end

# ╔═╡ 2bcd8a62-89ee-11eb-0575-dfa083fc40d6
function load_full_data()
	"""
	Select Subject and Body from the message
	Body appears after Subject + 1 empty line
	"""
	data = Vector{Message}()
	for (root, dirs, files) ∈ walkdir(OUTPUT_DIR;
		topdown=true, follow_symlinks=false)

		for file in files
			fp = joinpath(root, file)
			is_spam = occursin(r"ham", fp)
			found_subject = false
			body, subject = "", ""

			open(fp) do fh
				for line ∈ readlines(fh)
					# 78line = strip(line)
					if occursin(r"\ASubject:", line)
						subject = replace(line, "Subject: " => "") |>
							cleanup_entry
						found_subject = true
					elseif length(line) == 0
						continue
					elseif found_subject
						# cumulate cleaned up line found in body
						body = string(body, " ", cleanup_entry(line))
					end
				end
			end
			# finally make up full message as subject + body
			msg = string(subject, " ", body)
			push!(data, Message(msg; is_spam))
		end
	end
	data
end

# ╔═╡ 2bb0e580-89ee-11eb-24ae-a3947d35f204
begin
	data = load_full_data()
	length(data), data
end

# ╔═╡ 2b949b4e-89ee-11eb-0efa-9bcde1769743
function train_test_split(ds::Vector{Message};
                split=0.8, seed=42, shuffled=true)
	Random.seed!(seed)
	nr = length(ds)
	row_ixes = shuffled ? shuffle(1:nr) : collect(1:nr)
	nrp = round(Int, length(row_ixes) * split)
	(ds[row_ixes[1:nrp]], ds[row_ixes[nrp+1:nr]])
end

# ╔═╡ 347e75f2-89f5-11eb-2a08-d9b2bdda1511
begin
	train_messages, test_messages = train_test_split(data; split=0.75)
	model = NaiveBayes()
	train(model, train_messages)
	#
	length(train_messages), length(test_messages)
end

# ╔═╡ 5bcb82ee-89fa-11eb-36d7-c5668ac807d5
ŷ = [(msg, predict(model, msg.text)) for msg in test_messages]

# ╔═╡ 82175c86-89fa-11eb-1703-b5665587eedb
begin
	function confusion_matrix(ŷ)
		# Assume that spam_probability > 0.5 corresponds to spam prediction
		# and count the combinations of (actual is_spam, predicted is_spam)
		conf_matrix = Dict{Tuple{Bool, Bool}, Integer}()
		for (msg, spam_prob) ∈ ŷ
			#          real label   pred
			keypair = (msg.is_spam, spam_prob > 0.5)
			conf_matrix[keypair] = get(conf_matrix, keypair, 0) + 1
		end
		conf_matrix
	end

	tp(cm) = cm[(true, true)]     # True Positive
	tn(cm) = cm[(false, false)]   # True Negative
	fp(cm) = cm[(false, true)]    # False Positive
	fn(cm) = cm[(true, false)]    # False Negative

	function precision(cm)
		tp_, fp_ = tp(cm), fp(cm)
		tp_ / (tp_ + fp_)
	end

	function recall(cm)
		tp_, fn_ = tp(cm), fn(cm)
		tp_ / (tp_ + fn_)
	end

	function accuracy(cm)
		"""correct predictions / total predictions"""
		tp_, tn_ = tp(cm), tn(cm)
		fp_, fn_ = fp(cm), fn(cm)
		(tp_ + tn_) / (tp_ + fp_ + tn_ + fn_)
	end

	function error_rate(cm)
		1. - accuracy(cm) 
	end

	function f₁_score(cm)
		tp_ = tp(cm)
		fp_, fn_ = fp(cm), fn(cm)
		2. * tp_ / (2. * tp_ + fp_ + fn_)
	end
end

# ╔═╡ f8501806-89fe-11eb-1703-b5665587eedb
begin
	cm = confusion_matrix(ŷ)
	@test sum(values(cm)) == length(test_messages)
end

# ╔═╡ 686d2c82-89ff-11eb-322c-e5ef7394e0f4
with_terminal() do
	@printf("tp: %4d / fp: %4d\n", tp(cm), fp(cm))
	@printf("tn: %4d / fn: %4d\n", tn(cm), fn(cm))
end

# ╔═╡ 2760a7e8-89fd-11eb-36d7-c5668ac807d5
(precision=precision(cm), recall=recall(cm), 
	accuracy=accuracy(cm), f₁_score=f₁_score(cm))

# ╔═╡ 68c746b2-8a00-11eb-2762-ef6e77a8f8c3
function p_spam_given_token(model::NaiveBayes, token::String)::Float64
	prob_spam, prob_ham = probabilities(model, token)
	prob_spam / (prob_spam + prob_ham)
end

# ╔═╡ 9ec18d88-8a00-11eb-322c-e5ef7394e0f4
begin
	words = sort(collect(model.tokens), 
		by=t -> p_spam_given_token(model, t), rev=false)

	with_terminal() do
		println("spammiest_words:")
		for w ∈ words[1:10]
			@printf("\t%15s\n", w)
		end

		println("\n\nhammiest_words:")
		for w ∈ words[end-10:end]
			@printf("%15s\n", w)
		end
	end
end

# ╔═╡ 661fff40-8a13-11eb-38c7-e99a5dda7c7a
model.tokens

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
# ╟─ab9ac56e-8969-11eb-3340-337957fd81b7
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╟─5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═6a454512-89e8-11eb-303a-ad5920ec581d
# ╠═aa4dae40-89ed-11eb-2cb6-9734911ab226
# ╟─2be56d9e-89ee-11eb-0e39-bd2174d78266
# ╠═21668a04-8a02-11eb-07b7-0f83275b0ad6
# ╠═aa3808b2-8a0e-11eb-32e8-e70ec61b55c7
# ╠═2bcd8a62-89ee-11eb-0575-dfa083fc40d6
# ╠═2bb0e580-89ee-11eb-24ae-a3947d35f204
# ╠═2b949b4e-89ee-11eb-0efa-9bcde1769743
# ╠═347e75f2-89f5-11eb-2a08-d9b2bdda1511
# ╠═5bcb82ee-89fa-11eb-36d7-c5668ac807d5
# ╠═82175c86-89fa-11eb-1703-b5665587eedb
# ╠═f8501806-89fe-11eb-1703-b5665587eedb
# ╠═686d2c82-89ff-11eb-322c-e5ef7394e0f4
# ╠═2760a7e8-89fd-11eb-36d7-c5668ac807d5
# ╠═68c746b2-8a00-11eb-2762-ef6e77a8f8c3
# ╠═9ec18d88-8a00-11eb-322c-e5ef7394e0f4
# ╠═661fff40-8a13-11eb-38c7-e99a5dda7c7a
