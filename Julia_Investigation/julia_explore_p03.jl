### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ 404be014-4df2-11ed-1bf5-c3249fd4a704
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ b3050a00-edbc-40db-9167-6ac0080a3251
using Random

# ╔═╡ da7222ff-e5ee-4d7f-8479-7f3e69c45c68
using Match

# ╔═╡ 6bb7b535-96be-4404-a4bf-68fc75003273
md"""
### Functions, arguments, default values
"""

# ╔═╡ c17ff176-d940-486c-8b63-d4af2d2e9704
const TN{T} = Union{Vector{T}, Nothing} where {T <: Number}

# ╔═╡ 4b64c9bc-995e-4cda-8f11-6c2c808c8c23
function g(a::T, b::T, c::T...)::TN{T} where {T <: Number}
	n = length(c)
    n > 0 ? [a + b * c[ix] for ix ∈ 1:n] : nothing
end

# ╔═╡ 09254184-0505-45fd-a741-e485ee693abc
@assert g(1.0, 2.0) === nothing 

# ╔═╡ cda6867b-ac9b-46ce-973a-59ea720f9ff3
@assert g(1., 2., 3., 4.) == [7, 9] # 1 + 2 * [3, 4] == [7, 9]

# ╔═╡ 3e878100-3a30-445b-8187-133bdf452c7f
@assert g(1., 2., 3., 4., 5.) ≈ [7., 9., 11.] # Float

