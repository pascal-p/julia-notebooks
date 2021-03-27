### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ de098278-8e74-11eb-13e3-49c1b6e06e7d
using Pkg; Pkg.activate("MLJ_env", shared=true)

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
	using Test
	using Random
	# using Distributions
	using PlutoUI
	using LinearAlgebra
	# using Plots
	# using Flux.Data.MNIST
	# using Images
end

# ╔═╡ 8c80e072-8b59-11eb-3c21-a18fe43c4536
md"""
## Recommender Systems

ref. from book **"Data Science from Scratch"**, Chap 23
"""

# ╔═╡ e7373726-8b59-11eb-2a2b-b5138e4f5268
html"""
<a id='toc'></a>
"""

# ╔═╡ f5ee64b2-8b59-11eb-2751-0778efd589cd
md"""
#### TOC
  - [Recommending What is Popular](#recom-whats-popular)
  - [User-Based Collaborative Filtering](#user-based-collaborative-filtering)
  - [Item-Based Collaborative Filtering](#item-based-collaborative-filtering)
"""

# ╔═╡ 81290d1c-8ce2-11eb-3340-337957fd81b7
html"""
<p style="text-align: right;">
  <a id='recom-whats-popular'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 8ff1bb20-8ce2-11eb-1de6-fd84daec8930
md"""
#### Recommending What is Popular
"""

# ╔═╡ d3ee2138-8ce2-11eb-0b29-659a3be01512
const Users_Interests = [
    ["Hadoop", "Big Data", "HBase", "Java", "Spark", "Storm", "Cassandra"],
    ["NoSQL", "MongoDB", "Cassandra", "HBase", "Postgres"],
    ["Python", "scikit-learn", "scipy", "numpy", "statsmodels", "pandas"],
    ["R", "Python", "statistics", "regression", "probability"],
    ["machine learning", "regression", "decision trees", "libsvm"],
    ["Python", "R", "Java", "C++", "Haskell", "programming languages"],
    ["statistics", "probability", "mathematics", "theory"],
    ["machine learning", "scikit-learn", "Mahout", "neural networks"],
    ["neural networks", "deep learning", "Big Data", "artificial intelligence"],
    ["Hadoop", "Java", "MapReduce", "Big Data"],
    ["statistics", "R", "statsmodels"],
    ["C++", "deep learning", "artificial intelligence", "probability"],
    ["pandas", "R", "Python"],
    ["databases", "HBase", "Postgres", "MySQL", "MongoDB"],
    ["libsvm", "regression", "support vector machines"]
]

# ╔═╡ 0fcb268a-8ea8-11eb-309c-ef92de740db2
length(Users_Interests)

# ╔═╡ 51cc0044-8e95-11eb-1d0b-e7e3e537710c
begin
	const VVS = Vector{Vector{S}} where S <: AbstractString
	const VVF = Vector{Vector{Float64}}
	const VS = Vector{String}
	const VP = Vector{Pair{String, Integer}} 
	const VT_IF = Vector{Tuple{Integer, Float64}}
	const DSI = Dict{String, Integer}
	const AVT = AbstractArray{T, N} where {T <: Any, N}
end

# ╔═╡ 13a0940e-8ce4-11eb-231c-f331a607203c
function gen_popular_interests(ds::VVS)::DSI
  count_word = Dict{String, Integer}()
  for ui_s ∈ ds, w ∈ ui_s
    count_word[w] = get(count_word, w, 0) + 1
  end
  count_word
end

# ╔═╡ 6b5de662-8e95-11eb-1054-5144e8e0d5db
function most_popular_new_interests(ui::VS, pi::DSI; max_res=5)::VP
	suggestions = filter(((i, _f)=t) -> i ∉ ui, 
		sort(collect(pi), by=t -> t[2], rev=true)
	)[1:max_res]
end

# ╔═╡ 19a89dd2-8eac-11eb-2faa-375f52037a94
pop_interests = gen_popular_interests(Users_Interests)

# ╔═╡ f9716ebe-8e96-11eb-1f7f-9f61e16a374b
typeof(Users_Interests)

# ╔═╡ 12d52658-8e9b-11eb-1825-870032e6ad57
md"""
If you are user 2 (`Users_Interests[2]`) we recommend:
`[("R" => 4), ("Python" => 4), ("Java" => 3), ("Big Data" => 3), ("statistics" => 3)]`: 
"""

# ╔═╡ 930441a6-8e96-11eb-1374-7b8b4b5199af
begin
	@test most_popular_new_interests(Users_Interests[2], pop_interests) == [
		("R" => 4), ("Python" => 4), ("Java" => 3), ("Big Data" => 3), 
		("statistics" => 3)
	]
end

# ╔═╡ ee423fb0-8e9a-11eb-161a-3f3ba95287de
md"""
If you are user 4, who is already interested in many of those things, you would get instead `[("HBase" => 3), ("Java" => 3), ("Big Data" => 3), ("Hadoop" => 2),  ("statsmodels" => 2)]`:
"""

# ╔═╡ 537f09c6-8e9b-11eb-342c-fdcf36135acf
@test most_popular_new_interests(Users_Interests[4], pop_interests) == [
	("HBase" => 3), ("Java" => 3), ("Big Data" => 3), ("Hadoop" => 2), 
	("statsmodels" => 2)
]

# ╔═╡ 80ddf0f4-8ce2-11eb-3046-331119a0dc9b
html"""
<p style="text-align: right;">
  <a id='user-based-collaborative-filtering'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 80a71408-8ce2-11eb-3978-75a4a2df9116
