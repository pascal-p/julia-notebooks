### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
begin
	using Pkg
	
# 	try
# 		using UnicodePlots
		
# 	catch ArgumentError
# 		Pkg.add("UnicodePlots")
# 		using UnicodePlots
# 	end
	
	using Test
	using PlutoUI
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Scope of variables

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)
"""

# ╔═╡ 1cab379d-d483-43fc-84f7-3bad9e583e77
md"""
A variable can be defined in one of two scopes — either *local* or *global*.
"""

# ╔═╡ bbc9bdb0-3b28-4f89-a980-d597b98e7880
a, b = 1, 2;

# ╔═╡ c2f716f9-98be-4bdf-be71-d915b02fc8a6
with_terminal() do

	let a=30, b=40
		let b=500
			println("inner scope $a $b")
		end
		println("outer scope $a $b")
	end
end

# ╔═╡ ee5589bd-3ee5-4a19-9870-b9ef03122639
with_terminal() do
	println("global scope $a $b")
end

# ╔═╡ e091acba-3fb1-4d96-a976-58cb051656a6
x = 5;

# ╔═╡ f73be67c-5989-4be2-8102-0c4023815756
with_terminal() do
	let
		println(x+1)   ## Expect 6
	end
end

# ╔═╡ a6d11cc6-0628-4a2b-9e46-89823839786f
md"""
However:
"""

# ╔═╡ 05276c9e-b4f7-400e-bb17-2ef4211c19cd
let
	x = x + 1   ## No Error, with Julia 1.6 / PLuto 
end

# ╔═╡ 2687c6b0-727d-4e0d-aed3-377a57867279
with_terminal() do
	let
		println(x)   ## Expect 5
	end
end

# ╔═╡ 82bd8ebd-63af-4de2-a673-d2b147c82bca
## Will fail
function twogram(s::AbstractString) 
	twograms = String[] 
	for (i, c) in enumerate(s)
		prev = if i == 1
			c
		else
			push!(twograms, string(prev, c))
			c
		end
	end
	twograms
end

# ╔═╡ 82c70730-535f-45ac-ac8a-f2d9e0ab5454
twogram("ABCD")   ## Error expected

# ╔═╡ 1ae57919-8890-4bac-b80e-fb1981ce2552
md"""
The `prev` variable has been declared in a loop scope, and hence its value is lost in each pass of the loop. 

This can be corrected (we have added `local prev` before the loop in order to declare prev in an *outer local scope*):
"""

# ╔═╡ d3a817d8-3b7b-4a12-b305-cb756d839524
function twogram2(s::AbstractString)
	twograms = String[]
	local prev

	for (i, c) ∈ enumerate(s)
		prev = if i==1
			c
		else
			push!(twograms, string(prev, c))
			c
		end
	end
	twograms
end

# ╔═╡ 5c69604a-63a3-4288-bb7a-bf47f614d917
twogram2("ABCD")

# ╔═╡ 2e481224-fed9-417e-9d4e-89c190fab2d2
md"""
Note however that the code of `twograms2` will not run as expected, if copied directly to the Julia command line.

We need to define a local scope to make it work using a `let` construct or prepending `global` in front of `prev` inside the function.
"""

# ╔═╡ bbce4433-d567-43f4-8b04-ba4aa242d5c5
md"""
Note that each module has its own global scope. The `Julia` command line works in the global scope of the `Main` module. If you define some code within a module, it will be global within this module. All the presented rules are valid. For example, consider the following module:
"""

# ╔═╡ 7895d933-105b-4618-a9dd-368c17cef35c
module B
	x=1

	function getxplusone()
		x + 1
	end

	function increasex()
		x += 1
	end

	function increasexglob()
		global x += 1
	end
end

# ╔═╡ 1d409947-442f-42e8-9524-e99a245c00d8
B.getxplusone()

# ╔═╡ 27714280-7dff-40ee-8442-023c5182e1b5
B.increasex()   ## Error expected

# ╔═╡ 61b1330e-7fcd-483d-bbee-000ef0b479a1
B.increasexglob()

# ╔═╡ b522199d-ef3b-4be6-8aee-d828037d202b
md"""
Any function creates a new local scope. 
Scoping within a function (*local scope*) and within the `Julia` command line (*global scope*) exposes completely different behavior. 

