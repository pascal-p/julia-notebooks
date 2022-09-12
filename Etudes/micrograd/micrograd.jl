### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ bbd26197-1aaa-4869-9bf0-ea04326a0791
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 4544523e-e72d-48ba-8418-655f397145b6
using GraphViz, FileIO, Cairo

# ╔═╡ ab8703e5-e8e8-499d-b4ad-82b4160e4e0d
using Printf

# ╔═╡ a2e926f2-14c2-4fce-a695-f60d2315b929
using Random, Distributions

# ╔═╡ 870398aa-30cc-11ed-3869-f5f7935be279
md"""
## Micrograd

A presentation by Andrej Karpathi on Aug 2022 in [The spelled-out intro to neural networks and backpropagation: building micrograd](https://www.youtube.com/watch?v=VMj-3S1tku0&list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ&index=2)

Links:
 - [micrograd on github](https://github.com/karpathy/micrograd)
 - [Graphviz documentation](https://www.graphviz.org/documentation/)
 - [Julia graphviz](https://github.com/JuliaGraphs/GraphViz.jl)

"""

# ╔═╡ 99bc0941-b430-4e54-b355-63ef2fc6a124
md"""
### Data Structure

--- 
"""

# ╔═╡ 8c19aa91-77a7-46b1-b1ab-e31696924f15
mutable struct Value{T <: Real}
	data::T
	_prev::Set
	_op::Symbol
	_backward::Function
	label::String
	grad::T
	
	function Value{T}(data::T; 
		_children::Tuple=(), 
		_op::Symbol=:_, 
		label::String=""
	) where {T <: Real}
		grad = zero(T)
		_backward = () -> nothing # default to Nothing
		new{T}(data, Set(_children), _op, _backward, label, grad)
	end
end

# ╔═╡ 08edfe4c-c6d5-42ab-973c-34c34bf62f06
import Base: +, -, *, /, ^

# ╔═╡ dbe5cd66-702b-40b0-8134-4d897a7cb05a
const DT = Float64

# ╔═╡ caa3d111-e372-4d1a-ad80-fe041e10d317
# default constructor for Float64
function YaValue(data::T; _children::Tuple=(), _op::Symbol=:_, label::String="") where {T <: Real}
	Value{T}(data; _children, _op, label)
end

# ╔═╡ b5983179-aeb3-4d38-a2fb-2b17522c98a3
function Base.:*(self::Value{T}, other::Value{T}) where {T <: Real}
	y = YaValue(self.data * other.data; _children=(self, other), _op=:*)
	function _backward_fn()
		self.grad += other.data * y.grad
		other.grad += self.data * y.grad
	end
	y._backward = _backward_fn
	y
end

# ╔═╡ 53b65fae-2dca-4f2d-9aa0-388a3a127136
function Base.:+(self::Value{T}, other::Value{T}) where {T <: Real}
	y = YaValue(self.data + other.data; _children=(self, other), _op=:+)
	function _backward_fn()
		self.grad += 1.0 * y.grad
		other.grad += 1.0 * y.grad
	end
	y._backward = _backward_fn
	y
end

# ╔═╡ 11ae3bac-7f86-4435-a087-1eacbdd2945e
Base.show(io::IO, self::Value) = print(io, "Value(data=$(self.data))")

# ╔═╡ 8226ebf4-46eb-4ede-9a26-7dc29f2df38c
function backward(self::Value{T}) where {T <: Real}
	topo, visited = [], Set()
	function build_topological_order(v::Value)
		if v ∉ visited
			push!(visited, v)
			for child ∈ v._prev
				build_topological_order(child)
			end
			push!(topo, v)
		end
	end
	self.grad = 1.0
	for cnode ∈ build_topological_order(self) |> reverse
		cnode._backward()
	end
end

# ╔═╡ 66d05c88-d94a-49d4-8c26-871f7f49a2d8
md"""
--- 
"""

# ╔═╡ 2b382d36-9ccf-4bd1-85b0-318946e6a039
begin
	a = YaValue(2.0; label="a") 
	b = YaValue(-3.0; label="b")
	c = YaValue(10.0; label="c")

	d = a * b; d.label = "d"
	e = d + c; e.label = "e"
	
	f = YaValue(-2.0; label="f")
	L = e * f; L.label="Output"
end

# ╔═╡ c7830bbf-faf4-4994-a340-921167b351d5
d._prev, d._op

# ╔═╡ bdda1937-6719-4f90-b6b0-656e9b20bc12
md"""
### Visualization
"""

