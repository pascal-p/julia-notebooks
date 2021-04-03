### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
begin
	using Pkg
	using Random
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Functions as variable

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)
"""

# ╔═╡ 9608fdc8-807e-4be2-91f8-950c0ceec2dd
Random.seed!(0)

# ╔═╡ c15cd8d2-3178-4490-bcdb-7ec54ec41318
md"""
In this example, we will consider a simplified agent-based simulation model, where a group of agents moves randomly over a two-dimensional surface. Additionally, we assume that, at each step of the simulation, the closer the agent is to the starting point, the lower the probability of movement. 

the probability of a change in an agent's location is equal to $\frac{1}{k}$, where $k$ is the rank of an agent (the agent that managed to travel the longest distance from its origin has the highest rank). 
"""

# ╔═╡ 1911333e-be43-4294-a374-ce15a7538a42
mutable struct Agent
	id::Int
	x::Float64
	y::Float64
	times_moved::Int
end

# ╔═╡ e33a47c8-ce78-4aad-8deb-a97c9cb47b25
function move!(agent::Agent)
	angle = rand() * 2π
	agent.x += cos(angle)
	agent.y += sin(angle)
	agent.times_moved += 1
end

# ╔═╡ 03409d5c-a6d2-43c4-9367-c52b87a9da01
function step!(pop::Vector{Agent})
	sort!(pop, by=a -> (a.x * a.x + a.y * a.y), rev=true)
	foreach(ix -> (rand() < (1/ix) && move!(pop[ix])), 1:length(pop))
end

# ╔═╡ afd70dd1-a99a-4003-a57f-e037855c7ad1
md"""
Now let us define a population of 30 agents:
"""

# ╔═╡ c2ce27b3-64f3-4a9f-a72d-8c56a8492fcc
pop = Agent.(1:30, 0., 0., 0)

# ╔═╡ ca503785-20e7-4ed0-bb4a-6330d710c27b
md"""
Now we define what happens at each simulation time step:
"""

# ╔═╡ d9f6a75e-c588-42e7-a815-318c5e33f706
md"""
Let us run the simulation:
"""

# ╔═╡ 476e9c3b-805b-4e89-a537-238c95ed546c
foreach(_a -> step!(pop), 1:1000)

# ╔═╡ d86c15dc-c0a1-4834-9328-055ef838f756
md"""
Finally, let us filter out the agents that are at least 25 units away from the origin:
"""

# ╔═╡ 30907ce3-a6c4-47f7-9aea-c40fb4368599
filter(a -> √(a.x * a.x + a.y * a.y) ≥ 25., pop)

# ╔═╡ 20ffa0af-d9ac-46a1-a6bd-597f2f8f1bed
md"""
In Julia, a function is a first-class object. 
We start by defining `struct` that we will operate on. We also define a `move!` function that mutates an agent's state.

The `map` function takes two parameters: a function and a collection. The function given as the parameter is executed over each element of the collection, and the result is returned as Array.

In the `step!` function, when sorting with `sort!`, we provide the `by=` parameter. The value of this parameter is an anonymous function that calculates a weight for each Array's element. The `foreach` function allows us to execute the `move!` function for each agent. Once again, we provide an anonymous function as a parameter to the `move!` function.

Finally, we again use the `foreach` function to actually run the simulation. The `filter` function can be used to filter out those Array elements having a desired set of values.
"""

# ╔═╡ Cell order:
# ╠═45d72214-919c-11eb-2e69-23c0786baacb
# ╠═15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
# ╠═9608fdc8-807e-4be2-91f8-950c0ceec2dd
# ╟─c15cd8d2-3178-4490-bcdb-7ec54ec41318
# ╠═1911333e-be43-4294-a374-ce15a7538a42
# ╠═e33a47c8-ce78-4aad-8deb-a97c9cb47b25
# ╠═03409d5c-a6d2-43c4-9367-c52b87a9da01
# ╟─afd70dd1-a99a-4003-a57f-e037855c7ad1
# ╠═c2ce27b3-64f3-4a9f-a72d-8c56a8492fcc
# ╟─ca503785-20e7-4ed0-bb4a-6330d710c27b
# ╟─d9f6a75e-c588-42e7-a815-318c5e33f706
# ╠═476e9c3b-805b-4e89-a537-238c95ed546c
# ╟─d86c15dc-c0a1-4834-9328-055ef838f756
# ╠═30907ce3-a6c4-47f7-9aea-c40fb4368599
# ╟─20ffa0af-d9ac-46a1-a6bd-597f2f8f1bed
