### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ a5df7598-814e-11eb-03c8-b1450e513104
begin
	using Plots
    using Test
	using LinearAlgebra
end

# ╔═╡ 36396ea6-814e-11eb-0d9a-9b4ac175c109
md"""
## 01 - Statistics

ref. from book "Data Science from Scratch", Chap 5


"""

# ╔═╡ accc7d4e-815b-11eb-03e6-053884a6d2f2
md"""
One obvious description of any dataset is simply the data itself:
"""

# ╔═╡ a5b5ebba-814e-11eb-3945-7d6d1fc6aa1f
begin
	const num_friends = Float64[100.0, 49, 41, 40, 25, 21, 21, 19, 19, 18, 18, 16, 15, 15, 15, 15, 14, 14, 13, 13, 13, 13, 12, 12, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	
	const daily_minutes = Float64[1, 68.77, 51.25, 52.08, 38.36, 44.54, 57.13, 51.4, 41.42, 31.22, 34.76, 54.01, 38.79, 47.59, 49.1, 27.66, 41.03, 36.73, 48.65, 28.12, 46.62, 35.57, 32.98, 35, 26.07, 23.77, 39.73, 40.57, 31.65, 31.21, 36.32, 20.45, 21.93, 26.02, 27.34, 23.49, 46.94, 30.5, 33.8, 24.23, 21.4, 27.94, 32.24, 40.57, 25.07, 19.42, 22.39, 18.42, 46.96, 23.72, 26.41, 26.97, 36.76, 40.32, 35.02, 29.47, 30.2, 31, 38.11, 38.18, 36.31, 21.03, 30.86, 36.07, 28.66, 29.08, 37.28, 15.28, 24.17, 22.31, 30.17, 25.53, 19.85, 35.37, 44.6, 17.23, 13.47, 26.33, 35.02, 32.09, 24.81, 19.33, 28.77, 24.26, 31.98, 25.73, 24.86, 16.28, 34.51, 15.23, 39.72, 40.8, 26.06, 35.76, 34.76, 16.13, 44.04, 18.03, 19.65, 32.62, 35.59, 39.43, 14.18, 35.24, 40.13, 41.82, 35.45, 36.07, 43.67, 24.61, 20.9, 21.9, 18.79, 27.61, 27.21, 26.61, 29.77, 20.59, 27.53, 13.82, 33.2, 25, 33.1, 36.65, 18.63, 14.87, 22.2, 36.81, 25.53, 24.62, 26.25, 18.21, 28.08, 19.42, 29.79, 32.8, 35.99, 28.32, 27.79, 35.88, 29.06, 36.28, 14.1, 36.63, 37.49, 26.9, 18.58, 38.48, 24.48, 18.95, 33.55, 14.24, 29.04, 32.51, 25.63, 22.22, 19, 32.73, 15.16, 13.9, 27.2, 32.01, 29.27, 33, 13.74, 20.42, 27.32, 18.23, 35.35, 28.48, 9.08, 24.62, 20.12, 35.26, 19.92, 31.02, 16.49, 12.16, 30.7, 31.22, 34.65, 13.13, 27.51, 33.2, 31.57, 14.1, 33.42, 17.44, 10.12, 24.42, 9.82, 23.39, 30.93, 15.03, 21.67, 31.09, 33.29, 22.61, 26.89, 23.48, 8.38, 27.81, 32.35, 23.84]

	const daily_hours = daily_minutes ./ 60.
end

# ╔═╡ d56f5f5c-816b-11eb-1bf0-bd5824f9bd63
md"""
Let's define some utility functions first
"""

# ╔═╡ 2571eec0-8169-11eb-0532-753688761311
function counter(v::Vector{T})::Dict{Int, Int} where T <: Real
	v_count = Dict{Int, Int}(
		ix => 0 for ix ∈ 1:length(v)
	)
	for v ∈ num_friends
		v_count[Int(v)] += 1 
	end
	v_count
end

# ╔═╡ e7027f4e-816b-11eb-3919-ffd373f70cc5
sum_of_squares(v::Vector{T}) where T <: Real = sum(v .^ 2)

# ╔═╡ ea1008d4-814e-11eb-3556-8b78bb29f962
friends_count = counter(num_friends)

# ╔═╡ 83b0cf5c-814f-11eb-0a3a-9b53f8ea656f
begin
	n = maximum(num_friends) + 1
	xs = collect(1:n)
	ys = [friends_count[ix] for ix ∈ xs]
	
	plot(xs, ys, seriestype = :bar, bins=:scott,
		title="Histogram of Friend Counts",
		lw=1, 
		xlims=(0, n), 
		ylims=(0, 25),
    	xticks = 0:10:n,
		xlabel="# of friends", 
		ylabel="# of people",
		legend=nothing)
end

# ╔═╡ 8265bc76-815b-11eb-1eab-67efd5f15d0e
md"""
Unfortunately, this chart is still too difficult to slip into conversations. So
you start generating some statistics. Probably the simplest statistic is the
number of data points:
"""

# ╔═╡ e89b86b2-815b-11eb-1f9a-7dc9a833233e
num_points = length(num_friends)

# ╔═╡ fd2455a0-815b-11eb-222a-7b19df1c0123
md"""
Then largest and smallest values:
"""

# ╔═╡ 095cc486-815c-11eb-0a10-c16a401a3c03
begin 
	largest_value, smallest_value = maximum(num_friends), minimum(num_friends)
end

# ╔═╡ 27f992c2-815c-11eb-31d0-49d06a6b3d39
md"""
Which are just special cases of wanting to know the values in specific positions:
"""

# ╔═╡ 37c684ee-815c-11eb-0710-273f93e7da14
begin
	sorted_values = sort(num_friends)
	
	second_smallest_value = sorted_values[2]
	second_largest_value = sorted_values[end - 1]
	(second_smallest_value, second_largest_value)
end

# ╔═╡ 72f52228-815c-11eb-135e-cd8437424521
md"""
### General Tendencies

Usually, we will want some notion of where our data is centered. Most commonly we will use the mean (or average), which is just the sum of the data divided by its count:
"""

# ╔═╡ 8dbdd82a-815c-11eb-3cf9-11b411dc5255
function mean(v::Vector{T})::T where T <: Real 
	@assert length(v) > 0
	sum(v) / length(v)
end

# ╔═╡ c1fbc854-815c-11eb-2e11-37a579e958f1
@test mean(num_friends) ≈ 7.333333333333333

# ╔═╡ 16a00e4c-815d-11eb-1785-b965a0359d47
md"""
if you have 10 data points, and you increase the value of any of them by 1, you increase the *mean* by 0.1.
"""

# ╔═╡ 16830248-815d-11eb-118c-c34adc05bdb6
md"""
We will also sometimes be interested in the median, which is the middle-most value (if the number of data points is odd) or the average of the two middle-most values (if the number of data points is even).
"""

# ╔═╡ 166b0b98-815d-11eb-1574-bde5309670cd
function median(v::Vector{T})::T where T <: Real 
	@assert length(v) > 0
	
	n = length(v)
	vₛ = sort(v, rev=false)
 	if isodd(n)
		mix = (1 + n) ÷ 2
		vₛ[mix]
	else
		mix = n ÷ 2
		DT = eltype(vₛ)
		s = vₛ[mix] + vₛ[mix + 1]
		DT <: Integer ? s ÷ DT(2) : s /2.
		# what about Rational and Complex? 
	end
end

# ╔═╡ 164e8f4a-815d-11eb-3ef1-7d670678d772
begin
	@test median([1, 10, 2, 9, 5]) == 5
	@test median([1, 9, 2, 10]) == (2 + 9) ÷ 2
	
	@test median([1., 10., 2., 9., 5.5]) == 5.5
	@test median([1., 9., 2., 10.]) == (2. + 9.) / 2.
	
	@test median(num_friends) == 6.0
end

# ╔═╡ 15e97c0e-815d-11eb-2207-ab653fc57612
md"""
Clearly, the mean is simpler to compute, and it varies smoothly as our data changes. If we have n data points and one of them increases by some small amount e, then necessarily the mean will increase by e / n. (This makes the mean amenable to all sorts of calculus tricks.) 

In order to find the median, however, we have to sort our data (although there are some more efficient technique like binary heap...). And changing one of our data points by a small amount e might increase the median by e, by some number less than e, or not at all (depending on the rest of the data).

However the mean is very sensitive to outliers in our data. If our friendliest user had 200 friends (instead of 100), then the mean would rise to 7.82, while the median would stay the same. 
If outliers are likely to be bad data (or otherwise unrepresentative of whatever phenomenon we’re trying to understand), then the mean can sometimes give us a misleading picture.

A generalization of the median is the quantile, which represents the value under which a certain percentile of the data lies (the median represents the value under which 50% of the data lies):
"""

# ╔═╡ 49a1b4a0-8160-11eb-38e3-8dd705fbb346
function quantile(v::Vector{T}, p::T)::T where T <: Real 
	"""Returns the pth-percentile value in x"""
	pix = floor(Int64, p * length(v))
	sort(v, rev=false)[pix]
end

# ╔═╡ 4982ff74-8160-11eb-335d-cd2773020748
begin
	@test quantile(num_friends, 0.10) == 1.
	@test quantile(num_friends, 0.25) == 3.
	@test quantile(num_friends, 0.5) == median(num_friends)
	@test quantile(num_friends, 0.75) == 9.
	@test quantile(num_friends, 0.90) == 13.
end

# ╔═╡ 4969769e-8160-11eb-3fa9-4782c4d63ac0
md"""
You might want to look at the mode, or most common value(s):
"""

# ╔═╡ ad124582-8169-11eb-2a3e-f7060063b756
max([1, 2, 2, 3, 3, 4, 5, 6, 6, 7, 6, 3]...)

# ╔═╡ 4935696c-8160-11eb-07ef-059b429dbc9a
function mode(v::Vector{T})::Vector{T} where T <: Real 
	"""
	Returns a list, since there might be more than one mode
	"""
	counts = counter(v)
	max_cnt = values(counts) |> maximum
	[x_i for (x_i, cnt) ∈ counts if cnt == max_cnt]
end

# ╔═╡ d6beae9c-816a-11eb-05fa-092969ea79fd
@test mode(num_friends) == Float64[1.0, 6.0]

# ╔═╡ 3c8002a8-816b-11eb-2697-6356a438995d
md"""
#### Dispersion

Dispersion refers to measures of how spread out our data is. Typically they are statistics for which values near zero signify not spread out at all and for which large values (whatever that means) signify very spread out. 

For instance, a very simple measure is the range, which is just the difference
between the largest and smallest elements:
"""

# ╔═╡ 3c636418-816b-11eb-2e8d-23bddb884230
range(v::Vector{T}) where T <: Real = maximum(v) - minimum(v)

# ╔═╡ 3c4a8c9a-816b-11eb-24b8-430fadbee06c
@test range(num_friends) == 99

# ╔═╡ af74654c-816b-11eb-156c-a343acaed426
md"""
The range is zero precisely when the max and min are equal, which can only happen if the elements of x are all the same, which means the data is not dispersed at all. Conversely, if the range is large, then the max is much larger than the min and the data is more spread out.

Like the median, the range doesn’t really depend on the whole dataset. A dataset whose points are all either 0 or 100 has the same range as a dataset whose values are 0, 100, and lots of 50s. But it seems like the first dataset “should” be more spread out.
"""

# ╔═╡ af5a0c38-816b-11eb-148b-b5964037cba3
function de_mean(v::Vector{T})::Vector{T} where T <: Real 
	"""
	Translate v by subtracting its mean (so the result has mean 0)
	"""
	v̄ = mean(v)
	v .- v̄
end

# ╔═╡ af3b67a6-816b-11eb-360c-e5668c8ac456
function variance(v::Vector{T})::T where T <: Real 
	"""
	Almost the average squared deviation from the mean
	almost because we use n - 1, to get an unbiased estimate
	"""
	@assert length(v) ≥ 2 "variance requires at least two elements"
	n = length(v)
	dev = de_mean(v)
	sum_of_squares(dev) / (n - 1)
end

# ╔═╡ 1991ce0a-816d-11eb-3b8f-0fdf9c863bf6
md"""
Now, whatever units our data is in (e.g., “friends”), all of our measures of central tendency are in that same unit. The range will similarly be in that same unit. The variance, on the other hand, has units that are the square of the original units (e.g., “friends squared”). As it can be hard to make sense of these, we often look instead at the *standard deviation*, usually denoted as σ:
"""

# ╔═╡ 28e61e86-816d-11eb-198a-8f9df29bf4d5
σ(v::Vector{T}) where T <: Real = √(variance(v))

# ╔═╡ 3c2e2d48-816b-11eb-347f-4564c2ab7d11
@test 81.54 < σ(num_friends) < 81.55

# ╔═╡ 28d4fd42-816d-11eb-3ffc-d753aca1fae0
@test 9.02 < σ(num_friends) < 9.04

# ╔═╡ 28ba2e5e-816d-11eb-09a4-35e5a7314a2e
md"""
Both the range and the standard deviation have the same outlier problem that we saw earlier for the mean. Using the same example, if our friendliest user had instead 200 friends, the standard deviation would be 14.89 — more than 60% higher!

A more robust alternative computes the difference between the 75th percentile value and the 25th percentile value:
"""

# ╔═╡ 289f7136-816d-11eb-3b5c-e917eef9e556
function interquartile_range(v::Vector{T})::T where T <: Real
	"""
	Returns the difference between the 75%-ile and the 25%-ile
	"""
	quantile(v, 0.75) - quantile(v, 0.25)
end

# ╔═╡ 2885d1fe-816d-11eb-0845-8d7c3aa1e1ba
@test interquartile_range(num_friends) == 6.

# ╔═╡ 285912ac-816d-11eb-1359-d5ee97622b95
md"""
#### Correlation

We’ll first look at covariance, the paired analogue of variance. Whereas variance measures how a single variable deviates from its mean, covariance measures how two variables vary in tandem from their means:
"""

# ╔═╡ 2e768c6a-816e-11eb-303a-f9c19225cadc
function covariance(v₁::Vector{T}, v₂::Vector{T})::T where T <: Real
	@assert length(v₁) == length(v₂) "v₁ and v₂ must have same number of elements"
	dot(de_mean(v₁), de_mean(v₂)) / (length(v₁) - 1)
end

# ╔═╡ 2e5a7f2a-816e-11eb-157b-212c9167835d
begin
	@test  22.42 < covariance(num_friends, daily_minutes) < 22.43
	@test  22.42 / 60. < covariance(num_friends, daily_hours) < 22.43 / 60
end

# ╔═╡ 2e40e5ba-816e-11eb-38ed-6758053c18da
md"""
Because this number can be hard to interpret, it’s more common to look at the correlation, which divides out the standard deviations of both variables:
"""

# ╔═╡ 2e18ae10-816e-11eb-378e-db14eec0a669
function correlation(v₁::Vector{T}, v₂::Vector{T})::T where T <: Real
	"""
	Measures how much v₁ and v₂ vary in tandem about their means
	"""
	σ₁, σ₂ = σ(v₁), σ(v₂)
	
	σ₁ > zero(T) && σ₂ >zero(T) ? covariance(v₁, v₂) / σ₁ / σ₂ : 
		zerot(T)  ## if no variation, correlation is zero
end

# ╔═╡ 2de6a9ce-816e-11eb-2787-6950d6475db8
begin
	@test 0.24 < correlation(num_friends, daily_minutes) < 0.25
	@test 0.24 < correlation(num_friends, daily_hours) < 0.25
end

# ╔═╡ 5a29723c-8170-11eb-08a9-71ec55858cc0
plot(num_friends, daily_minutes, seriestype = :scatter, 
	title="Correlation with outlier", lw=1, 
	xlims=(0, n), ylims=(0, n), xticks = 0:10:n,
	xlabel="# of friends", 
	ylabel="minutes / day",
	legend=nothing)

# ╔═╡ 9c9020e0-8172-11eb-154d-2d7f4d69148c
md"""
The person with 100 friends (who spends only 1 minute per day on the site)
is a huge outlier, and correlation can be very sensitive to outliers. What
happens if we ignore him?
"""

# ╔═╡ 5a0aac6a-8170-11eb-188a-bd76519cf2a5
begin
	outlier_ix = findnext(x -> x == 100, num_friends, 1) # index of outlier
	
	num_friends_good = filter(t -> t[1] ≠ outlier_ix,
		enumerate(num_friends) |> collect
	) |> a -> map(t -> t[2], a)
	
	daily_minutes_good =  filter(t -> t[1] ≠ outlier_ix,
		enumerate(daily_minutes) |> collect
	) |> a -> map(t -> t[2], a)
	
	daily_hours_good = daily_minutes_good ./ 60.
end

# ╔═╡ 5014754e-8173-11eb-20ad-83f94f0109ca
begin
	@test 0.57 < correlation(num_friends_good, daily_minutes_good) < 0.58
	@test 0.57 < correlation(num_friends_good, daily_hours_good) < 0.58
end

# ╔═╡ 655d7a4a-8173-11eb-1765-1994d89fcd72
plot(num_friends_good, daily_minutes_good, seriestype = :scatter, 
	title="Correlation after removing the outlier", lw=1, 
	xlims=(0, n ÷ 2), ylims=(0, n), xticks = 0:10:n,
	xlabel="# of friends", 
	ylabel="minutes / day",
	legend=nothing)

# ╔═╡ 8b899ef8-8176-11eb-0d24-3d8972f0e9c4
md"""
Without the outlier, there is a much stronger correlation.
"""

# ╔═╡ Cell order:
# ╟─36396ea6-814e-11eb-0d9a-9b4ac175c109
# ╠═a5df7598-814e-11eb-03c8-b1450e513104
# ╟─accc7d4e-815b-11eb-03e6-053884a6d2f2
# ╠═a5b5ebba-814e-11eb-3945-7d6d1fc6aa1f
# ╟─d56f5f5c-816b-11eb-1bf0-bd5824f9bd63
# ╠═2571eec0-8169-11eb-0532-753688761311
# ╠═e7027f4e-816b-11eb-3919-ffd373f70cc5
# ╠═ea1008d4-814e-11eb-3556-8b78bb29f962
# ╠═83b0cf5c-814f-11eb-0a3a-9b53f8ea656f
# ╟─8265bc76-815b-11eb-1eab-67efd5f15d0e
# ╠═e89b86b2-815b-11eb-1f9a-7dc9a833233e
# ╟─fd2455a0-815b-11eb-222a-7b19df1c0123
# ╠═095cc486-815c-11eb-0a10-c16a401a3c03
# ╟─27f992c2-815c-11eb-31d0-49d06a6b3d39
# ╠═37c684ee-815c-11eb-0710-273f93e7da14
# ╟─72f52228-815c-11eb-135e-cd8437424521
# ╠═8dbdd82a-815c-11eb-3cf9-11b411dc5255
# ╠═c1fbc854-815c-11eb-2e11-37a579e958f1
# ╟─16a00e4c-815d-11eb-1785-b965a0359d47
# ╟─16830248-815d-11eb-118c-c34adc05bdb6
# ╠═166b0b98-815d-11eb-1574-bde5309670cd
# ╠═164e8f4a-815d-11eb-3ef1-7d670678d772
# ╟─15e97c0e-815d-11eb-2207-ab653fc57612
# ╠═49a1b4a0-8160-11eb-38e3-8dd705fbb346
# ╠═4982ff74-8160-11eb-335d-cd2773020748
# ╟─4969769e-8160-11eb-3fa9-4782c4d63ac0
# ╠═ad124582-8169-11eb-2a3e-f7060063b756
# ╠═4935696c-8160-11eb-07ef-059b429dbc9a
# ╠═d6beae9c-816a-11eb-05fa-092969ea79fd
# ╟─3c8002a8-816b-11eb-2697-6356a438995d
# ╠═3c636418-816b-11eb-2e8d-23bddb884230
# ╠═3c4a8c9a-816b-11eb-24b8-430fadbee06c
# ╟─af74654c-816b-11eb-156c-a343acaed426
# ╠═af5a0c38-816b-11eb-148b-b5964037cba3
# ╠═af3b67a6-816b-11eb-360c-e5668c8ac456
# ╠═3c2e2d48-816b-11eb-347f-4564c2ab7d11
# ╟─1991ce0a-816d-11eb-3b8f-0fdf9c863bf6
# ╠═28e61e86-816d-11eb-198a-8f9df29bf4d5
# ╠═28d4fd42-816d-11eb-3ffc-d753aca1fae0
# ╟─28ba2e5e-816d-11eb-09a4-35e5a7314a2e
# ╠═289f7136-816d-11eb-3b5c-e917eef9e556
# ╠═2885d1fe-816d-11eb-0845-8d7c3aa1e1ba
# ╟─285912ac-816d-11eb-1359-d5ee97622b95
# ╠═2e768c6a-816e-11eb-303a-f9c19225cadc
# ╠═2e5a7f2a-816e-11eb-157b-212c9167835d
# ╟─2e40e5ba-816e-11eb-38ed-6758053c18da
# ╠═2e18ae10-816e-11eb-378e-db14eec0a669
# ╠═2de6a9ce-816e-11eb-2787-6950d6475db8
# ╠═5a29723c-8170-11eb-08a9-71ec55858cc0
# ╠═9c9020e0-8172-11eb-154d-2d7f4d69148c
# ╠═5a0aac6a-8170-11eb-188a-bd76519cf2a5
# ╠═5014754e-8173-11eb-20ad-83f94f0109ca
# ╠═655d7a4a-8173-11eb-1765-1994d89fcd72
# ╟─8b899ef8-8176-11eb-0d24-3d8972f0e9c4
