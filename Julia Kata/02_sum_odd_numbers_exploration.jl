### A Pluto.jl notebook ###
# v0.19.13

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
html"""
<style>
  main {
    max-width: calc(950px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
BenchmarkTools = "~1.3.1"
PlutoUI = "~0.7.44"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "ba5485f9627aeae9b74495c8021d66695c1b705d"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "4c10eee4af024676200bc7752e536f858c6b8f93"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "6e33d318cf8843dade925e35162992145b4eb12f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.44"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

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
# ╟─9e4b2dfc-680a-11eb-26e6-299d32fbb6b0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
