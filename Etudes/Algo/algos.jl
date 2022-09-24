### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 2ebd50d4-ce0b-4c6d-a7a5-f65435bafe67
begin
        using PlutoUI
        PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 64f4c264-3bb7-11ed-3dfe-8365186d0729
md"""
## Intro. Algos with `Julia`
--- 

Based on [Intro to Algorithms with Python](https://www.freecodecamp.org/news/intro-to-algorithms-with-python/) 
"""

# ╔═╡ 8be680d2-f0af-47b1-8d8f-06c16c7991bc
md"""
### 1. Recursivity
"""

# ╔═╡ 1809702d-6cd3-462b-a473-76cf250950b2
md"""
#### Permutations

Write a function that permutes all the letter of a given string.
"""

# ╔═╡ 568f17b4-3ae2-4268-bbef-9b8a477d7337
function rec_permute(str::String, res::String)
	length(str) == 0 && (println(res))

	for i ∈ 1:length(str)
		letter = str[i]
		head = str[1:i - 1]
		tail = str[i + 1:end]
		rec_permute(string(head, tail), string(letter, res))
	end
end

# ╔═╡ 2fb4c18b-100e-4b37-a542-f9d4c09aadff
rec_permute("zy", "")

# ╔═╡ 4756900a-24e1-453b-a1ee-b0e533a49dfb
rec_permute("xyz", "")

# ╔═╡ 68fea753-ba33-449b-b116-5407729691d5
# rec_permute("wxyz", "") 

# ╔═╡ e9701184-3f79-4985-a60e-b370f2cafd22
md"""
#### Iterative versions of permutations
"""

# ╔═╡ a2df02cc-b91f-496e-9f07-93bda662a127
md"""
OK, this works but this is not efficient. \
Can we devise an iterative version that generates the $n!$ permutation of a given string of length n?
"""

# ╔═╡ 1740e40b-483a-4511-9e18-5223853434b9
function permute_wlog(v::Vector{T}) where T # using vector because we want to use mutability
	for _ ∈ 1:factorial(length(v))
		println(v)        # display as it is
		ix = length(v)
		while ix > 1 && v[ix - 1] > v[ix]
			ix -= 1
		end
		println("\tix started from $(length(v)) it is now: $(ix) - mutate v[ix:end]: $(v[ix:end])")
		v[ix:end] = reverse(v[ix:end])
		println("\tnow we have v[ix:end]: $(v[ix:end])")
		
		if ix > 1
			jx = ix
			while v[ix - 1] > v[jx]
				jx += 1
			end
			println("\t(jx: $(jx) ix: $(ix) - now swap: v[ix - 1]: $(v[ix - 1]), v[jx]: $(v[jx])")
			v[ix - 1], v[jx] = v[jx], v[ix - 1]
			println("\t(jx: $(jx) ix: $(ix) - $(v[ix - 1]), v[jx]: $(v[jx])")
		end
	end
	# back to original order
end

# ╔═╡ 87279ef1-8ca5-48d8-a2ea-a84fcdfae317
function permute(v::Vector{T}) where T # using vector because we want to use mutability
	n = length(v)
	for _ ∈ 1:factorial(n)
		println(v)        # display as it is
		ix = n
		while ix > 1 && v[ix - 1] > v[ix]
			ix -= 1
		end
		v[ix:end] = reverse(v[ix:end])
		if ix > 1
			jx = ix
			while v[ix - 1] > v[jx]
				jx += 1
			end
			v[ix - 1], v[jx] = v[jx], v[ix - 1]
		end
	end
	# back to original order
end

# ╔═╡ 9fc5477e-5acd-491d-adcc-e9436c1c532a
permute(str::String) = collect(str) |> permute

# ╔═╡ d4dd4a58-36ca-41e0-aa4f-117cf989514b
function permute(v...)
	println(v, " / ", typeof(v), " / ", eltype(v))
	println(length(v))
	permute(Vector{eltype(v)}([v...]))
end

# ╔═╡ cc57be02-b0e5-4890-9fd1-32f8474caf83
md"""
Order does not matter. However if the sequence is ordered it becomes easier to follow what is happening... 

Assume increasing order of original sequence (ex: 'abcd')
  - first, keep the leftist item (smallest in increasing order, 'a' ) at its place and generate all permutations of size length(sequence) - 1 (for "bcd").
  - then swap the two leftmost element ('a' and 'b') and again generate all permutations of size length(sequence) - 1 (for acd)...
  - then swap the two leftmost element ('b' and 'c') ...
  - then swap the two leftmost element ('c' and 'd') ...
"""

# ╔═╡ 922170c4-556e-49c3-b30e-1e188da7e354
permute_wlog("abcd" |> collect)

# ╔═╡ 3a96f0c6-c66e-4ca8-80d2-818cda74689b
permute([2, 4, 3])