Consider the following code:
"""

# ╔═╡ b1be6114-5cd1-47bf-b400-e996ee0a9181
function f()
	x = 1
	for a ∈ 1:10
		x += 1
	end
	x
end

# ╔═╡ 9bb77ec4-3857-4a27-a74b-37b8bdbf368f
f()

# ╔═╡ cb51498d-baf4-42f8-975d-ef08ee7271d1
z = 1

# ╔═╡ c3529a34-c2e4-45d9-8aef-d91786f342e4
for _ ∈ 1:10
	z += 1       ## No problem anynore with `Julia ≥ 1.6`
end

# ╔═╡ 48d99279-a9a0-448d-b23d-2511d1c2fd52
u = 5; [(x = u + i; x) for i ∈ 1:2]

# ╔═╡ bb20dc58-b9c8-447b-a7a2-1fb553d6888b
u

# ╔═╡ dce5f294-48db-4ea6-a405-4f74b1aa3f97
v = 5; [(v = v + i; v) for i in 1:2]  # No problem anynore

# ╔═╡ 03ee4abd-268a-4a1c-9be0-5dbfdb50b41a
v

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╠═15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
# ╟─1cab379d-d483-43fc-84f7-3bad9e583e77
# ╠═bbc9bdb0-3b28-4f89-a980-d597b98e7880
# ╠═c2f716f9-98be-4bdf-be71-d915b02fc8a6
# ╠═ee5589bd-3ee5-4a19-9870-b9ef03122639
# ╠═e091acba-3fb1-4d96-a976-58cb051656a6
# ╠═f73be67c-5989-4be2-8102-0c4023815756
# ╟─a6d11cc6-0628-4a2b-9e46-89823839786f
# ╠═05276c9e-b4f7-400e-bb17-2ef4211c19cd
# ╠═2687c6b0-727d-4e0d-aed3-377a57867279
# ╠═82bd8ebd-63af-4de2-a673-d2b147c82bca
# ╠═82c70730-535f-45ac-ac8a-f2d9e0ab5454
# ╟─1ae57919-8890-4bac-b80e-fb1981ce2552
# ╠═d3a817d8-3b7b-4a12-b305-cb756d839524
# ╠═5c69604a-63a3-4288-bb7a-bf47f614d917
# ╟─2e481224-fed9-417e-9d4e-89c190fab2d2
# ╟─bbce4433-d567-43f4-8b04-ba4aa242d5c5
# ╠═7895d933-105b-4618-a9dd-368c17cef35c
# ╠═1d409947-442f-42e8-9524-e99a245c00d8
# ╠═27714280-7dff-40ee-8442-023c5182e1b5
# ╠═61b1330e-7fcd-483d-bbee-000ef0b479a1
# ╟─b522199d-ef3b-4be6-8aee-d828037d202b
# ╠═b1be6114-5cd1-47bf-b400-e996ee0a9181
# ╠═9bb77ec4-3857-4a27-a74b-37b8bdbf368f
# ╠═cb51498d-baf4-42f8-975d-ef08ee7271d1
# ╠═c3529a34-c2e4-45d9-8aef-d91786f342e4
# ╠═48d99279-a9a0-448d-b23d-2511d1c2fd52
# ╠═bb20dc58-b9c8-447b-a7a2-1fb553d6888b
# ╠═dce5f294-48db-4ea6-a405-4f74b1aa3f97
# ╠═03ee4abd-268a-4a1c-9be0-5dbfdb50b41a
