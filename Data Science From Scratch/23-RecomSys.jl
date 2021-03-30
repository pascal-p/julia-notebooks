### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
	using Test
	using Random
	using PlutoUI
	using LinearAlgebra
	using CSV
	using StringEncodings
	using Printf
	using Plots
	
	push!(LOAD_PATH, "./src")
	using YaWorkingData: DT, pca, transform
	using YaDistances: cosine_similarity
end

# ╔═╡ de098278-8e74-11eb-13e3-49c1b6e06e7d
using Pkg; Pkg.activate("MLJ_env", shared=true)

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
  - [Matrix Factorization](#matrix-factorization)
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

Check cosine similarity definition in `YaDistances` module.
"""

# ╔═╡ 526acb22-8ea2-11eb-158e-63c3ec6df336
#function cosine_similarity(v₁::AVT, v₂::AVT)::Float64 # where {T <: Any}
#	dot(v₁, v₂) / (norm(v₁) * norm(v₂))
#end

# ╔═╡ 66a3df24-8ea5-11eb-309c-f549d788b65d
# begin
# 	@test cosine_similarity([1., 1, 1], [2., 2, 2]) ≈ 1. ## "same direction"
# 	@test cosine_similarity([-1., -1], [2., 2]) ≈ -1.    ## "opposite direction"
# 	@test cosine_similarity([1., 0], [0., 1]) ≈ 0.       ## "orthogonal"
# end

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

# ╔═╡ d9e37240-8f31-11eb-1caf-dbbf84b424f0
html"""
<p style="text-align: right;">
  <a id='matrix-factorization'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d962551e-8f31-11eb-3ddf-8bc8b04b3086
md"""
#### Matrix Factorization
"""

# ╔═╡ 1a9f18a4-8f32-11eb-056a-b3ee5e093957
begin
	const MOVIES = "./recommender_data/ml-100k/u.item"
	const RATINGS = "./recommender_data/ml-100k/u.data"
end

# ╔═╡ 1a84db5e-8f32-11eb-2724-23abff284462
struct Rating
	user_id:: String
	movie_id::String
	rating::Float32
end

# ╔═╡ 1a69eff8-8f32-11eb-1513-63f5a01b3ec0
begin
	movies = Dict{String, String}()
	
	for row ∈ CSV.File(open(read, MOVIES, enc"ISO-8859-1"); delim="|")
    	movies[string(row[1])] = row[2]
	end
end

# ╔═╡ d3183c3a-8f38-11eb-21ac-bdb7bb7d21c7
@test length(movies) == 1681

# ╔═╡ 40705800-8f39-11eb-1f91-b3a013911ef8
collect(keys(movies))[1:10]

# ╔═╡ 5f543412-8f39-11eb-3a1f-4d7b9960e772
movies["519"]

# ╔═╡ 1a4d76a0-8f32-11eb-2293-51b004ec835f
begin
	ratings= Rating[]
	
	for row ∈ CSV.File(open(read, RATINGS, enc"ISO-8859-1"); delim="\t")
    	push!(ratings, Rating(string(row[1]), string(row[2]), Float32(row[3])))
	end
end

# ╔═╡ db2dbb10-8f31-11eb-259b-2f0f3ca5a29d
@test length(rating.user_id for rating ∈ ratings) == 99999

# ╔═╡ 7237b428-8f39-11eb-2b91-effb877198e5
##
## Create a dictionary for ratings by movie ids
##
# starwars_ratings = Dict{String, Vector{Float32}}(
# 	movie_id => Float32[] for (movie_id, title) ∈ movies if occursin(r"Star Wars|Empire Strikes|Jedi", title)
# )
starwars_ratings = reduce(
	(hsh, (movie_id, title)=r) -> (
		occursin(r"Star Wars|Empire Strikes|Jedi", title) && 
			(hsh[movie_id] = Float32[]); hsh
		), 
	movies;
	init=Dict{String, Vector{Float32}}()
)

# ╔═╡ 71c9a9fe-8f39-11eb-1d2e-5994b912b366
begin
	## Iterate over ratings, accumulating the Star Wars ones
	for rating ∈ ratings
		rating.movie_id ∈ keys(starwars_ratings) && 
			(push!(starwars_ratings[rating.movie_id], rating.rating))
	end

	## Compute avg rating for each movie
	avg_ratings = [
		(sum(title_ratings) / length(title_ratings), movie_id) 
			for (movie_id, title_ratings) ∈ starwars_ratings
	]

	## then print them in order
	with_terminal() do
		for (avg_rating, movie_id) ∈ sort(avg_ratings, by=t -> t[1], rev=true)
			@printf("%.2f %5s\n", avg_rating, movies[movie_id])
		end
	end
end

# ╔═╡ fb52634a-8f3c-11eb-173f-fdd2dfe5d9d3
md"""
Ok, let us try to come up with a model to predict these ratings. Our first step is to split the ratings data into 3 subsets: train, validation and test
"""

# ╔═╡ f093174a-8f43-11eb-154c-e54e019c2a93
typeof(ratings)

# ╔═╡ 61fb5714-8f3d-11eb-265d-97ac6dc8f150
begin
	Random.seed!(42)
	Random.shuffle!(ratings)
	s₁, s₂ = round(Int, length(ratings) * .7), round(Int, length(ratings) * .05)

	train, valid = ratings[1:s₁], ratings[s₁+1:s₁+1+s₂]
	test = ratings[s₁+2+s₂:end]
	
	length(train), length(valid), length(test)
end

# ╔═╡ 61df4254-8f3d-11eb-1b73-d5045174f781
@test length(train) + length(valid) + length(test) == length(ratings)

# ╔═╡ 3adaca50-8f3f-11eb-2881-a1bc37f221b0
train[1], typeof(train)

# ╔═╡ 61c6f168-8f3d-11eb-311c-47ad4dc9bb5e
md"""
Let us define a baseline model which will predict the average rating. We will use MSE (Mean Squared Error) as our metric and check how the baseline does on our test set.
"""

# ╔═╡ 71ac1ecc-8f39-11eb-0489-7bda4977893d
begin
	bl_avg_ratings = map(row -> row.rating, train) |> 
		sum |> s -> s/length(train)
	
	bl_error = map(row -> (row.rating - bl_avg_ratings) ^ 2, test) |> 
		sum |> s -> s/length(test);
end

# ╔═╡ ea84aeb2-8f3f-11eb-09e2-c7cb101a48d1
@test 1.26 < bl_error < 1.28   ## this is what we hope to beat...

# ╔═╡ ea67ca68-8f3f-11eb-28ce-5b807376fa85
md"""
Given our embeddings, the predicted ratings are given by the matrix product of the user embeddings and the movie embeddings. 
For a given user and movie, that value is just the dot product of the corresponding
embeddings.

Let us start by creating the embeddings. We will represent them as dictionaries
where the keys are IDs and the values are vectors, which will allow us to easily retrieve the embedding for a given ID:
"""

# ╔═╡ 2580fa72-8f40-11eb-1894-8dc53902cff1
begin
	const EMB_DIM = 2

	user_ids = map(r -> r.user_id, ratings) |> unique
	movie_ids = map(r -> r.movie_id, ratings) |> unique

	user_vects = Dict{String, Vector{Float32}}(
		user_id => rand(Float32, EMB_DIM) for user_id ∈ user_ids
	)
	movie_vects = Dict{String, Vector{Float32}}(
		movie_id => rand(Float32, EMB_DIM) for movie_id ∈ movie_ids
	)
end

# ╔═╡ 25666c1c-8f40-11eb-265b-070dc6e71052
md"""
Now, it is time to write our taining loop.
"""

# ╔═╡ 4d52b86a-8f41-11eb-07de-632ac5b2c513
function train_loop(ds::Vector{Rating}, ds_name::Symbol; 
		η::Union{Float32, Nothing}=nothing)
	loss = 0.
	for (ix, rating) ∈ enumerate(ds)
		movie_v = movie_vects[rating.movie_id]
		user_v = user_vects[rating.user_id]
		ŷ = dot(user_v, movie_v)
		err = ŷ - rating.rating
		loss += err ^ 2
		if !isnothing(η)
			## we have ŷ ≡ m₀ × u₀	+ m₁ × u₁ + ... +mₖ × uₖ
			## thus each uⱼ contributes to output with coefficient mⱼ
			## and conv. each mⱼ contributes to output with coefficient uⱼ
			∇user = movie_v * err # [err * mⱼ for mⱼ ∈ movie_v]
			∇movie = user_v * err
			#
			user_v .-= η * ∇user
			movie_v .-= η * ∇movie
		end
		ix % 10_000 == 0 && @printf("\t%5d: avg_loss: %3.6f\n", ix, loss / ix)
	end
	avg_loss = loss / length(ds)
	@printf("\tFinal avg_loss(%12s): %3.6f\n", ds_name, avg_loss)
	avg_loss
end

# ╔═╡ 25489752-8f40-11eb-129b-e52fde513eed
begin
	η = Float32(0.05)
	avg_train_losses, avg_valid_losses = [], [] 
	avg_test_loss = nothing
	
	with_terminal() do
		for epoch ∈ 1:20
			global η *= Float32(0.9)
			@printf("%2d => η: %2.5f", epoch, η)
			#
			avg_train_loss = train_loop(train, :Training; η)
			avg_valid_loss = train_loop(valid, :Validation)
			push!(avg_train_losses, avg_train_loss)
			push!(avg_valid_losses, avg_valid_loss)
		end
		#
		global avg_test_loss = train_loop(test, :Test)
	end
end

# ╔═╡ a1bc5930-8f55-11eb-0fdb-af0f194e92b3
(avg_test_loss=string(round(avg_test_loss * 100., digits=2), "%"),)

# ╔═╡ 27dd9746-8f55-11eb-28a7-d3037bd284e8
begin
	plot(avg_train_losses, title="avg loss/epoch", label="train loss")
	plot!(avg_valid_losses, label="valid loss")
end

# ╔═╡ 46a227c8-8f55-11eb-07f9-f7eaff5b38de
md"""
Now, we will inspect  the learned vectors. Because there is no reason to expect the two components to be particularly meaningful, we are going to use PCA. 
"""

# ╔═╡ f82b1e48-8f71-11eb-1988-c970a4a0a5a3
begin
	orig_vects = values(movie_vects) |> collect
	comps = pca(orig_vects, 2)
end

# ╔═╡ 143bd95e-8f74-11eb-10af-49df13561522
md"""
Let us transform our vectors to represent the principal components and join
in the movie IDs and average ratings:
"""

# ╔═╡ 21dcc152-8f76-11eb-1511-674e702e4072
begin
	ratings_by_movie = Dict{String, DT}()
	for rating in ratings
		id = rating.movie_id
		ary = get(ratings_by_movie, id, DT{Float32}())
		push!(ary, rating.rating)
		ratings_by_movie[id] = ary
	end
	vs = [
		(
			movie_id, 
			sum(ratings_by_movie[movie_id]) / length(ratings_by_movie[movie_id]),
			get(movies, movie_id, "_"),
			vect
		) 
		for (movie_id, vect) ∈ zip(keys(movie_vects), transform(orig_vects, comps))
	]
end


# ╔═╡ f1c75d7c-8f7c-11eb-1e75-dbc0b7d8225d
# top 25 by first principal component
sort(vs, by=t -> t[end][1], rev=true)[1:25]

# ╔═╡ 51e6fadc-8f7d-11eb-1f1f-93756139d30b
# bottom 25 by first principal component
sort(vs, by=t -> t[end][1], rev=false)[1:25]

# ╔═╡ 81cb1cec-8f7d-11eb-0b7d-4f4c7dd01a2c
md"""
The top 25 are all highly rated, while the bottom 25 are *mostly* low-rated (or unrated in the training data), which suggests that the first principal component is mostly capturing “how good is this movie?”

It is hard to make much sense of the second component; and, indeed the 2-dimensional embeddings performed only slightly better than the one-dimensional embeddings, suggesting that whatever the second component captured is possibly very subtle...
"""

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═de098278-8e74-11eb-13e3-49c1b6e06e7d
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╟─f5ee64b2-8b59-11eb-2751-0778efd589cd
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
# ╟─d9e37240-8f31-11eb-1caf-dbbf84b424f0
# ╟─d962551e-8f31-11eb-3ddf-8bc8b04b3086
# ╠═1a9f18a4-8f32-11eb-056a-b3ee5e093957
# ╠═1a84db5e-8f32-11eb-2724-23abff284462
# ╠═1a69eff8-8f32-11eb-1513-63f5a01b3ec0
# ╠═d3183c3a-8f38-11eb-21ac-bdb7bb7d21c7
# ╠═40705800-8f39-11eb-1f91-b3a013911ef8
# ╠═5f543412-8f39-11eb-3a1f-4d7b9960e772
# ╠═1a4d76a0-8f32-11eb-2293-51b004ec835f
# ╠═db2dbb10-8f31-11eb-259b-2f0f3ca5a29d
# ╠═7237b428-8f39-11eb-2b91-effb877198e5
# ╠═71c9a9fe-8f39-11eb-1d2e-5994b912b366
# ╟─fb52634a-8f3c-11eb-173f-fdd2dfe5d9d3
# ╠═f093174a-8f43-11eb-154c-e54e019c2a93
# ╠═61fb5714-8f3d-11eb-265d-97ac6dc8f150
# ╠═61df4254-8f3d-11eb-1b73-d5045174f781
# ╠═3adaca50-8f3f-11eb-2881-a1bc37f221b0
# ╟─61c6f168-8f3d-11eb-311c-47ad4dc9bb5e
# ╠═71ac1ecc-8f39-11eb-0489-7bda4977893d
# ╠═ea84aeb2-8f3f-11eb-09e2-c7cb101a48d1
# ╟─ea67ca68-8f3f-11eb-28ce-5b807376fa85
# ╠═2580fa72-8f40-11eb-1894-8dc53902cff1
# ╟─25666c1c-8f40-11eb-265b-070dc6e71052
# ╠═4d52b86a-8f41-11eb-07de-632ac5b2c513
# ╠═25489752-8f40-11eb-129b-e52fde513eed
# ╠═a1bc5930-8f55-11eb-0fdb-af0f194e92b3
# ╠═27dd9746-8f55-11eb-28a7-d3037bd284e8
# ╟─46a227c8-8f55-11eb-07f9-f7eaff5b38de
# ╠═f82b1e48-8f71-11eb-1988-c970a4a0a5a3
# ╟─143bd95e-8f74-11eb-10af-49df13561522
# ╠═21dcc152-8f76-11eb-1511-674e702e4072
# ╠═f1c75d7c-8f7c-11eb-1e75-dbc0b7d8225d
# ╠═51e6fadc-8f7d-11eb-1f1f-93756139d30b
# ╟─81cb1cec-8f7d-11eb-0b7d-4f4c7dd01a2c