# ╔═╡ 102bd441-a350-4360-8ed0-612eae994f80
## for visualization
begin
	function trace(root::Value)
		# builds a set of all nodes and all edges in a graph
		nodes, edges = Set(), Set()
		function build(v::Value)
			if v ∉ nodes
				push!(nodes, v)
				for child ∈ v._prev
					push!(edges, (child, v))
					build(child)
				end
			end
		end
		build(root)
		nodes, edges
	end

	function draw_dot(root::Value)
		gr = """ 
			format=svg;
			rankdir="LR";
			dpi=72;
			bgcolor=lightblue;
			imagepos="mc";
		 	landscape=false;
			mode="hier";
			layout=dot
			node [shape=record];
		""" # Left to Right
		nodes, edges = trace(root)
		for n ∈ nodes
			uid = string(objectid(n))
			gr = string(gr, 
				"""
			   	$(uid) [name=$(uid),label="$(Printf.@sprintf "%s | data: %.4f | grad: %.4f" n.label n.data n.grad)",fontsize=8];
				"""
			)
			if n._op != :_
				gr = string(gr,
					"""
					"$(string(uid, n._op))" [name=$(string(uid)),label="$(string(n._op))",shape="ellipse"];
			   		"$(string(uid, n._op))" -- $(uid) [color=blue,dir=forward];
					"""
				)
			end
		end
		for (n₁, n₂) ∈ edges
			gr = string(gr, 
				"""
				$(string(objectid(n₁))) -- "$(string(objectid(n₂), n₂._op))" [color=blue,dir=forward];
				"""
			)
		end
		gr = string("""graph G {""", gr, """}""")
		# dot"""
		# 	$(gr)
		# """
		open("digraph.dot", "w") do io
			write(io, gr)
		end
		
		open("digraph.dot", "r") do io
	    	GraphViz.load(io)
		end
	end
end

# ╔═╡ 3a83bb02-e9be-4102-a862-5e17abbd6f1c
draw_dot(L)

# ╔═╡ 55e82545-c059-4c82-a301-71100f23b3d7
md"""
### Manual backpropagation and gradient 
"""

# ╔═╡ acf97b23-4113-420a-ad7d-cfaceba84569
md"""
Let's do backpropagation through tanh. So what is $\frac{do}{dn}$ given $o = tanh(n)$?

By definition: $\frac{do}{dn} = 1 - o² = 1 - tanh(n)²$
"""

# ╔═╡ 5230e9a9-c8c4-4507-bbb4-9e549a8d6b48
md"""
### Backpropagation programmatically

Of course, we need to update all arithmetic operations on our datatype. 
"""

# ╔═╡ 51450b56-72c5-496d-9d9b-fcc640b9b15e
md"""
Note: we can backpropagate given an order: the reverse of a topological order of the graph...
"""

# ╔═╡ 75a46369-3c75-4270-808e-70bb5de02f2e
function topological_order(o::Value)
	topo, visited = [], Set()
	function build_topological_order(v::Value)
		if v ∉ visited
			push!(visited, v)
			for child ∈ v._prev
				build_topological_order(child)
			end
			push!(topo, v)
		end
	end
	build_topological_order(o)
end

# ╔═╡ 98e308e4-5f5b-4f75-aec6-d29eb2be6e3f
md"""
After defining the function `backward` on our datatype (`Value`) we can invoke it!

Let's do this...
"""

# ╔═╡ d4bbe45f-a7d9-4bcd-b163-b8d50138a017
begin
	# need to use += in _backward() function on Value type.
	aa = YaValue(-2.0, label="a")
	bb = aa + aa 
	bb.label = "b"
	backward(bb)
	draw_dot(bb)  # double arrow from a to :+ - expected ∇(aa) == 2.  
end

# ╔═╡ 64696b32-a4f2-4601-985f-86b00906bbb1
md"""
### Re-implementing tanh using basic building blocks


#### Julia Apparte - Conversion and Promotion rules
First we want to be able to write something like

```Julia
a = Value(2.0, label="a")
a + 1  # MethodError: no method matching +(...)
```

As it is with our datatype, this is not working because 1 is not a Value it is just an integer.
OK, so let's add some methods (in `Julia` terminology) for our arithmetic operators, namely by adding promotion rules.
"""

# ╔═╡ ce0922f6-2e91-482e-9db7-c0a7f127b075
begin
	import Base: promote_rule, convert
 
 	# these two allow: promote(xr, r) where xr is Value{Float64} and r is Float64 => Value{Float64}
	#                  promote(xi, i) where xi is Value{Int64} and i is Int64 => Value{Int64}
	convert(::Type{Value{T}}, x::T) where {T <: Real} = Value{T}(x)
	promote_rule(::Type{Value{T}}, ::Type{T}) where {T <: Real} = Value{T}

	# Value{Float64} and Float32 => Value{Float64} 
	convert(::Type{Value{T}}, x::S) where {T <: Real, S <: AbstractFloat} = Value{T}(T(x))
	promote_rule(::Type{Value{T}}, ::Type{S}) where {T <: Real, S <: AbstractFloat} = Value{T}

	# Value{Float64} and Integer => Value{Float64} 
	convert(::Type{Value{T}}, x::S) where {T <: Real, S <: Integer} = Value{T}(T(x))
	promote_rule(::Type{Value{T}}, ::Type{S}) where {T <: Real, S <: Integer} = Value{T}

	convert(::Type{Value{T}}, x::Type{Value{S}}) where {T <: Real, S <: T} = Value{T}(T(x.data))
	promote_rule(::Type{Value{T}}, ::Type{Value{S}}) where {T <: Real, S <: T} = Value{promote_type(T, S)}
end