# ╔═╡ d0ab011d-3237-4276-9cad-b5c357d382db
# fractions
@assert g(1//2, 2//3, 3//5, 5//7) == [9//10, 41//42]

# ╔═╡ eb7b95fd-ced5-460d-b4c5-97508897e89c
md"""
Note: g can be rewritten as follows (using "vectorization").
"""

# ╔═╡ 718ab143-669d-404f-bff0-a7b1233950c6
function g_(a::T, b::T, c::T...)::TN{T} where {T <: Number}
	length(c) == 0 && return nothing
	a .+ b .* [c...]
end

# ╔═╡ 98db07bb-577e-4a48-a201-a9e164a2965e
@assert g_(1.0, 2.0) === nothing

# ╔═╡ d553dae6-059a-428c-ac77-0e708563fd91
@assert g_(1., 2., 3., 4.) == [7, 9]

# ╔═╡ bf6860c6-b4d0-4277-82a6-71f0cae3b8cb
@assert g_(1//2, 2//3, 3//5, 5//7) == [9//10, 41//42]

# ╔═╡ bbd71cb0-c242-4ff6-ab75-5f5269232fe1
function meta_g(fn::Function, x::T...)::TN{T} where {T <: Number}
	length(x) == 0 && return nothing
	fn.([x...])
end

# ╔═╡ cb87cbee-1cfd-495a-94c6-7937bd39f336
# square args
@assert meta_g(x -> x * x + 1, 10, 20, 30) ==  [101, 401, 901]

# ╔═╡ 0e924c60-696d-4ce8-aed0-94ff142ceb65
@assert meta_g(x -> 2x + 1, 1//5, 2//3, 3//7) ==  [7//5, 7//3, 13//7]

# ╔═╡ 4e0d0c65-374c-43b9-9361-0e178fa28e56
md"""
### Named parameters and default
"""

# ╔═╡ 06bfc32d-1bcc-4f90-b987-1eaf82eb9790
f(x, y; α=2.5, β=4., γ=1.) = α * x + β * y + γ

# ╔═╡ 1a284050-dc50-4612-9e3c-5c69f26c2807
@assert f(2., 3.) ≈ 18.

# ╔═╡ f4115459-a772-432e-97bd-f5f140a33e0b
const rng = MersenneTwister(67);

# ╔═╡ 1ef5d74a-0e87-472a-a4af-fb8306e39134
function h(x::T...; μ::T₁=0., σ::T₁=1.)::TN{T₁} where {T <: Number, T₁ <: Number}
    n = length(x)
    n == 0 && return nothing
    [μ + σ * rand(rng) * x[ix] for ix ∈ 1:n]
end

# ╔═╡ c724871f-425c-4d97-ac21-73db8b575fa9
h(10, μ=2., σ=√2)

# ╔═╡ b5f9dab9-6c68-48b0-8a40-09dd950b8b53
h(10, μ=2., σ=√2)

# ╔═╡ dbae5bdd-2446-42ba-917a-23d0474b1129
md"""
### Oddity
"""

# ╔═╡ f5c21fc3-b65a-451a-a282-7c969811705e
is_even(n::Integer) = n % 2 == 0

# ╔═╡ cb69664a-ff6c-4158-a20a-86018bbe3ca7
map(is_even, [1, 2, 3])

# ╔═╡ 8ccb06b5-a024-448b-9cfb-ff2fadc2d576
begin
	function all_odds_are_prime(n::Any)
    	isinteger(n) && (return _all_odds_are_prime(n))
    	"Need integer value"
	end
    
	function _all_odds_are_prime(n::Integer) 
    	@match n begin
        	3 || 5 || 7 => "$n is a prime"
        	_   	    => "By induction all odds are prime!!"
    	end
	end
end

# ╔═╡ 4a075834-a4b6-4629-9b0c-364bc67b9811
@assert !isinteger(1.1)

# ╔═╡ 2b176202-69e5-412c-846f-887ed5269c52
@assert all_odds_are_prime(1.1) == "Need integer value"

# ╔═╡ 2b01d663-774a-4961-a6aa-61640b105a3e
@assert all_odds_are_prime(5) == "5 is a prime"

# ╔═╡ 4e615659-107d-4e31-8078-fd6bf8feea3b
@assert all_odds_are_prime(7) == "7 is a prime"

# ╔═╡ 156319eb-40e0-4d47-bf01-bd24745fcb18
_all_odds_are_prime(9) # doh!!

# ╔═╡ 71874a60-4817-4024-813e-d920d093f18b
function num_match(n::Integer)
    @match n begin
        0      => "zero"
        1 || 2 => "one or two"
        3:10   => "three to ten"
        _      => "something else"
    end
end

# ╔═╡ 994a4654-2601-4814-b37b-73b3604780fe
@assert num_match(0) == "zero"

# ╔═╡ 831597af-37bd-4e88-8a01-f9a176398c75
@assert num_match(1) == "one or two"

# ╔═╡ bb4df179-b02e-406c-9c32-2c9875ffa89a
@assert num_match(42) == "something else"

# ╔═╡ dba17805-6c4e-43bf-ab32-ea47eab2e7b5
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
Match = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Match = "~1.2.0"
PlutoUI = "~0.7.44"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "211c1067e9719d9728263b8f4ec9d4bcd3729903"

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

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

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
# ╠═404be014-4df2-11ed-1bf5-c3249fd4a704
# ╟─6bb7b535-96be-4404-a4bf-68fc75003273
# ╠═c17ff176-d940-486c-8b63-d4af2d2e9704
# ╠═4b64c9bc-995e-4cda-8f11-6c2c808c8c23
# ╠═09254184-0505-45fd-a741-e485ee693abc
# ╠═cda6867b-ac9b-46ce-973a-59ea720f9ff3
# ╠═3e878100-3a30-445b-8187-133bdf452c7f
# ╠═d0ab011d-3237-4276-9cad-b5c357d382db
# ╟─eb7b95fd-ced5-460d-b4c5-97508897e89c
# ╠═718ab143-669d-404f-bff0-a7b1233950c6
# ╠═98db07bb-577e-4a48-a201-a9e164a2965e
# ╠═d553dae6-059a-428c-ac77-0e708563fd91
# ╠═bf6860c6-b4d0-4277-82a6-71f0cae3b8cb
# ╠═bbd71cb0-c242-4ff6-ab75-5f5269232fe1
# ╠═cb87cbee-1cfd-495a-94c6-7937bd39f336
# ╠═0e924c60-696d-4ce8-aed0-94ff142ceb65
# ╟─4e0d0c65-374c-43b9-9361-0e178fa28e56
# ╠═06bfc32d-1bcc-4f90-b987-1eaf82eb9790
# ╠═1a284050-dc50-4612-9e3c-5c69f26c2807
# ╠═b3050a00-edbc-40db-9167-6ac0080a3251
# ╠═f4115459-a772-432e-97bd-f5f140a33e0b
# ╠═1ef5d74a-0e87-472a-a4af-fb8306e39134
# ╠═c724871f-425c-4d97-ac21-73db8b575fa9
# ╠═b5f9dab9-6c68-48b0-8a40-09dd950b8b53
# ╟─dbae5bdd-2446-42ba-917a-23d0474b1129
# ╠═f5c21fc3-b65a-451a-a282-7c969811705e
# ╠═cb69664a-ff6c-4158-a20a-86018bbe3ca7
# ╠═da7222ff-e5ee-4d7f-8479-7f3e69c45c68
# ╠═8ccb06b5-a024-448b-9cfb-ff2fadc2d576
# ╠═4a075834-a4b6-4629-9b0c-364bc67b9811
# ╠═2b176202-69e5-412c-846f-887ed5269c52
# ╠═2b01d663-774a-4961-a6aa-61640b105a3e
# ╠═4e615659-107d-4e31-8078-fd6bf8feea3b
# ╠═156319eb-40e0-4d47-bf01-bd24745fcb18
# ╠═71874a60-4817-4024-813e-d920d093f18b
# ╠═994a4654-2601-4814-b37b-73b3604780fe
# ╠═831597af-37bd-4e88-8a01-f9a176398c75
# ╠═bb4df179-b02e-406c-9c32-2c9875ffa89a
# ╟─dba17805-6c4e-43bf-ab32-ea47eab2e7b5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
