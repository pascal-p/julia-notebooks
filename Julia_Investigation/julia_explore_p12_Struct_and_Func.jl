### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ d3435ffa-6910-11eb-1169-5f99095f1fdf
begin
	using PlutoUI
	using Test
	using Printf
end

# ╔═╡ 57e617da-6910-11eb-0e3f-33b08ab72b7a
md"""
### Structs and Functions

* From Chapter 16. Structs and Functions - Think Julia, by Ben Lauwens*  
* From Chapter 17. Multiple Dispatch  - Think Julia, by Ben Lauwens*  

Resources:
- https://github.com/BenLauwens/ThinkJulia.jl
"""

# ╔═╡ b8800646-8364-4cd9-8ab5-c010c666fb65
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 7d6fa0de-6910-11eb-00df-39e0c9733dd2
"""
Represents the time of day.
fields: hour, minute, second
"""
struct YaTime
    hour::Int64
    minute::Int64
    second::Int64
    
    # inner constructor, to enforce invariants:
    function YaTime(hour::Int64=0, minute::Int64=0, second::Int64=0)
        @assert(0 ≤ minute < 60, "Minute is not between 0 and 60.")
        @assert(0 ≤ second < 60, "Second is not between 0 and 60.")
		
        new(hour, minute, second)
    end
end

# ╔═╡ a5a13cf2-6910-11eb-1db3-392525cb52dc
md"""
The `struct YaTime` now has four inner constructor methods:
- `YaTime()`
- `YaTime(hour::Int64)`
- `YaTime(hour::Int64, minute::Int64)`
- `YaTime(hour::Int64, minute::Int64, second::Int64)`

An inner constructor method is always defined inside the block of a type declaration, and it has access to a special function called `new` that creates objects of the newly declared type.
"""

# ╔═╡ b5c2de12-6910-11eb-3ade-73ae4245aaf9
begin
	@test_throws AssertionError YaTime(23, 89, 10)
	@test_throws AssertionError YaTime(23, 89)
end

# ╔═╡ 0e1ecf32-6912-11eb-3eff-4bbfc6d00980
md"""
**Exercise**

Write a function called print_time that takes a YaTime object and prints it in the form `hour:minute:second`.  
The @printf macro of the standard library module Printf prints an integer with the format sequence `"%02d"` using at least two digits, including a leading zero if necessary.

"""

# ╔═╡ 030e96a8-6911-11eb-3c5f-b103f63ecb8f
function print_time(t::YaTime)
    @printf("%02d:%02d:%02d\n", t.hour, t.minute, t.second)
end

# ╔═╡ 5777439a-6911-11eb-3cd0-cdd3a66c15a6
with_terminal() do
	t = YaTime(10, 11, 24) # using default (implicit) constructor
	print_time(t)
end

# ╔═╡ 6f3db41e-6911-11eb-016d-11a7e82f072d
## we can also define Base.show

Base.show(io::IO, t::YaTime) = print(io, @sprintf("%02d:%02d:%02d\n", t.hour, t.minute, t.second))

# ╔═╡ d522cea2-6911-11eb-026f-4be6aec6f3de
t₁ = YaTime(19, 58, 24)

# ╔═╡ 22d86fa0-6912-11eb-13f6-1125998a1df7
md"""
**Exercise**

Write a Boolean function called `is_after` that takes two YaTime objects, t1 and t2, and returns true if t1 follows t2 chronologically and false otherwise. 

*Challenge: don’t use an if statement.*
"""

# ╔═╡ 37c16a0c-6912-11eb-07c3-733e4066b898
is_after(t₁::YaTime, t₂::YaTime) = t₁.hour > t₂.hour || t₁.minute > t₂.minute || t₁.second > t₂.second

# ╔═╡ 91dcec8c-6912-11eb-1c04-f781c60db1ae
begin
	tₓ, tₜ = (YaTime(11, 11, 54), YaTime(10, 11, 54)) 
	@test is_after(tₓ, tₜ)
	
	(t₃, t₄) = (YaTime(11, 11, 56), YaTime(11, 11, 55)) 
	@test is_after(t₃, t₄)
	
	t₅ = YaTime(11, 10, 54) 
	@test is_after(t₃, t₅)
	
	t₆= YaTime(12, 11, 54)
	@test !is_after(tₓ, t₆)    ## negation
end

# ╔═╡ a64a66e4-6913-11eb-29cb-85ce1f785caa
md"""
#### Pure Function
"""

# ╔═╡ 50166aec-6914-11eb-2bda-cde28024c50f
begin

import Base: +, ==, isless