# ╔═╡ 3e1f8cdb-9638-41d1-963e-2eb369f66440
begin
	vf64 = YaValue(2.0, label="vf64")
	vf32 = YaValue(Float32(2.0), label="vf32")
	vi64 = YaValue(2, label="vi64")
	vi32 = YaValue(Int32(2), label="vi32")
	
	typeof(vf64), typeof(vf32), typeof(vi64), typeof(vi32)
end

# ╔═╡ 43b8b610-bfa5-47e4-8445-59170d9b9d71
begin # from Int -> Value{Int}
	i64, i32 = 4, Int32(16)
	promote(vi64, i64), promote(vi64, i32)
end

# ╔═╡ c397358c-b467-46a4-b063-65cf6df76e8a
begin # from Float -> Value{Float}
	f64 = 2.0
	promote(vf64, f64)
end

# ╔═╡ 17ae88d3-ba1c-4146-ada7-316d31491632
begin # from Float32 -> Value{Float64}, Float16 -> Value{Float32} ...
	f32 = Float32(π)
	promote(vf64, f32)
end

# ╔═╡ cd005e82-a71d-4f3f-be87-60834342f935
promote(vf64, i32)  # from Int -> Value{Float}

# ╔═╡ e0f59457-6031-4281-a95c-ce45999b5f4b
##
## Extending operator for DataType Value{T 
##
for op ∈ (:+, :*)
	@eval begin
		## Allowing:
		#   - Value{T} :op T  =>  Value{T}
		#   - T :op Value{T}  =>  Value{T}
		($op)(self::Value{T}, other::T) where {T <: Real} = ($op)(self, Value{T}(other))
		($op)(other::T, self::Value{T}) where {T <: Real} = ($op)(self, Value{T}(other))
		
		# Allowing Value{T} :op S =>  Value{T} where S <: T
		($op)(self::Value{T}, other::S) where {T <: Real, S <: Integer} = 
			($op)(self, Value{T}(T(other)))
		($op)(other::S, self::Value{T}) where {T <: Real, S <: Integer} = 
			($op)(self, Value{T}(T(other)))

		# Allowing Value{T} :op Value{S} =>  Value{T} where S <: T
		($op)(self::Value{T}, other::Value{S}) where {T <: Real, S <: Real} = 
  			($op)(self, Value{T}(T(other.data)))
		($op)(other::Value{S}, self::Value{T}) where {T <: Real, S <: Real} = 
  			($op)(self, Value{T}(T(other.data)))
	end
end

# ╔═╡ ed9e2edb-4052-4a3d-8b7c-5b5bdd42a1d1
vi64 + i64, vi64 + i32, typeof(vi64 + i64), typeof(vi64 + i32)

# ╔═╡ f6dbefe7-1073-41b3-a1cb-72d02a66bea0
vf64 + i64, vf64 + i32, typeof(vf64 + i64), typeof(vf64 + i32)

# ╔═╡ 8518e039-f8c9-45c4-a972-2b421ab46984
vf64 + f64, typeof(vf64), typeof(f64)

# ╔═╡ 296a8bdb-1a49-4ecf-a17f-1cf6971968ba
vf64 + vi64, typeof(vf64), typeof(vi32)  # Value{Float64} + Value{Int64}

# ╔═╡ ffa7cf3f-a937-468f-b48e-9a85a85c01b1
vf64 + vf32, vf32 + vf64, typeof(vf64), typeof(vf32)  # Value{Float64} + Value{Float32}

# ╔═╡ f4241f8b-1189-487c-b256-3f2b196501ef
supertype.((Float32, Float64))

# ╔═╡ 74182a22-4c99-4e79-89ab-ffe7accc3a79
function subtypetree(rtype, level=1, indent=2)
	level == 1 && (println(rtype))
	for st ∈ subtypes(rtype)
		println(string(repeat(" ", level * indent), st))
		subtypetree(st, level + 1, indent)
	end
end

# ╔═╡ 5ee2cc46-ac0b-402e-b922-4e7c4586fc9b
subtypetree(Real)

# ╔═╡ 8bfa956c-40ca-48e4-9deb-a52e54219dbc
# subtypetree(Integer)

# ╔═╡ 3fe857c9-d4b3-41d6-87d6-02048edd74fb
# subtypetree(AbstractFloat)

# ╔═╡ 6401511c-a8e2-4a92-9957-c06bde822c1c
begin
	z₂ = YaValue(2.0)
	2 * z₂
end

# ╔═╡ daa8a844-80f0-4ba4-a54b-9307eaaabc71
md"""
#### tanh in terms of exp.
"""

# ╔═╡ 12405c4b-861d-452e-a998-ca2793c915bc
function Base.exp(self::Value{T}) where {T <: Real}
	x = self.data
	y = YaValue(exp(x); _children=(self, ), _op=:exp, label="exp")
	function _backward_fn()
		self.grad += y.data * y.grad  # because ∂exp/∂x = exp
	end
	y._backward = _backward_fn
	y
end

# ╔═╡ 5fa1b1ce-37fb-4d4f-a861-b1bbb15a4fff
md"""
### More operators
"""

# ╔═╡ 6dc7a448-b2ea-4465-8962-19f36bd41ef2
md"""
Note that a / b == a × 1/b == a × b⁻¹  
"""

