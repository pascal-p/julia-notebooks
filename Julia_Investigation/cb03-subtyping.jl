### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 9608fdc8-807e-4be2-91f8-950c0ceec2dd
begin
	using Test
	using PlutoUI
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Subtyping

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)

**Context**
A Gaussian integer is a complex number whose real and imaginary parts are both integers.
"""

# ╔═╡ 82503139-3e37-4bf5-99f6-daf686f591e8
md"""
Let us start with defining a custom `Point` type, and two outer constructors for this type:
"""

# ╔═╡ 25b36455-0e5a-4318-9bd3-0440ac0b0080
begin
	
	struct Point{T <: Integer, S<:AbstractString}
		pos::Complex{T}
		label::S
	end
	
	Point(x::T, y::T, label::S) where {T <: Integer, S <: AbstractString} =
		Point{T, S}(Complex(x, y), label)
	
	Point(x, y, label) = Point(promote(Integer.((x, y))...)..., label)
	
end

# ╔═╡ c07b43bd-4aff-4e0a-9a34-12bc8a49e8ca
begin
	p₁ = Point(1, 0, "1")
	p₂ = Point(1, 0, SubString("1", 1))
	p₃ = Point(true, false, "1")         ## will be promoted
	p₄ = Point(2, 0, "2")
	
	ary = Point[p₁, p₂, p₃, p₄]
	(p₁, p₂, p₃, p₄)
end

# ╔═╡ ced242ca-2352-4b3f-bf32-a095705756ef
md"""
let us write a method that takes an array of Point and returns a new Point type that is the sum of passed Point instances with an empty label:
"""

# ╔═╡ f886d114-114e-4f66-8d5c-9edd5e1fdfe2
function sum_points_v₁(ary::Vector{Point})::Point
	Point(sum(getfield.(ary, :pos)), "")
end

# ╔═╡ 81840539-f363-414d-a263-227dcb10abb0
function sum_points_v₂(ary::Vector{Point})::Point
	Point(sum(p.pos for p in ary), "")
end

# ╔═╡ e4d9bae1-1a63-45c6-97a2-9d9fa54f3b54
sum_points_v₁(ary)  ## slower than  sum_points_v₂

# ╔═╡ 20bdff6e-c631-4de0-8631-9a9de2f82edb
md"""
Expecting an **error** while invoking `sum_points_v₂([p₁, p₂])`, but why?
"""

# ╔═╡ d8e2b4db-ec24-411a-9a62-d7f2a6b4d078
## with Reactive cell - the test will pass and then fail because of added 
## definition to fix the problem later

# @test_throws MethodError sum_points_v₂([p₁, p₂])

# ╔═╡ c2745a46-6258-4b92-b7bb-2a770c9273ec
md"""
our `Vector{Point{Int64, S}` (see cell below) does not match the function signature expectation, which is `Vector{Point}`.
"""

# ╔═╡ a70143ea-4920-413f-a6c1-515eef6c4f78
typeof([p₁, p₂])

# ╔═╡ 268af4e1-eb7a-4c0c-959c-c434c8e094b4
md"""
vs using `Point[...]`, which is fine:
"""

# ╔═╡ d74742e6-1aed-47fa-8c29-0e31c4459e3f
md"""
OK, so let us modified our function signature as follows. Note the use of `AbstractVector`.
"""

# ╔═╡ 6fa1df97-16e4-4b45-814c-cba39ebf9efa
function sum_points_v₂(ary::AbstractVector{<: Point})::Point
	Point(sum(p.pos for p in ary), "")
end

# ╔═╡ bc1b65b1-5063-4567-8928-f9847f0382b4
sum_points_v₂(ary)

# ╔═╡ e9a32b85-e697-4a78-8cbb-0d242e86d8fe
sum_points_v₂(Point[p₁, p₂])

# ╔═╡ 224a9eaa-7062-481f-8af3-098ba1988c5d
md"""
And now we can see this is working (cf. explanation in later cells):
"""

# ╔═╡ e432f0a0-45de-4f23-aab7-09a30b1b7bdc
sum_points_v₁(ary)

# ╔═╡ d7f7ab10-f69b-4143-962c-72ea4b764e40
md"""
##### Remarks:
When storing parametric types in collections, the standard constructors try to find the narrowest possible type that can hold the passed data. This means that if we can expect to encounter heterogeneous data types in the collection, then we *should manually specify an appropriate type*.
For instance, the first example shown below fails, while the second works:
"""

# ╔═╡ 424a9736-1c65-440a-9079-5fd63c74fd50
@test_throws MethodError push!([p₁], p₂)

# ╔═╡ 810473f2-d8c2-44e5-811b-185a445694a9
@test push!(Point[p₁], p₂) == Point[Point{Int64, String}(1 + 0im, "1"), 
	Point{Int64, SubString{String}}(1 + 0im, "1")]

# ╔═╡ 4b8455fd-b54c-4eee-8e95-612b3132a0bc
md"""
##### Methods