# ╔═╡ 3ceb8d7b-02bc-415a-9db3-1254cd651222
permute(2, 4, 3)

# ╔═╡ c854d92e-6366-4444-8594-f2eef3db5b79
permute(2, 2//3, π)

# ╔═╡ b469b203-c598-4b5c-a2e3-65c629c1f97c
permute([Float64(π), Float64(ℯ), √2, √3])  # ℯ ≡ \euler

# ╔═╡ 72841639-3b28-4b16-a5b8-1161c9c93bb5
permute_cons(s::String) = permute_cons(s |> collect)

# ╔═╡ c5f2b476-9f57-4316-a880-69f2f4bff08c
function insert_all(seqs::Vector{Vector{T}}, item::T) where T <: Any
	n = length(seqs)
	new_seqs = fill(T[], (length(seqs[1]) + 1) * n)

	# kx = 1
	for ix ∈ 1:n
		m = length(seqs[ix]) + 1
		for jx ∈ 1:m
			new_seqs[jx + (ix  - 1) * m] = [seqs[ix][1:jx-1]..., item, seqs[ix][jx:end]...]
			# new_seqs[kx] = [seqs[ix][1:jx-1]..., item, seqs[ix][jx:end]...]
			# kx += 1
		end
	end
	seqs = nothing
	new_seqs
end

# ╔═╡ 8ec0b743-abba-41e0-a47a-c2cd50766beb
function permute_cons(v::Vector{T}) where T <: Any
	n = length(v)
	n == 0 && return nothing
	n == 1 && return v
	n == 2 && return [v, [v[2], v[1]]]

	# n ≥ 3
	seqs = [v[1:2], v[1:2] |> reverse]
	for ix ∈ 3:n
		item = v[ix]
		seqs = insert_all(seqs, item)
	end
	seqs
end

# ╔═╡ 740bf70a-1f9d-486a-bc47-72593bfbc222
 @assert permute_cons([1, 2]) == [[1, 2], [2, 1]]

# ╔═╡ 5d7987ec-6b65-48ea-9bc4-3a1ab6225de4
permute_cons([1, 2, 3])

# ╔═╡ eb5970a9-0060-4bde-b561-ec3144db0a59
permute_cons("abcd")

# ╔═╡ ae5b2b3a-c5c4-4863-ab86-6296ea88e57c
permute_cons([false, true, nothing])

# ╔═╡ 58224148-017b-45a6-983e-bcff84d5e618
html"""
<style>
  main {
    max-width: calc(1000px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.43"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "502a5e5263da26fcd619b7b7033f402a42a81ffc"

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
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "2777a5c2c91b3145f5aa75b61bb4c2eb38797136"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.43"

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
version = "1.10.0"

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
# ╟─64f4c264-3bb7-11ed-3dfe-8365186d0729
# ╠═2ebd50d4-ce0b-4c6d-a7a5-f65435bafe67
# ╟─8be680d2-f0af-47b1-8d8f-06c16c7991bc
# ╟─1809702d-6cd3-462b-a473-76cf250950b2
# ╠═568f17b4-3ae2-4268-bbef-9b8a477d7337
# ╠═2fb4c18b-100e-4b37-a542-f9d4c09aadff
# ╠═4756900a-24e1-453b-a1ee-b0e533a49dfb
# ╠═68fea753-ba33-449b-b116-5407729691d5
# ╟─e9701184-3f79-4985-a60e-b370f2cafd22
# ╟─a2df02cc-b91f-496e-9f07-93bda662a127
# ╠═1740e40b-483a-4511-9e18-5223853434b9
# ╠═87279ef1-8ca5-48d8-a2ea-a84fcdfae317
# ╠═9fc5477e-5acd-491d-adcc-e9436c1c532a
# ╠═d4dd4a58-36ca-41e0-aa4f-117cf989514b
# ╟─cc57be02-b0e5-4890-9fd1-32f8474caf83
# ╠═922170c4-556e-49c3-b30e-1e188da7e354
# ╠═3a96f0c6-c66e-4ca8-80d2-818cda74689b
# ╠═3ceb8d7b-02bc-415a-9db3-1254cd651222
# ╠═c854d92e-6366-4444-8594-f2eef3db5b79
# ╠═b469b203-c598-4b5c-a2e3-65c629c1f97c
# ╠═8ec0b743-abba-41e0-a47a-c2cd50766beb
# ╠═72841639-3b28-4b16-a5b8-1161c9c93bb5
# ╠═c5f2b476-9f57-4316-a880-69f2f4bff08c
# ╠═740bf70a-1f9d-486a-bc47-72593bfbc222
# ╠═5d7987ec-6b65-48ea-9bc4-3a1ab6225de4
# ╠═eb5970a9-0060-4bde-b561-ec3144db0a59
# ╠═ae5b2b3a-c5c4-4863-ab86-6296ea88e57c
# ╟─58224148-017b-45a6-983e-bcff84d5e618
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