md"""
#### User-Based Collaborative Filtering

One way of taking a user’s interests into account is to look for users who
are somehow similar to him/her, and then suggest the things that those users are
interested in.

In order to do that we need to measure how similar two users are and for this we need a "distance". A typical one for this case is the cosine distance. 
To apply it, we will binary encode the user preference's vector. With this encoding, similar user (which means users with vectors pointing nearly in the same direction of the feature space) will have a similarity close to 1. Conversely, very dissimilar users will a similarity  of 0. Otherwise the similarity will fall between 0 and 1.

To achieve this, let us start collecting the known (unique) interests. 
"""

# ╔═╡ d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
const Uniq_Interests = Iterators.flatten(Users_Interests) |>
	collect |>
	sort |>
	unique;

# ╔═╡ 1ede2ea4-8ea0-11eb-3cb2-6f9f009cc47c
@test Uniq_Interests[1:6] == String["Big Data", "C++", "Cassandra", "HBase", "Hadoop", "Haskell"]

# ╔═╡ 2b256fe4-8ead-11eb-094e-319b84541a47
length(Uniq_Interests), length(Users_Interests)

# ╔═╡ d2b198b6-8ce2-11eb-170e-0f17904c9f2c
begin
	
function gen_binary_vect(user_int::VS, uniq_int::VS)::BitArray
	v = BitArray(undef, length(uniq_int))
	for (ix, ui) ∈ enumerate(uniq_int)
		v[ix] = ui ∈ user_int ? 1 : 0
	end
	v
end

gen_binary_vect(user_int::VVS, uniq_int::VS) = gen_binary_vect.(user_int, uniq_int)

end

# ╔═╡ 5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
## NOTE: we need to prevent broadcasting on the second array => Ref()
const User_Interest_Vect = gen_binary_vect.(Users_Interests, Ref(Uniq_Interests))

# ╔═╡ 1df61abc-8ead-11eb-0613-73865afa45f4
length(User_Interest_Vect[1])

# ╔═╡ 394093fa-8cea-11eb-0071-eff3045a012b
md"""
Now `user_interest_vect[i][j]` is 1 if user i has interest in j and 0 otherwise.

Let us define the cosine similarity:
"""

# ╔═╡ 526acb22-8ea2-11eb-158e-63c3ec6df336
function cosine_similarity(v₁::AVT, v₂::AVT)::Float64 # where {T <: Any}
	dot(v₁, v₂) / (norm(v₁) * norm(v₂))
end

# ╔═╡ 66a3df24-8ea5-11eb-309c-f549d788b65d
begin
	@test cosine_similarity([1., 1, 1], [2., 2, 2]) ≈ 1. ## "same direction"
	@test cosine_similarity([-1., -1], [2., 2]) ≈ -1.    ## "opposite direction"
	@test cosine_similarity([1., 0], [0., 1]) ≈ 0.       ## "orthogonal"
end

# ╔═╡ 1a305bc2-8ea3-11eb-128a-27139da33ae3
md"""
Because we have a small dataset, it is not a problem to compute the pairwise
similarities between all of our users (*it is symetric*) :
"""

