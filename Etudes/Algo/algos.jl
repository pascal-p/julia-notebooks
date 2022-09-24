### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

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
# permute(2, 2//3, π)

# ╔═╡ b469b203-c598-4b5c-a2e3-65c629c1f97c
# permute([Float64(π), Float64(ℯ), √2, √3])  # ℯ ≡ \euler

# ╔═╡ 8ec0b743-abba-41e0-a47a-c2cd50766beb


# ╔═╡ 740bf70a-1f9d-486a-bc47-72593bfbc222


# ╔═╡ 5d7987ec-6b65-48ea-9bc4-3a1ab6225de4


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
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─64f4c264-3bb7-11ed-3dfe-8365186d0729
# ╟─8be680d2-f0af-47b1-8d8f-06c16c7991bc
# ╟─1809702d-6cd3-462b-a473-76cf250950b2
# ╠═568f17b4-3ae2-4268-bbef-9b8a477d7337
# ╠═2fb4c18b-100e-4b37-a542-f9d4c09aadff
# ╠═4756900a-24e1-453b-a1ee-b0e533a49dfb
# ╠═68fea753-ba33-449b-b116-5407729691d5
# ╟─a2df02cc-b91f-496e-9f07-93bda662a127
# ╠═1740e40b-483a-4511-9e18-5223853434b9
# ╠═87279ef1-8ca5-48d8-a2ea-a84fcdfae317
# ╠═9fc5477e-5acd-491d-adcc-e9436c1c532a
# ╠═d4dd4a58-36ca-41e0-aa4f-117cf989514b
# ╠═cc57be02-b0e5-4890-9fd1-32f8474caf83
# ╠═922170c4-556e-49c3-b30e-1e188da7e354
# ╠═3a96f0c6-c66e-4ca8-80d2-818cda74689b
# ╠═3ceb8d7b-02bc-415a-9db3-1254cd651222
# ╠═c854d92e-6366-4444-8594-f2eef3db5b79
# ╠═b469b203-c598-4b5c-a2e3-65c629c1f97c
# ╠═8ec0b743-abba-41e0-a47a-c2cd50766beb
# ╠═740bf70a-1f9d-486a-bc47-72593bfbc222
# ╠═5d7987ec-6b65-48ea-9bc4-3a1ab6225de4
# ╟─58224148-017b-45a6-983e-bcff84d5e618
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
