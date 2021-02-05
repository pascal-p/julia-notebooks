### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 7c7e9c40-6805-11eb-1016-4d344df3bf4b
begin
  using Test
  using BenchmarkTools
	
  using PlutoUI
end

# ╔═╡ ed2b997a-680a-11eb-1ab6-ab8d60e5c570
md"""
### Exploration

Feb 2021
"""

# ╔═╡ 9dd99a26-6804-11eb-0ed2-f919ade51b5d
md"""
Given the triangle of consecutive odd numbers:
```sh
                1
             3      5
           7     9     11
        13    15    17    19
     21    23    25    27     29
  31    33    35    37    39      41 
...
```

Calculate the row sums of this triangle from the row index (starting at index 1) e.g.:

```
row_sum_odd_numbers(1) # 1
row_sum_odd_numbers(2) # 3 + 5 = 8
```

Can we build this triangle?

 - n = 1, [1]  
 - n = 2, [3, 5]                [n+1, n+3] n is even  
 - n = 3, [7, 9, 11]            [n+4, n+6, n+8] n is odd  
 - n = 4, [13, 15, 17, 19]      [n+9, n+11, n+13, n+15] n is even  
 - n = 5, [21, 23, 25, 27, 29]  [n+16, n+18, n+20, n+22, n+24]  
 - n = 6, [31, 33, 35, 37, 39, 41]
 - n = 7, [43, 45, 47, 49, 51, 53 55] 

Notice the upper limit is given by: $n^2 + n-1$ which can be cheked on the follwoing (this is not a demonstration, but one can devise a recurrence)...

- $n = 1 \Rightarrow n^2 + n-1 = 1^2 + 0 = 1$
- $n = 2 \Rightarrow n^2 + n-1 = 2^2 + 1 = 5$
- $n = 3 \Rightarrow n^2 + n-1 = 3^2 + 2 = 11$
- $n = 4 \Rightarrow n^2 + n-1 = 4^2 + 3 = 19$
- $n = 5 \Rightarrow n^2 + n-1 = 5^2 + 4 = 29$
- $n = 6 \Rightarrow n^2 + n-1 = 6^2 + 5 = 41$
- $n = 7 \Rightarrow n^2 + n-1 = 7^2 + 6 = 55$
...


Also notice that the lower bound is then given by formulae: $(n-1)^2 + n-2 + 2 \equiv (n-1)^2 + n$

  - $n = 1 \Rightarrow (n-1)^2 + n = 0 + 1 = 1$
  - $n = 2 \Rightarrow (n-1)^2 + n = 1 + 2 = 3$
  - $n = 3 \Rightarrow (n-1)^2 + n = 4 + 3 = 7$
  - $n = 4 \Rightarrow (n-1)^2 + n = 9 + 4 = 13$
  - $n = 5 \Rightarrow (n-1)^2 + n = 16 + 5 = 21$
...
"""

# ╔═╡ a2253dfa-6805-11eb-14ca-a58592832cdf
"""
Calc. sequence of odd integer from (n-1)^2 + n..n^2 + (n-1) 
"""
function gen_odd_seq(n::T) where T <: Integer
	T[ix for ix in (n-1)^2+n:2:n^2+(n-1)]
end

# type stable - check with @code_warntype

# ╔═╡ 78c6f476-6805-11eb-0e0c-a91004763e37
@code_warntype gen_odd_seq(2)  # check output in console...

# ╔═╡ 682aaed2-6805-11eb-1f27-3524bd18d209
begin
	a = gen_odd_seq(1)
	@test a == [1]
end

# ╔═╡ 15cba046-6806-11eb-20ba-fdf803dbb982
begin
 	a₂ = gen_odd_seq(3);
 	println(a₂)             # output console: [7, 9, 11] 
end

# ╔═╡ 4d965c50-6806-11eb-11cf-63bd5e1cd90e
begin 
 	a₁₀ = gen_odd_seq(10)
	@test a₁₀ == Int[91, 93, 95, 97, 99, 101, 103, 105, 107, 109]
end

# ╔═╡ e77f2c18-6809-11eb-0cd2-51ecbc12c92d
with_terminal() do
	println(length(gen_odd_seq(20)))
end

