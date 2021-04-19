### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 5ecc9b01-bbcf-41d3-a2e5-51c2d242ba13
begin
	using PlutoUI
	using Test
end

# ╔═╡ 420fe8b0-a0e1-11eb-3d87-8fbf9a8445a6
md"""
## Julia exploration: Channels, iterators

"""

# ╔═╡ 4cb29ef3-be1d-45e2-90c0-5cd6d33f6308
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ b5d4212a-8971-40b9-a540-0b0593f3014a
md"""
### Using channels
"""

# ╔═╡ b84302b6-6582-4d6b-9350-90a39c1c87da
## Producer 
##
function fibo(n::Integer)
	Channel{Int64}(20) do ch
		a, b = 0, 1
		for _ ∈ 1:n
			a, b = b, a + b
			put!(ch, a)
		end
	end
end

# ╔═╡ 7e7b494c-0052-4192-b810-144a3c3c7e72
## Consummer
##
with_terminal() do
	for val ∈ fibo(54)
		val % 5 == 0 && println()
    	print(val, " ")
	end
end

# ╔═╡ 32674ee8-2e34-4e81-b8b8-e8fdcfcf4132
md"""
Another example.
"""

# ╔═╡ c8430355-2128-4206-ae88-319d26557f60
function generator(;n::Int=1, buffer_sz=10)::Channel
	@assert n > 0 && buffer_sz > 0
	
	Channel{Char}(buffer_sz) do ch
		for ix ∈ 0:n-1
			put!(ch, Char('A' + (ix % 26)))
		end
	end
end

# ╔═╡ b5155ffb-b371-45c9-8778-7f6005164022
g = generator()

# ╔═╡ 645a0289-4c3e-49c8-af2c-64555d283e25
collect(g)

# ╔═╡ 39665955-0835-459d-9476-797d50ea10a9
g₂ = generator(n=10, buffer_sz=2)

# ╔═╡ 16ab9011-cbef-4939-b3ef-69029d2cb7e7
collect(g₂)

# ╔═╡ 3dc47adb-154c-4109-bb6b-2223e0d26d9f
# we can use the splat operator
@test [g...] == collect(g)

# ╔═╡ ab40e357-7fac-4220-addb-b3add86ad982
md"""
### Details about Tasks and Channels
"""

# ╔═╡ 1aac9209-a955-430e-a898-1a25f056826c
md"""
Let us rewrite our generator function without the Channel block to explicit what is going on...
"""

# ╔═╡ 0cced5d4-77ba-46c9-b1c4-0119cf4cff46
function generator_alt(;n::Int=1, buffer_sz=10)
	@assert n > 0 && buffer_sz > 0
	ch = Channel(buffer_sz)
	
	# closure
	function gen_letters()
		for ix ∈ 0:n-1
			put!(ch, Char('A' + (ix % 26)))
		end
	end
	
	t = Task(gen_letters)    ## create a task for this coroutine
	schedule(t)              ## schedule it to run
	ch
end

# ╔═╡ f37022c3-b4bd-4904-a544-38d83ef67cbf
md"""
Channels are used to send data between coroutines. 

Note we cannot have multiple coroutines running on different CPU cores. Coroutines allow for cooperative multi-tasking. The scheduler switches between coroutine, because the current one has explicitly give up control.


We specified a buffer of size 2 and when this buffer gets full, the coroutine will block and the scheduler will pick another coroutine (task) waiting for this particular channel.

Every coroutine needs a task, while a task keeps track of the execution state. 
"""

# ╔═╡ 23930be8-ab35-4cae-9563-99fcd571a401
begin
	## consumer
	ch_gen = generator_alt(n=5)
	take!(ch_gen)   ## consume 1 char
end

# ╔═╡ 45046186-8f4c-44e1-9097-5b39ac678cd4
take!(ch_gen)

# ╔═╡ 4e259e35-b318-49bb-97c3-839354169b20
with_terminal() do
	for _ ∈ 1:3
		println(take!(ch_gen))
	end
	# take!(ch_gen)  ## would block forever
end

# ╔═╡ 500c5603-e0cd-40b2-80c4-6cbd6bbef7cc
md"""
Finally an alternative with the `@async` macro.
"""

# ╔═╡ d34b4627-4d7e-41be-b32d-7455a1a33105
function generator_alt₂(;n::Int=1, buffer_sz=10)
	@assert n > 0 && buffer_sz > 0
	ch = Channel(buffer_sz)
	
	@async begin
		for ix ∈ 0:n-1
			put!(ch, Char('A' + (ix % 26)))
		end
	end
	ch
end

# ╔═╡ 5820cab3-84e0-4c3d-a910-43a59b5ed24e
with_terminal() do
	## consumer
	n = 3
	ch_gen₂ = generator_alt₂(;n)
	for _ ∈ 1:n
		println(take!(ch_gen₂))
	end
end

# ╔═╡ 8a65122f-d236-42cc-816c-5686c8202b34
html"""                                        
<style>                                        
  main {                                       
	max-width: calc(800px + 25px + 6px);   
  }                                            
  .plutoui-toc.aside {                         
	background: linen;                         
  }                                            
  h3, h4 {                                     
	background: wheat;                     
  }                                            
</style>
"""


# ╔═╡ Cell order:
# ╟─420fe8b0-a0e1-11eb-3d87-8fbf9a8445a6
# ╠═5ecc9b01-bbcf-41d3-a2e5-51c2d242ba13
# ╟─4cb29ef3-be1d-45e2-90c0-5cd6d33f6308
# ╟─b5d4212a-8971-40b9-a540-0b0593f3014a
# ╠═b84302b6-6582-4d6b-9350-90a39c1c87da
# ╠═7e7b494c-0052-4192-b810-144a3c3c7e72
# ╟─32674ee8-2e34-4e81-b8b8-e8fdcfcf4132
# ╠═c8430355-2128-4206-ae88-319d26557f60
# ╠═b5155ffb-b371-45c9-8778-7f6005164022
# ╠═645a0289-4c3e-49c8-af2c-64555d283e25
# ╠═39665955-0835-459d-9476-797d50ea10a9
# ╠═16ab9011-cbef-4939-b3ef-69029d2cb7e7
# ╠═3dc47adb-154c-4109-bb6b-2223e0d26d9f
# ╟─ab40e357-7fac-4220-addb-b3add86ad982
# ╟─1aac9209-a955-430e-a898-1a25f056826c
# ╠═0cced5d4-77ba-46c9-b1c4-0119cf4cff46
# ╟─f37022c3-b4bd-4904-a544-38d83ef67cbf
# ╠═23930be8-ab35-4cae-9563-99fcd571a401
# ╠═45046186-8f4c-44e1-9097-5b39ac678cd4
# ╠═4e259e35-b318-49bb-97c3-839354169b20
# ╟─500c5603-e0cd-40b2-80c4-6cbd6bbef7cc
# ╠═d34b4627-4d7e-41be-b32d-7455a1a33105
# ╠═5820cab3-84e0-4c3d-a910-43a59b5ed24e
# ╟─8a65122f-d236-42cc-816c-5686c8202b34