function +(t₁::YaTime, t₂::YaTime)::YaTime
    """
    Creates a new YaTime Struct, initializes its fields, and returns a reference to it
    """
    sec  = t₁.second + t₂.second
    min  = t₁.minute + t₂.minute
    hour = t₁.hour + t₂.hour
    
    sec, min  = add_hlpr(sec, min)
    min, hour = add_hlpr(min, hour) 
    
    YaTime(hour, min, sec)
end

function +(t::YaTime, sec::Int64)::YaTime
  	tsec = time_to_int(t) + sec
  	int_to_time(tsec)
end

+(sec::Int64, t::YaTime) = :+(t, sec)	
	
function ==(t₁::YaTime, t₂::YaTime)::Bool
	t₁.hour == t₂.hour && t₁.minute == t₂.minute && t₁.second == t₂.second
end
	
function isless(t₁::YaTime, t₂::YaTime)::Bool
    (t₁.hour, t₁.minute, t₁.second) < (t₂.hour, t₂.minute, t₂.second)
end
	
function time_to_int(t::YaTime)::Int64
  t.second + t.minute * 60 + t.hour * 3600
end
	
function int_to_time(val::Int64)::YaTime
  (h, val) = divrem(val, 3600)
  (m, s) = divrem(val, 60)
  YaTime(h, m, s)
end
	
function add_hlpr(u₁::Integer, u₂::Integer, mod::Integer=60)
    if u₁ > mod
        u₁ -= 60
        u₂ += 1
    end
    (u₁, u₂)
end
	
end

# ╔═╡ eff6c928-6917-11eb-2720-918204039f0e
with_terminal() do
	println(methods(+))
end

# ╔═╡ de8be752-6914-11eb-2061-21ec29439e96
begin
	(tₐ, tₒ) = (YaTime(12, 11, 54), YaTime(11, 11, 54)) 
	nt = tₐ + tₒ
end

# ╔═╡ 1ced8ab4-6915-11eb-1de5-3de099efa35c
@test YaTime(10, 30, 54) + YaTime(9, 11, 44) == YaTime(19, 42, 38)

# ╔═╡ e4bc1df8-6915-11eb-130f-e1b1bdd1e940
md"""
#### Using Conversions

When we wrote `+`, we were effectively doing addition in base 60, which is why we had to carry from one column to the next.

This observation suggests another approach to the whole problem — we can convert YaTime objects to integers and take advantage of the fact that the computer knows how to do integer arithmetic.

cf. implementation above...
"""

# ╔═╡ 6526d230-6916-11eb-07f2-63fe39f294c7
begin
	ts = YaTime(1, 10, 10)
	@test time_to_int(ts) == 4210
	
	nts = YaTime(2, 31, 10)
	@test time_to_int(nts) == 9070  # "3h31m10s is 9070s"

	nts₂ = YaTime(24, 0, 0)
	@test time_to_int(nts₂) == 86_400 # "24h is 86400s"
	
	nts₃ = YaTime(24, 0, 0) + 11
	@test time_to_int(nts₃) == 86_411 # "24h and 11s is 86411s"
end

# ╔═╡ d2836738-c72c-4348-aede-7db694123f70
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
# ╟─57e617da-6910-11eb-0e3f-33b08ab72b7a
# ╠═d3435ffa-6910-11eb-1169-5f99095f1fdf
# ╟─b8800646-8364-4cd9-8ab5-c010c666fb65
# ╠═7d6fa0de-6910-11eb-00df-39e0c9733dd2
# ╟─a5a13cf2-6910-11eb-1db3-392525cb52dc
# ╠═b5c2de12-6910-11eb-3ade-73ae4245aaf9
# ╟─0e1ecf32-6912-11eb-3eff-4bbfc6d00980
# ╠═030e96a8-6911-11eb-3c5f-b103f63ecb8f
# ╠═5777439a-6911-11eb-3cd0-cdd3a66c15a6
# ╠═6f3db41e-6911-11eb-016d-11a7e82f072d
# ╠═d522cea2-6911-11eb-026f-4be6aec6f3de
# ╟─22d86fa0-6912-11eb-13f6-1125998a1df7
# ╠═37c16a0c-6912-11eb-07c3-733e4066b898
# ╠═91dcec8c-6912-11eb-1c04-f781c60db1ae
# ╟─a64a66e4-6913-11eb-29cb-85ce1f785caa
# ╠═50166aec-6914-11eb-2bda-cde28024c50f
# ╠═eff6c928-6917-11eb-2720-918204039f0e
# ╠═de8be752-6914-11eb-2061-21ec29439e96
# ╠═1ced8ab4-6915-11eb-1de5-3de099efa35c
# ╟─e4bc1df8-6915-11eb-130f-e1b1bdd1e940
# ╠═6526d230-6916-11eb-07f2-63fe39f294c7
# ╟─d2836738-c72c-4348-aede-7db694123f70