# ╔═╡ 5a2d25f8-6805-11eb-31d4-13603bb1aecb
Base.return_types(gen_odd_seq, (Int64,))

# ╔═╡ 4d2d7f7e-6805-11eb-036c-17d06e49738a
function row_sum_odd_numbers(n::T) where T <: Integer 
  gen_odd_seq(n) |> ary -> sum(ary)
end

# ╔═╡ 417d8e62-6805-11eb-0543-5f35fdd51d93
begin
	@test row_sum_odd_numbers(1) == 1
	@test row_sum_odd_numbers(2) == 8
	@test row_sum_odd_numbers(42) == 74088
end

# ╔═╡ 340787ba-6805-11eb-1ca4-b3f04158a7d0
with_terminal() do
	@code_warntype row_sum_odd_numbers(5)
end

# ╔═╡ 5991b3f0-6807-11eb-1cda-a58ecc2bfe2f
md"""
## Performance
"""

# ╔═╡ 1afed860-6805-11eb-0856-2f71aa247f42
with_terminal() do
	@btime for i in 1:10_000
    	row_sum_odd_numbers(i)
	end
end

# Note: a lot of allocations!

# ╔═╡ 2424d02a-6808-11eb-345d-4b364881f4fb
# A new version more efficient ? 
function row_sum_odd_numbers_2(n::T) where T <: Integer 
  s = zero(eltype(n))   # pre-alloc
  for ix in (n-1)^2+n:2:n^2+(n-1)
      s += ix
  end
  s    
end

# ╔═╡ 174bd250-6805-11eb-0eba-eb84d09ef7ea
with_terminal() do
	@btime for i in 1:10_000
    	row_sum_odd_numbers_2(i)
	end
end

# Note: faster, still more memory allocations!

# ╔═╡ f00c8acc-6808-11eb-038a-574e118b5025
function alloc_gen_odd_seq_sum(m::T) where T <: Integer
    ary = Vector{T}(undef, m)                        ## Allocate
    
    gen_fn = function (n::T) where T <: Integer      ## Populate
        for (ix, v) ∈ enumerate((n-1)^2+n:2:n^2+(n-1))
            ary[ix] = v
        end 
    end
    
    sum_fn = function (n::T) where T <: Integer      ## Sum...
		gen_fn(n) |> ary -> sum(ary)
	end
	
	sum_fn
end

# ╔═╡ 100fd7d6-6805-11eb-0631-99a070466ac5
with_terminal() do
	@btime for ix in 1:10_000
    	alloc_gen_odd_seq_sum(ix)
	end
end

# ╔═╡ 9e4b2dfc-680a-11eb-26e6-299d32fbb6b0


# ╔═╡ Cell order:
# ╟─ed2b997a-680a-11eb-1ab6-ab8d60e5c570
# ╟─9dd99a26-6804-11eb-0ed2-f919ade51b5d
# ╠═7c7e9c40-6805-11eb-1016-4d344df3bf4b
# ╠═a2253dfa-6805-11eb-14ca-a58592832cdf
# ╠═78c6f476-6805-11eb-0e0c-a91004763e37
# ╠═682aaed2-6805-11eb-1f27-3524bd18d209
# ╠═15cba046-6806-11eb-20ba-fdf803dbb982
# ╠═4d965c50-6806-11eb-11cf-63bd5e1cd90e
# ╠═e77f2c18-6809-11eb-0cd2-51ecbc12c92d
# ╠═5a2d25f8-6805-11eb-31d4-13603bb1aecb
# ╠═4d2d7f7e-6805-11eb-036c-17d06e49738a
# ╠═417d8e62-6805-11eb-0543-5f35fdd51d93
# ╠═340787ba-6805-11eb-1ca4-b3f04158a7d0
# ╟─5991b3f0-6807-11eb-1cda-a58ecc2bfe2f
# ╠═1afed860-6805-11eb-0856-2f71aa247f42
# ╠═2424d02a-6808-11eb-345d-4b364881f4fb
# ╠═174bd250-6805-11eb-0eba-eb84d09ef7ea
# ╠═f00c8acc-6808-11eb-038a-574e118b5025
# ╠═100fd7d6-6805-11eb-0631-99a070466ac5
# ╠═9e4b2dfc-680a-11eb-26e6-299d32fbb6b0