Investigating `Julia` subtyping algorithm in method dispatch.$(html"<br />")
Let us define another function `foo` which takes a single Point:
"""

# ╔═╡ 87e8df24-dc9d-42bd-a38f-9d5f16533e75
begin
	foo(p::Point) = "Generic Definition."
	
	foo(p::Point{Int, <: AbstractString}) = "Default Int Passed."
	
	foo(p::Point{<: Integer, String}) = "Default String Passed."
end

# ╔═╡ 639755ac-0d13-4087-b632-223ced8d334c
md"""
The last test shows that it is necessary to define a specific method for the intersection of types: `foo(p::Point{Int, String}) = "Most Specific Method."`:
"""

# ╔═╡ 6bcfbc7a-fa47-4471-bedc-071bbd58decc
foo(p::Point{Int, String}) = "Most Specific Method."

# ╔═╡ cfd030ff-ddc5-46d8-b478-56a87d2f8f11
with_terminal() do
	@show methods(foo)
end

# ╔═╡ af97433f-e26d-4178-97dd-1f580b9c66d3
begin
	@test foo(Point(true, true, s"12")) == "Generic Definition."
	
	@test foo(Point(1, 1, s"12")) == "Default Int Passed."
	
	@test foo(Point(true, true, "12")) == "Default String Passed."
	
	##
	## OK: with reactive cells - this will fail one the specific foo method is added!
	##
	## @test_throws MethodError foo(Point(1, 1, "12")) # == "Default String Passed"
	##
	## => foo(::Main.workspace36.Point{Int64, String}) is ambiguous. Candidates:
	## Possible fix, define
	##
	## foo(::Main.workspace36.Point{Int64, String})
end

# ╔═╡ cdc06666-2646-46cc-9a45-890ae5c88abe
with_terminal() do
	@show methods(foo)
end

# ╔═╡ 42a5ca4c-cd2c-4ced-a59c-638d7429c2c7
@test foo(Point(1, 1, "12")) == "Most Specific Method."

# ╔═╡ 03b637ec-6537-4019-9332-a9881a4ad54c
md"""
##### Remarks:

In `Julia`, most parametric types are invariant. 
**This means that subtyping of type parameters does not translate to subtyping of parametric types**. 

Here is an example - consider the following:
"""

# ╔═╡ 3f337631-6d8a-4618-9e9f-a0f0a1eb5438
begin
	@test Int <: Integer                                  ## => true 
	@test !(Point{Int, String} <: Point{Integer, String}) ## NOTE the ! ≡ negation
end

# ╔═╡ 5fc62545-fc1f-4385-9a79-bccdaa665953
md"""
In order to allow for subtyping of types in function signatures, the <: operator is  required:
"""

# ╔═╡ 37a08ce3-7b85-4540-a080-ec1f47c3bf6a
begin
	@test Point{Int, String} <: Point{<:Integer, String} ## NOTE: <:Integer
	
	# equivalent:
	@test Point{Int, String} <: Point{T, String} where {T <: Integer}
end

# ╔═╡ 122211d1-4ba1-440f-a632-b4b90e47302a
md"""
If a parametric type has more than one parameter, we can partially restrict them to a subset. Consider the following examples:
"""

# ╔═╡ 428c43cb-2c9b-4c1f-9509-1bd93af3d0bb
Point{Int}

# ╔═╡ b3056d5a-7790-4b94-9c77-854087a01cb2
Point{<: Signed, String}

# ╔═╡ b0162138-03e1-4dcc-b76c-073e6bea17d9
Point{Int}{String}, Point{Int, String}
## equivalent

# ╔═╡ 61a7e87a-9dc1-4519-ad78-51659c383496
md"""
We can see that type invariance is important in the definition of the `sum_points_v₂` function, as it only accepts subtypes of `AbstractVector{Point}` and `[p1, p2]` creates `Vector{Point{Int}}`, which is *NOT its subtype*. 

However, the following statement works: `sum_points_v₂(Point[p1, p2])` because we have explicitly set the type of the vector holding p1 and p2. This is a common pitfall in Julia. 

Fortunately, it is simple to solve this using the `<:` operator, as shown above with the defintion of `sum_points_v₂(ary::AbstractVector{<: Point})` above...
"""

# ╔═╡ a29183fa-99eb-4bc9-bffd-4bf8fe1c1cb1
md"""
The preceding type invariance rules are NOT applicable to **tuples that are covariant**. This means that tuple subtyping behaves as if the `<:` operator were added to every variable in the tuple definition. 