# ╔═╡ f11f60dc-4b08-43d3-afb9-cf3f49c0eb07
Base.:-(self::Value{T}, other::Value{T}) where {T <: Real} = Base.:+(self, other * -1.)

# ╔═╡ e5158eed-6895-4752-8e65-2ce71629881b
Base.:-(self::Value{T}, other::S)  where {T <: Real, S <: Real} = Base.:+(self, other * -1.)

# ╔═╡ f63f9d2e-43f2-4fdd-8eee-ec922abd1a39
function Base.:^(self::Value{T}, p::T) where {T <: Real} 
	y = YaValue(self.data^p; _children=(self, ), _op=:^, label="^p")
	function _backward_fn()
		self.grad += p * self.data^(p - 1) * y.grad # because ∂x^p/∂x = p x^(p -1 ) 
	end
	y._backward = _backward_fn
	y
end

# ╔═╡ 42880e3f-7479-4921-bc32-adca1df48efd
Base.:/(self::Value{T}, other::Value{T}) where {T <: Real} = Base.:*(self, other^(-1.)) 

# ╔═╡ b3c4625f-29f3-48e7-927e-4951e0352c97
function Base.tanh(self::Value{T}) where {T <: Real} 
	x = exp(2*self.data)
	tanh = (x - 1.) / (x + 1.)
	y = YaValue(tanh; _children=(self, ), _op=:tanh, label="tanh")
	function _backward_fn()
		self.grad += (1. - tanh^2) * y.grad
	end
	y._backward = _backward_fn
	y
end

# ╔═╡ c4da7d5a-dba3-4242-bb5f-156cde691676
function one_neuron()
	# 2 inputs
	x₁, x₂ = YaValue(2.0; label="x₁"), YaValue(0.0; label="x₂")
	# 2 weights
	w₁, w₂ = YaValue(-3.0; label="w₁"), YaValue(1.0; label="w₂")
	# bias
	b = YaValue(6.8813735870195432; label="b")

	x₁w₁ = x₁ * w₁
	x₁w₁.label = "x₁×w₁"
	x₂w₂ = x₂ * w₂
	x₂w₂.label = "x₂×w₂"

	# x₁w₁ + x₂w₂ + b
	x₁w₁x₂w₂ = x₁w₁ + x₂w₂
	x₁w₁x₂w₂.label = "x₁×w₁ + x₂×w₂"
	n = x₁w₁x₂w₂ + b
	n.label = "n"

	o = tanh(n)
	o.label = "output"
	(o, n, x₁w₁x₂w₂, b, x₁w₁, x₂w₂, x₁, x₂, w₁, w₂)
end

# ╔═╡ db3a36c2-4113-4df7-95f2-d64a42db4ae3
begin
	(o, n, x₁w₁x₂w₂, bias, x₁w₁, x₂w₂, x₁, x₂, w₁, w₂) = one_neuron()
	o.grad = 1.0
	draw_dot(o)
end

# ╔═╡ 7e8a56cd-1cb0-40f0-a163-de0716b1fe02
begin
	n.grad = 1 - o.data^2
	
	# we also can fill in the gradient for x₁w₁x₂w₂, b - applying + rule
	x₁w₁x₂w₂.grad = bias.grad = n.grad

	# and for x₁w₁, x₂w₂ - applying + rule
	x₁w₁.grad, x₂w₂.grad = x₁w₁x₂w₂.grad, x₁w₁x₂w₂.grad
end

# ╔═╡ 3250073d-c4c1-4683-b182-edb953e10a45
x₂.grad, w₂.grad = w₂.data * x₂w₂.grad, x₂.data * x₂w₂.grad

# ╔═╡ 7b7e521b-167a-4bbb-8ea6-c678c74cb557
x₁.grad, w₁.grad = w₁.data * x₁w₁.grad, x₁.data * x₁w₁.grad

# ╔═╡ a9697bad-9dd0-4b54-bed6-4a1f98245711
# redraw graph with gradient updated
draw_dot(o)

# ╔═╡ 251976c2-7609-4e6b-b26d-042651c01a06
begin
	(o₃, _rest_) = one_neuron() 
	backward(o₃)
	draw_dot(o₃)
end

# ╔═╡ 237f80c7-755e-450d-8b3b-8173914de65a
function backprop_one_neuron()
	# 2 inputs
	x₁, x₂ = YaValue(2.0; label="x₁"), YaValue(0.0; label="x₂")
	# 2 weights
	w₁, w₂ = YaValue(-3.0; label="w₁"), YaValue(1.0; label="w₂")
	# bias
	b = YaValue(6.8813735870195432; label="b")

	x₁w₁ = x₁ * w₁
	x₁w₁.label = "x₁×w₁"
	x₂w₂ = x₂ * w₂
	x₂w₂.label = "x₂×w₂"

	# x₁w₁ + x₂w₂ + b
	x₁w₁x₂w₂ = x₁w₁ + x₂w₂
	x₁w₁x₂w₂.label = "x₁×w₁ + x₂×w₂"
	n = x₁w₁x₂w₂ + b
	n.label = "n"

	o = tanh(n)
	o.label = "output"
	# (o, n, x₁w₁x₂w₂, b, x₁w₁, x₂w₂, x₁, x₂, w₁, w₂)	
	
	# and now the backward pass
	o.grad = 1.0
	o._backward()
	n._backward()
	x₁w₁x₂w₂._backward()
	x₁w₁._backward()
	x₂w₂._backward()
	# b._backward()
	o