# ╔═╡ 435c4444-8dfd-11eb-24e8-5543f905f199
# user_similarities = [
# 	[cosine_similarity(u_i, u_j) for (i, u_i) ∈ enumerate(user_interest_vect)
# 			for (j, u_j) ∈ enumerate(user_interest_vect) if j > i]
# ]

User_Similarities = [
	[cosine_similarity(u_i, u_j) for u_i ∈ User_Interest_Vect]
			for u_j ∈ User_Interest_Vect
]

# ╔═╡ 1ab295c8-8ea4-11eb-166c-8de4f02f0fce
md"""
`user_similarities[i][j]` gives us the similarity between users i and j (i < j)
"""

# ╔═╡ 7365ac88-8eaa-11eb-04da-0ff2fe7e8361
typeof(User_Similarities)

# ╔═╡ e95983ba-8ceb-11eb-38fd-ed92cdcf754c
## Users 1 and 10 share interests in Hadoop, Java, and Big Data
@test 0.56 ≤ User_Similarities[1][10] ≤ 0.58  ## several shared interests

## @test 0.56 ≤ user_similarities[1][9] ≤ 0.58  ## several shared interests

# ╔═╡ 88c98664-8ea6-11eb-1f63-abf82c75db63
## Users 1 and 9 share only one interest: Big Data
@test 0.18 ≤ User_Similarities[1][9] ≤ 0.20  ## "only one shared interest"

## @test 0.18 ≤ user_similarities[1][8] ≤ 0.20  ## "only one shared interest"

# ╔═╡ d3a749a2-8cec-11eb-1f06-b568f244b576
md"""
In particular, `user_similarities[i]` is the vector of user i’s similarities
to every other user. We can use this to write a function that finds the most
similar users to a given user (avoiding including the user himself/herself,
nor any users with zero similarity). Then we will sort the results from most
similar to least similar:
"""

# ╔═╡ 31d3226a-8cf4-11eb-0897-39989ba76b58
function most_similar_users(user_simil::VVF, user_id::Integer)::VT_IF
	type_ = eltype(user_simil[user_id])
	filter(
		((uid, sim)=t) -> uid ≠ user_id && sim > zero(type_),
		collect(enumerate(user_simil[user_id]))
	) |> a -> sort(a, by=t -> t[end], rev=true)
end

# ╔═╡ c99f7c3c-8eaa-11eb-0d3c-8def70eef326
most_similar_users(User_Similarities, 1)

# ╔═╡ 683fb19e-8eaf-11eb-1bed-67aa24fcd830
typeof(most_similar_users(User_Similarities, 1))

# ╔═╡ 6e7e7896-8cf8-11eb-062e-99492ec8cff8
md"""
How do we use this to suggest new interests to a user?

For each interest we can add up the user similarities of the other iuser interested in it:
"""

# ╔═╡ 70d84470-8cf6-11eb-23b6-c7ba506d8552
function user_based_suggestions(user_id::Integer, user_simil, user_inter::VVS; 
		incl_curr_interests=false)
	#
	suggs = Dict{String, Float64}()
	for (o_uid, simil) ∈ most_similar_users(user_simil, user_id), 
		inter ∈ user_inter[o_uid]
		suggs[inter] = get(suggs, inter, 0.) + simil
	end
	
	suggs = sort(collect(suggs), by=t -> t[end], rev=true)  ## Vector of pairs
	
	incl_curr_interests && (return suggs)
	
	[(sugg, w) for (sugg, w) ∈ suggs if sugg ∉ user_inter[user_id]]
end

# ╔═╡ c451451a-8cf7-11eb-183b-e358c9d618e0
user_based_suggestions(1, User_Similarities, Users_Interests)

# ╔═╡ ebd531e6-8cf7-11eb-228f-d530e7a48151
md"""
This seems to make sense for someone whose stated interests are "Big Data" and database related.

Note however that this approach does not scale well and in large dimensional vector spaces, vectors are far apart.  
"""

# ╔═╡ 6f3fc602-8ed5-11eb-050b-977276cabfee
html"""
<p style="text-align: right;">
  <a id='item-based-collaborative-filtering'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 6f006b24-8ed5-11eb-11d5-c32ce953dcaf
md"""
#### Item-Based Collaborative Filtering
An alternative approach is to compute similarities between interests directly. We can then generate suggestions for each user by aggregating interests that are similar to his/her current interests.