For instance, consider this example (it has been made complex on purpose to show that subtyping of every entry of Tuple type is subtyped):

"""

# ╔═╡ 43655522-24a7-4497-a305-4cb1a53e8791
@test Tuple{Point{Int, String}, Point{Bool, SubString{String}}} <: Tuple{Point{Int}, Point}   ## true

# ╔═╡ 8a1e851c-8e86-4e56-86be-089667044cd4
md"""
The consequence is that with tuples, we do not specify `<:` to get the subtyping behavior we discussed earlier:
"""

# ╔═╡ f40cdaeb-8474-4bae-a46f-44e2199e3712
sum_point_tuple(v::Tuple{Vararg{Point}}) = Point(sum(p.pos for p in v), "")

# ╔═╡ 4c940780-fbd3-44dd-af56-2559809caa73
@test sum_point_tuple((p₁, p₂, p₃)) == Point{Int64,String}(3 + 0im, "")

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╠═9608fdc8-807e-4be2-91f8-950c0ceec2dd
# ╟─82503139-3e37-4bf5-99f6-daf686f591e8
# ╠═25b36455-0e5a-4318-9bd3-0440ac0b0080
# ╠═c07b43bd-4aff-4e0a-9a34-12bc8a49e8ca
# ╟─ced242ca-2352-4b3f-bf32-a095705756ef
# ╠═f886d114-114e-4f66-8d5c-9edd5e1fdfe2
# ╠═81840539-f363-414d-a263-227dcb10abb0
# ╠═bc1b65b1-5063-4567-8928-f9847f0382b4
# ╠═e4d9bae1-1a63-45c6-97a2-9d9fa54f3b54
# ╟─20bdff6e-c631-4de0-8631-9a9de2f82edb
# ╠═d8e2b4db-ec24-411a-9a62-d7f2a6b4d078
# ╟─c2745a46-6258-4b92-b7bb-2a770c9273ec
# ╠═a70143ea-4920-413f-a6c1-515eef6c4f78
# ╟─268af4e1-eb7a-4c0c-959c-c434c8e094b4
# ╠═e9a32b85-e697-4a78-8cbb-0d242e86d8fe
# ╟─d74742e6-1aed-47fa-8c29-0e31c4459e3f
# ╠═6fa1df97-16e4-4b45-814c-cba39ebf9efa
# ╟─224a9eaa-7062-481f-8af3-098ba1988c5d
# ╠═e432f0a0-45de-4f23-aab7-09a30b1b7bdc
# ╟─d7f7ab10-f69b-4143-962c-72ea4b764e40
# ╠═424a9736-1c65-440a-9079-5fd63c74fd50
# ╠═810473f2-d8c2-44e5-811b-185a445694a9
# ╟─4b8455fd-b54c-4eee-8e95-612b3132a0bc
# ╠═87e8df24-dc9d-42bd-a38f-9d5f16533e75
# ╠═cfd030ff-ddc5-46d8-b478-56a87d2f8f11
# ╠═af97433f-e26d-4178-97dd-1f580b9c66d3
# ╟─639755ac-0d13-4087-b632-223ced8d334c
# ╠═6bcfbc7a-fa47-4471-bedc-071bbd58decc
# ╠═cdc06666-2646-46cc-9a45-890ae5c88abe
# ╠═42a5ca4c-cd2c-4ced-a59c-638d7429c2c7
# ╟─03b637ec-6537-4019-9332-a9881a4ad54c
# ╠═3f337631-6d8a-4618-9e9f-a0f0a1eb5438
# ╟─5fc62545-fc1f-4385-9a79-bccdaa665953
# ╠═37a08ce3-7b85-4540-a080-ec1f47c3bf6a
# ╟─122211d1-4ba1-440f-a632-b4b90e47302a
# ╠═428c43cb-2c9b-4c1f-9509-1bd93af3d0bb
# ╠═b3056d5a-7790-4b94-9c77-854087a01cb2
# ╠═b0162138-03e1-4dcc-b76c-073e6bea17d9
# ╟─61a7e87a-9dc1-4519-ad78-51659c383496
# ╟─a29183fa-99eb-4bc9-bffd-4bf8fe1c1cb1
# ╠═43655522-24a7-4497-a305-4cb1a53e8791
# ╟─8a1e851c-8e86-4e56-86be-089667044cd4
# ╠═f40cdaeb-8474-4bae-a46f-44e2199e3712
# ╠═4c940780-fbd3-44dd-af56-2559809caa73