end

# ╔═╡ 4c71c0fa-801d-4f24-b385-b9ec6f275841
begin
	o₁ = backprop_one_neuron()
	draw_dot(o₁)	
end

# ╔═╡ e99517de-a342-4c93-8237-a3ed4ed36fa9
topological_order(o₁)

# ╔═╡ bf1e7d64-d5b8-4d09-a4a9-2fca20abc05d
function auto_backprop_one_neuron()
	# 2 inputs
	x₁, x₂ = YaValue(2.0; label="x₁"), YaValue(0.0; label="x₂")
	# 2 weights
	w₁, w₂ = YaValue(-3.0; label="w₁"), YaValue(1.0; label="w₂")
	# bias
	b = YaValue(6.8813735870195432; label="b")

	# forward pass
	x₁w₁ = x₁ * w₁
	x₁w₁.label = "x₁×w₁"
	x₂w₂ = x₂ * w₂
	x₂w₂.label = "x₂×w₂"

	# x₁w₁ + x₂w₂ + b
	x₁w₁x₂w₂ = x₁w₁ + x₂w₂
	x₁w₁x₂w₂.label = "x₁×w₁ + x₂×w₂"
	n = x₁w₁x₂w₂ + b
	n.label = "n"

	o = tanh(n)
	o.label = "output"
	
	
	# and now the backward pass, using reverse order of the graph's topological order
	o.grad = 1.0
	for cnode ∈ topological_order(o) |> reverse
		cnode._backward()
	end
	o
end

# ╔═╡ 0d9b8cf7-459e-4c99-9c26-a1030e12c821
begin
	o₂ = auto_backprop_one_neuron()
	draw_dot(o₂)	
end

# ╔═╡ f996e2ff-4d4e-45ce-83e1-bc9749e8cb32
function try_grad()
	h = 0.001
	
	a = YaValue(2.0; label="a")
	b = YaValue(-3.0; label="b")
	c = YaValue(10.0; label="c")
	f = YaValue(-2.0; label="f")
	# compose
	d = a * b; d.label = "d"
	e = d + c; e.label = "e"
	L = e * f; L.label="Output"

	a₁ = YaValue(a.data; label="a")
	b₁ = YaValue(b.data; label="b")
	c₁ = YaValue(c.data; label="c")
	f₁ = YaValue(f.data; label="f")
	# compose
	d₁ = a₁ * b₁; d₁.label = "d"
	d₁.data += h
	e₁ = d₁ + c₁; e₁.label = "e"
	L₁ = e₁ * f₁; L₁.label="Output"

	Δh = (L₁.data - L.data) / h 
end

# ╔═╡ 93144f22-e9ce-4d7f-9ef7-7f223f435421
# got 7 var => 
try_grad()

# ╔═╡ 9e5bb9f5-72a0-4008-a3ea-6b3b3ba1b4d6
z₂ / YaValue(4.0), z₂ - YaValue(5.0), YaValue(5.0) - 2

# ╔═╡ 6d64e78e-4042-4d66-b60e-46c3afc3454e
function one_neuron_alt()
	# 2 inputs
	x₁, x₂ = YaValue(2.0; label="x₁"), YaValue(0.0; label="x₂")
	# 2 weights
	w₁, w₂ = YaValue(-3.0; label="w₁"), YaValue(1.0; label="w₂")
	# bias
	b = YaValue(6.8813735870195432; label="b")

	x₁w₁ = x₁ * w₁
	x₁w₁.label = "x₁×w₁"
	x₂w₂ = x₂ * w₂
	x₂w₂.label = "x₂×w₂"

	# x₁w₁ + x₂w₂ + b
	x₁w₁x₂w₂ = x₁w₁ + x₂w₂
	x₁w₁x₂w₂.label = "x₁×w₁ + x₂×w₂"
	n = x₁w₁x₂w₂ + b
	n.label = "n"

	# ------------------------------
	# o = tanh(n)
	e = exp(2 * n)
	o = (e - 1) / (e + 1)
	o.label = "output"
	# ------------------------------
	# (o, n, x₁w₁x₂w₂, b, x₁w₁, x₂w₂, x₁, x₂, w₁, w₂)
	o
end

# ╔═╡ adf5f57c-9fc2-49fd-9245-2e60edfc37a2
begin
	o₄ = one_neuron_alt()
	backward(o₄)
	draw_dot(o₄)
end

# ╔═╡ 57f6c9b7-a124-4fd9-bb59-ceccafd56f25
md"""
### Implementing a MLP
"""

# ╔═╡ b3574970-a905-4d7e-8289-a91d3cd611d1
md"""
#### Neuron Datatype
"""

# ╔═╡ afc983e6-bd8c-4725-a0bd-076d2bc201c4
Random.seed!(42)