First let us transpose our user_interest_vect (a list of column vector) into a matrix of row vector.
"""

# ╔═╡ 30bdc788-8d01-11eb-2f8f-9fd79593ddb8
size(User_Interest_Vect), typeof(User_Interest_Vect)

# ╔═╡ 6f36902c-8ed6-11eb-08c4-d545f9adab62
const Interest_User_Matrix = hcat.(User_Interest_Vect...)

# ╔═╡ df8f698e-8ed6-11eb-12c9-3b495c1356f3
size(Interest_User_Matrix)

# ╔═╡ eb391ec2-8ed6-11eb-306b-0d5c56ef4063
@test Interest_User_Matrix[1] == [1 0 0 0 0 0 0 0 1 1 0 0 0 0 0]

## user 1, 9 and 10 indicated their interest in Big Data

# ╔═╡ 84946000-8d02-11eb-3160-571efee8fb0b
md"""
With this we can now use the cosine similarity again. If same users are interested in two topics, their similarity will be 1 and conversely when two users are interested in different topices tehir similarity will be 0.
"""

# ╔═╡ bdf358d8-8ed8-11eb-263e-d9adffd4a1db
const Interest_Similarities = [
	[cosine_similarity(uvectᵢ, uvectⱼ) for uvectⱼ ∈ Interest_User_Matrix]
	for uvectᵢ ∈ Interest_User_Matrix
]

# ╔═╡ d05f1c40-8d17-11eb-2724-4d989c4c6b92
function most_similar_interests(inter_id::Integer, inter_similarities::VVF,
		uniq_inters)
	simils = inter_similarities[inter_id]
	
	[(uniq_inters[o_inter_id], sim) for (o_inter_id, sim) ∈ enumerate(simils) 
	 		if inter_id ≠ o_inter_id && sim > 0.] |>
	pairs -> sort(pairs, by=pair -> pair[end], rev=true)
end

# ╔═╡ 70b220c4-8edb-11eb-0db8-97a36ff4675b
md"""
We can, for example, find the interests most similar to "big Data" (interest 1) using  the following, which suggest these similar interests:
"""

# ╔═╡ 848fd812-8d02-11eb-01d6-75965b08bcc5
msit1 = most_similar_interests(1, Interest_Similarities, Uniq_Interests)

# ╔═╡ 7d35f85e-8e07-11eb-228c-81d28a444b52
begin
	@test msit1[1][1] == "Hadoop"
	@test 0.815 < msit1[1][2] < 0.817
	@test msit1[2][1] == "Java"
	@test 0.666 < msit1[2][2] < 0.667
end

# ╔═╡ 6e7c18b4-8e09-11eb-0238-2515d39a89cd
md"""
Thus now we can create recommendations for a user by summing up the similarities of the interests similar to his/her. 
"""

# ╔═╡ 80dff352-8d02-11eb-06b1-5f5e325046f5
function item_based_suggestions(user_id::Integer, user_inter_vect, users_inter,
		inter_similarities::VVF, uniq_inters;
		incl_curr_interests=false)
	#
	suggs = Dict{String, Float64}()
	user_inter_v = user_inter_vect[user_id]
	for (inter_id, is_inter) ∈ enumerate(user_inter_v)
		if is_inter == 1
			similar_inters = most_similar_interests(inter_id, inter_similarities, 
				uniq_inters)
			for (inter, sim) ∈ similar_inters
				suggs[inter] = get(suggs, inter, 0.) + sim
			end
		end
	end
	# sort...
	suggs = collect(suggs) |>
		p -> sort(p, by=pair -> pair[end], rev=true)
	#
	incl_curr_interests && (return suggs)
	[(sugg, w) for (sugg, w) ∈ suggs if sugg ∉ users_inter[user_id]]
end

# ╔═╡ 34811c32-8edd-11eb-0018-e73666ea7667
ibs1 = item_based_suggestions(1, User_Interest_Vect, Users_Interests, 
	Interest_Similarities, Uniq_Interests)

# ╔═╡ d878e9b6-8edd-11eb-03ab-f3a908ee47fe
begin
	@test ibs1[1][1] == "MapReduce"
	@test 1.86 < ibs1[1][2] < 1.87

	@test ibs1[2][1] ∈ ("Postgres", "MongoDB")  # A tie
	@test 1.31 < ibs1[2][2] < 1.32
end

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═de098278-8e74-11eb-13e3-49c1b6e06e7d
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╠═f5ee64b2-8b59-11eb-2751-0778efd589cd
# ╟─81290d1c-8ce2-11eb-3340-337957fd81b7
# ╟─8ff1bb20-8ce2-11eb-1de6-fd84daec8930
# ╠═d3ee2138-8ce2-11eb-0b29-659a3be01512
# ╠═0fcb268a-8ea8-11eb-309c-ef92de740db2
# ╠═51cc0044-8e95-11eb-1d0b-e7e3e537710c
# ╠═13a0940e-8ce4-11eb-231c-f331a607203c
# ╠═6b5de662-8e95-11eb-1054-5144e8e0d5db
# ╠═19a89dd2-8eac-11eb-2faa-375f52037a94
# ╠═f9716ebe-8e96-11eb-1f7f-9f61e16a374b
# ╟─12d52658-8e9b-11eb-1825-870032e6ad57
# ╠═930441a6-8e96-11eb-1374-7b8b4b5199af
# ╟─ee423fb0-8e9a-11eb-161a-3f3ba95287de
# ╠═537f09c6-8e9b-11eb-342c-fdcf36135acf
# ╟─80ddf0f4-8ce2-11eb-3046-331119a0dc9b
# ╟─80a71408-8ce2-11eb-3978-75a4a2df9116
# ╠═d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
# ╠═1ede2ea4-8ea0-11eb-3cb2-6f9f009cc47c
# ╠═2b256fe4-8ead-11eb-094e-319b84541a47
# ╠═d2b198b6-8ce2-11eb-170e-0f17904c9f2c
# ╠═5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
# ╠═1df61abc-8ead-11eb-0613-73865afa45f4
# ╟─394093fa-8cea-11eb-0071-eff3045a012b
# ╠═526acb22-8ea2-11eb-158e-63c3ec6df336
# ╠═66a3df24-8ea5-11eb-309c-f549d788b65d
# ╟─1a305bc2-8ea3-11eb-128a-27139da33ae3
# ╠═435c4444-8dfd-11eb-24e8-5543f905f199
# ╟─1ab295c8-8ea4-11eb-166c-8de4f02f0fce
# ╠═7365ac88-8eaa-11eb-04da-0ff2fe7e8361
# ╠═e95983ba-8ceb-11eb-38fd-ed92cdcf754c
# ╠═88c98664-8ea6-11eb-1f63-abf82c75db63
# ╟─d3a749a2-8cec-11eb-1f06-b568f244b576
# ╠═31d3226a-8cf4-11eb-0897-39989ba76b58
# ╠═c99f7c3c-8eaa-11eb-0d3c-8def70eef326
# ╠═683fb19e-8eaf-11eb-1bed-67aa24fcd830
# ╟─6e7e7896-8cf8-11eb-062e-99492ec8cff8
# ╠═70d84470-8cf6-11eb-23b6-c7ba506d8552
# ╠═c451451a-8cf7-11eb-183b-e358c9d618e0
# ╟─ebd531e6-8cf7-11eb-228f-d530e7a48151
# ╟─6f3fc602-8ed5-11eb-050b-977276cabfee
# ╟─6f006b24-8ed5-11eb-11d5-c32ce953dcaf
# ╠═30bdc788-8d01-11eb-2f8f-9fd79593ddb8
# ╠═6f36902c-8ed6-11eb-08c4-d545f9adab62
# ╠═df8f698e-8ed6-11eb-12c9-3b495c1356f3
# ╠═eb391ec2-8ed6-11eb-306b-0d5c56ef4063
# ╟─84946000-8d02-11eb-3160-571efee8fb0b
# ╠═bdf358d8-8ed8-11eb-263e-d9adffd4a1db
# ╠═d05f1c40-8d17-11eb-2724-4d989c4c6b92
# ╟─70b220c4-8edb-11eb-0db8-97a36ff4675b
# ╠═848fd812-8d02-11eb-01d6-75965b08bcc5
# ╠═7d35f85e-8e07-11eb-228c-81d28a444b52
# ╟─6e7c18b4-8e09-11eb-0238-2515d39a89cd
# ╠═80dff352-8d02-11eb-06b1-5f5e325046f5
# ╠═34811c32-8edd-11eb-0018-e73666ea7667
# ╠═d878e9b6-8edd-11eb-03ab-f3a908ee47fe