# ╔═╡ e6eb2850-600e-4008-a412-599fa5d14257
# const uniform_d = Uniform(-1, 1) # = Distributions.Uniform{Float64}(a=-1.0, b=1.0)

# ╔═╡ 63b6b64e-9eab-4e64-a83c-c8a786898764
# const uniform_df32 = Uniform{Float32}(-1, 1) # = Distributions.Uniform{Float32}(a=-1.0f0, b=1.0f0)

# ╔═╡ e03f249f-6aa9-4b6e-aaad-b544bc52964d
# const NT = rand(uniform_d, 1) |> eltype # = Float64

# ╔═╡ 03e5fd6e-0168-4d3b-b5b4-5e44c3fe7322
struct Neuron{T <: AbstractFloat}
	w::Vector{Value{T}}
	b::Value{T}

	function Neuron{T}(n_inp::Integer; dist=Uniform{T}(-1., 1.)) where {T <: AbstractFloat}
		@assert n_inp ≥ 1
		w = Value{T}.(rand(dist, n_inp))
		b = Value{T}(rand(dist, 1)[1])
		new(w, b)
	end

	function Neuron{Float32}(n_inp::Integer; dist=Uniform{Float32}(-1., 1.))
		@assert n_inp ≥ 1
		w = [Value{Float32}(Float32(rand(dist, n_inp)[1])) for _ ∈ 1:n_inp]
		b = Value{Float32}(Float32(rand(dist, 1)[1]))
		new(w, b)
	end
end

# ╔═╡ 4d90574d-5b26-4391-b1cd-568e2db45158
Neuron_f64(n_inp::Integer) = Neuron{Float64}(n_inp)

# ╔═╡ 82383a21-730c-4380-9448-274c5a6adca4
#
## not working as rand will return float64
#
# function Neuron_f32(n_inp::Integer)
# 	DT = Float32
# 	Neuron{DT}(n_inp; dist=Uniform{DT}(-1., 1.))
# end

# ╔═╡ 52c45b00-c029-459e-9036-5b302165fe3c
n₁ = Neuron_f64(4)

# ╔═╡ 6461d1dd-d2cd-4b0c-b0b8-9d358a504718
n₂ = Neuron{Float32}(4)

# ╔═╡ b918dadc-ed55-4994-9bcb-5fb0ff00189d
n₂.w[1].data |> typeof, n₁.w[1].data |> typeof

# ╔═╡ fb2f2a82-4544-4a66-9171-dfb4e288260c
UVT{T} = Union{Vector{T}, Vector{Value{T}}} where {T <: AbstractFloat}

# ╔═╡ 8c7322ee-d6db-49fc-90fa-1dc9caa9842d
"""
    forward(...)
    eval neuron by taking the dot-product between input and weights, sum, add bias and pass it to activation function
"""
function forward(self::Neuron{T}, x::UVT{T}; act_fn=tanh) where {T <: AbstractFloat}
	# x == vector of inputs
	@assert length(self.w) >= 1 && length(self.w) == length(x)
	self.w .* x |> d -> sum(d; init=self.b) |> act_fn
end

# ╔═╡ aa193df7-aafe-4529-a4a5-6b2effac23c1
md"""
#### Layer Datatype
"""

# ╔═╡ 281046da-e4ef-4afb-a058-4d1aba0b9da9
struct Layer{T <: AbstractFloat}
	neurons::Vector{Neuron{T}}

	function Layer{T}(n_inp::Integer, n_out::Integer) where {T <: AbstractFloat}
		@assert n_inp ≥ 1 && n_out ≥ 1
		vn = [Neuron{T}(n_inp) for _ ∈ 1:n_out]
		new(vn)
	end
end

# ╔═╡ 7138d45e-ce2b-4aa6-a0ba-27a7f3ab29bc
function forward(self::Layer{T}, x::UVT{T}) where {T <: AbstractFloat}
	y = [forward(n, x) for n ∈ self.neurons]
	length(y) == 1 ? y[1] : y
end

# ╔═╡ 5d4a5da6-6dae-46e1-b786-73a749bff1e8
md"""
#### MLP Datatype
"""

# ╔═╡ b438fad8-2691-4475-b26b-65fc1ada66a9
struct MLP{T <: AbstractFloat}
	layers::Vector{Layer{T}}

	function MLP{T}(n_inp::Integer, n_outs::Vector{<: Integer}) where {T <: AbstractFloat}
		@assert n_inp ≥ 1 && length(n_outs) ≥ 1
		sz = [n_inp, n_outs...]
		layers = [Layer{T}(sz[ix], sz[ix + 1]) for ix ∈ 1:length(n_outs)]
		new(layers)
	end
end

# ╔═╡ 0ac8efb9-4aaf-4a8d-ad79-eb7be8e4eb48
function forward(self::MLP{T}, x::UVT{T}) where {T <: AbstractFloat}
	for layer ∈ self.layers
		x = forward(layer, x) # mutate x
	end
	x
end

# ╔═╡ d140e239-35e6-460b-af10-283f83dede85
forward(n₁, [1., 2., 3., 4.])

# ╔═╡ c75b08a7-8250-4d85-bd83-19e04e09457f
begin
	xx₁ = [1.1, 2.0]
	nl₁ = Layer{Float64}(2, 3)  # 2 inputs, 3 outputs 
	forward(nl₁, xx₁)
end

# ╔═╡ ebb36172-1d50-41d5-b14c-a566ffe126b5
begin
	mlp_x = [2.0, 3.4, -1.0]          # inputs
	mlp = MLP{Float64}(3, [4, 4, 1])  # input 3 neurons, 2 hidden with 4 neurons each, 1 output neuron
	oₓ = forward(mlp, mlp_x)
end

# ╔═╡ b0197278-4ed8-4df9-a31a-ac10d61c51c2
draw_dot(oₓ)

# ╔═╡ b221641d-8e86-4300-a281-e41cbb68798d
# TBD examples, loss, backprop

# ╔═╡ a5e92195-d95e-4723-9c80-8d690517d1dd
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
Cairo = "159f3aea-2a34-519c-b102-8c37f9878175"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
GraphViz = "f526b714-d49f-11e8-06ff-31ed36ee7ee0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Cairo = "~1.0.5"
Distributions = "~0.25.70"
FileIO = "~1.15.0"
GraphViz = "~0.2.0"
PlutoUI = "~0.7.40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "aa2433613f731ea1a1cc6879dbcb48cffa1474b0"

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

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dc4405cee4b2fe9e1108caec2d760b7ea758eca2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.5"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "8579b5cdae93e55c0cff50fbb0c2d1220efd5beb"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.70"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "94f5101b96d2d968ace56f7f2db19d0a5f592e28"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.15.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.GraphViz]]
deps = ["FileIO", "Graphviz_jll", "Requires"]
git-tree-sha1 = "da5580b236c5b6bb634e96ca35dcd7eaeeac1bd1"
uuid = "f526b714-d49f-11e8-06ff-31ed36ee7ee0"
version = "0.2.0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphviz_jll]]
deps = ["Artifacts", "Cairo_jll", "Expat_jll", "JLLWrappers", "Libdl", "Pango_jll", "Pkg"]
git-tree-sha1 = "a5d45833dda71048117e8a9828bef75c03b18b1c"
uuid = "3c863552-8265-54e4-a6dc-903eb78fde85"
version = "2.50.0+1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

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

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a121dfbba67c94a5bec9dde613c3d0cbcf3a12b"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.3+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

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

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

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
# ╟─870398aa-30cc-11ed-3869-f5f7935be279
# ╠═bbd26197-1aaa-4869-9bf0-ea04326a0791
# ╟─99bc0941-b430-4e54-b355-63ef2fc6a124
# ╠═8c19aa91-77a7-46b1-b1ab-e31696924f15
# ╠═08edfe4c-c6d5-42ab-973c-34c34bf62f06
# ╠═dbe5cd66-702b-40b0-8134-4d897a7cb05a
# ╠═caa3d111-e372-4d1a-ad80-fe041e10d317
# ╠═53b65fae-2dca-4f2d-9aa0-388a3a127136
# ╠═b5983179-aeb3-4d38-a2fb-2b17522c98a3
# ╠═11ae3bac-7f86-4435-a087-1eacbdd2945e
# ╠═b3c4625f-29f3-48e7-927e-4951e0352c97
# ╠═8226ebf4-46eb-4ede-9a26-7dc29f2df38c
# ╟─66d05c88-d94a-49d4-8c26-871f7f49a2d8
# ╠═2b382d36-9ccf-4bd1-85b0-318946e6a039
# ╠═c7830bbf-faf4-4994-a340-921167b351d5
# ╟─bdda1937-6719-4f90-b6b0-656e9b20bc12
# ╠═4544523e-e72d-48ba-8418-655f397145b6
# ╠═ab8703e5-e8e8-499d-b4ad-82b4160e4e0d
# ╠═102bd441-a350-4360-8ed0-612eae994f80
# ╠═3a83bb02-e9be-4102-a862-5e17abbd6f1c
# ╟─55e82545-c059-4c82-a301-71100f23b3d7
# ╠═f996e2ff-4d4e-45ce-83e1-bc9749e8cb32
# ╠═93144f22-e9ce-4d7f-9ef7-7f223f435421
# ╠═c4da7d5a-dba3-4242-bb5f-156cde691676
# ╠═db3a36c2-4113-4df7-95f2-d64a42db4ae3
# ╟─acf97b23-4113-420a-ad7d-cfaceba84569
# ╠═7e8a56cd-1cb0-40f0-a163-de0716b1fe02
# ╠═3250073d-c4c1-4683-b182-edb953e10a45
# ╠═7b7e521b-167a-4bbb-8ea6-c678c74cb557
# ╠═a9697bad-9dd0-4b54-bed6-4a1f98245711
# ╟─5230e9a9-c8c4-4507-bbb4-9e549a8d6b48
# ╠═237f80c7-755e-450d-8b3b-8173914de65a
# ╠═4c71c0fa-801d-4f24-b385-b9ec6f275841
# ╟─51450b56-72c5-496d-9d9b-fcc640b9b15e
# ╠═75a46369-3c75-4270-808e-70bb5de02f2e
# ╠═e99517de-a342-4c93-8237-a3ed4ed36fa9
# ╠═bf1e7d64-d5b8-4d09-a4a9-2fca20abc05d
# ╠═0d9b8cf7-459e-4c99-9c26-a1030e12c821
# ╟─98e308e4-5f5b-4f75-aec6-d29eb2be6e3f
# ╠═251976c2-7609-4e6b-b26d-042651c01a06
# ╠═d4bbe45f-a7d9-4bcd-b163-b8d50138a017
# ╟─64696b32-a4f2-4601-985f-86b00906bbb1
# ╠═ce0922f6-2e91-482e-9db7-c0a7f127b075
# ╠═3e1f8cdb-9638-41d1-963e-2eb369f66440
# ╠═43b8b610-bfa5-47e4-8445-59170d9b9d71
# ╠═c397358c-b467-46a4-b063-65cf6df76e8a
# ╠═17ae88d3-ba1c-4146-ada7-316d31491632
# ╠═cd005e82-a71d-4f3f-be87-60834342f935
# ╠═e0f59457-6031-4281-a95c-ce45999b5f4b
# ╠═ed9e2edb-4052-4a3d-8b7c-5b5bdd42a1d1
# ╠═f6dbefe7-1073-41b3-a1cb-72d02a66bea0
# ╠═8518e039-f8c9-45c4-a972-2b421ab46984
# ╠═296a8bdb-1a49-4ecf-a17f-1cf6971968ba
# ╠═ffa7cf3f-a937-468f-b48e-9a85a85c01b1
# ╠═f4241f8b-1189-487c-b256-3f2b196501ef
# ╠═74182a22-4c99-4e79-89ab-ffe7accc3a79
# ╠═5ee2cc46-ac0b-402e-b922-4e7c4586fc9b
# ╠═8bfa956c-40ca-48e4-9deb-a52e54219dbc
# ╠═3fe857c9-d4b3-41d6-87d6-02048edd74fb
# ╠═6401511c-a8e2-4a92-9957-c06bde822c1c
# ╟─daa8a844-80f0-4ba4-a54b-9307eaaabc71
# ╠═12405c4b-861d-452e-a998-ca2793c915bc
# ╟─5fa1b1ce-37fb-4d4f-a861-b1bbb15a4fff
# ╟─6dc7a448-b2ea-4465-8962-19f36bd41ef2
# ╠═42880e3f-7479-4921-bc32-adca1df48efd
# ╠═f63f9d2e-43f2-4fdd-8eee-ec922abd1a39
# ╠═f11f60dc-4b08-43d3-afb9-cf3f49c0eb07
# ╠═e5158eed-6895-4752-8e65-2ce71629881b
# ╠═9e5bb9f5-72a0-4008-a3ea-6b3b3ba1b4d6
# ╠═6d64e78e-4042-4d66-b60e-46c3afc3454e
# ╠═adf5f57c-9fc2-49fd-9245-2e60edfc37a2
# ╟─57f6c9b7-a124-4fd9-bb59-ceccafd56f25
# ╟─b3574970-a905-4d7e-8289-a91d3cd611d1
# ╠═a2e926f2-14c2-4fce-a695-f60d2315b929
# ╠═afc983e6-bd8c-4725-a0bd-076d2bc201c4
# ╠═e6eb2850-600e-4008-a412-599fa5d14257
# ╠═63b6b64e-9eab-4e64-a83c-c8a786898764
# ╠═e03f249f-6aa9-4b6e-aaad-b544bc52964d
# ╠═03e5fd6e-0168-4d3b-b5b4-5e44c3fe7322
# ╠═4d90574d-5b26-4391-b1cd-568e2db45158
# ╠═82383a21-730c-4380-9448-274c5a6adca4
# ╠═52c45b00-c029-459e-9036-5b302165fe3c
# ╠═6461d1dd-d2cd-4b0c-b0b8-9d358a504718
# ╠═b918dadc-ed55-4994-9bcb-5fb0ff00189d
# ╠═fb2f2a82-4544-4a66-9171-dfb4e288260c
# ╠═8c7322ee-d6db-49fc-90fa-1dc9caa9842d
# ╠═d140e239-35e6-460b-af10-283f83dede85
# ╟─aa193df7-aafe-4529-a4a5-6b2effac23c1
# ╠═281046da-e4ef-4afb-a058-4d1aba0b9da9
# ╠═7138d45e-ce2b-4aa6-a0ba-27a7f3ab29bc
# ╠═c75b08a7-8250-4d85-bd83-19e04e09457f
# ╟─5d4a5da6-6dae-46e1-b786-73a749bff1e8
# ╠═b438fad8-2691-4475-b26b-65fc1ada66a9
# ╠═0ac8efb9-4aaf-4a8d-ad79-eb7be8e4eb48
# ╠═ebb36172-1d50-41d5-b14c-a566ffe126b5
# ╠═b0197278-4ed8-4df9-a31a-ac10d61c51c2
# ╠═b221641d-8e86-4300-a281-e41cbb68798d
# ╟─a5e92195-d95e-4723-9c80-8d690517d1dd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
