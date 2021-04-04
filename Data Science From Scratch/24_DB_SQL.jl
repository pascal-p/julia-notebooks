### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ de098278-8e74-11eb-13e3-49c1b6e06e7d
using Pkg; Pkg.activate("MLJ_env", shared=true)

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
	using Test
	using PlutoUI
end

# ╔═╡ 8c80e072-8b59-11eb-3c21-a18fe43c4536
md"""
## Databases and SQL

ref. from book **"Data Science from Scratch"**, Chap 24
"""

# ╔═╡ e7373726-8b59-11eb-2a2b-b5138e4f5268
html"""
<a id='toc'></a>
"""

# ╔═╡ f5ee64b2-8b59-11eb-2751-0778efd589cd
md"""
#### TOC
  - [Create table and insert rows](#create-insert)
  - [Update](#update)
  - [Delete](#delete)
  - [Select](#select)
  - [Group by](#group-by)
  - [Order by](#order-by)
  - [Join](#join)
"""

# ╔═╡ 81290d1c-8ce2-11eb-3340-337957fd81b7
html"""
<p style="text-align: right;">
  <a id='create-insert'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 8ff1bb20-8ce2-11eb-1de6-fd84daec8930
md"""
#### Create table and insert rows

"""

# ╔═╡ d3ee2138-8ce2-11eb-0b29-659a3be01512
md"""
We will represent our table in memory by a dictionary (not really space efficient).   

Also, we will:
  - Support the primary key for our table (some table do not and will not have a primary key).
  - Allow for NULL value for any column of our table (but for the primary key).
"""

# ╔═╡ 6d759180-928b-11eb-1cc1-0593c7f3b0c2
begin
	const Row = Dict{Symbol, Any}
	const GRow = Union{Row, Vector{Pair{Symbol, Any}}, Vector{Any}}  ## Generic Row
	const WhereClause = Function
	const HavingClause = Function
	const S_N = Union{Symbol, Nothing}
	# const PK = Pair{S_N, DataType}
	const D_SF = Dict{Symbol, Function}
	const U_IN = Union{Int, Nothing}
	const U_SN = Union{String, Nothing}
	const UDT = Union{Union, DataType, Type};
end

# ╔═╡ 2e8684fc-2ba6-48ec-81b3-f1c31cdde43a
md"""
Let us define our custom type for a relational table:
"""

# ╔═╡ 53accaea-92d4-11eb-0bc2-3d2ee10f9bfb
mutable struct Table
	columns::Vector{Symbol}
	types::Vector{UDT}
	pkey::Union{Symbol, Nothing}
	rows::Vector{Row}
	
  function Table(col_types::Vector{Pair{Symbol, DT}};
               pkey::Pair=(:id => Int)) where DT <: UDT
    # vector of pairs keeps implicit order
    @assert length(col_types) ≥ 1
    #
    cols = map(((k, _)=p) -> k, col_types)
    types = map(((_, v)=p) -> v, col_types)
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey.first, Vector{Row}[])
  end

  function Table(cols::Vector{Symbol}, types::Vector{DT};
               pkey::Pair=(:id => Int)) where DT <: UDT
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey.first, Vector{Row}[])
  end
end

# ╔═╡ 1b1b8d8c-3803-43fa-b3af-7a58d75bb13b
md"""
And let us start developing our API and utilities:
"""

# ╔═╡ 6f9c58d4-92d1-11eb-2c09-cb1ea5afcd6d
begin
	import Base: length
	##
	## API for Table
	##

	id(self::Table) = self.pkey

	length(self::Table) = length(self.rows)

	function gen_pkey_value(self::Table)
	  """
	  Assuming pkey is instance of a numeric type
	  """
	  length(self.rows) == 0 && (return 1)
	  (map(r -> r[id(self)], self.rows) |> maximum)  + 1
	end

	## utility
	function check_pk(cols, types, pkey)
	  if pkey.first !== nothing
		@assert pkey[2] <: Integer "Expecting an Integer, got: $(pkey[2])"
	  end

	  if pkey.first !== nothing && pkey.first ∉ cols
		cols  = [pkey[1], cols...]
		types = [pkey[2], types...]
	  end
	  (cols, types)
	end
end

# ╔═╡ 040a7354-92d2-11eb-2825-7bac34b9fdf9
YaUsers = Table([:name => String, :num_friends => Int];
	pkey=(:user_id => Int32))

# ╔═╡ 17d214a7-be15-4236-a614-3127b535ef66
AltUsers = Table([:name => String, :num_friends => Int]) ## Default pkey

# ╔═╡ 85211d8a-be50-454d-a6c5-cd820a20f8d4
## Default pkey and NULL values allowed
AltUsers₂ = Table([:name, :num_friends], [U_SN, U_IN])

# ╔═╡ adf67244-92d4-11eb-3004-41e62e906e32
begin
	##
	## Convention: by default all tables have a primary key called :id,
	## unless explicitly stated otherwise, something like:
	##   :pkey => (:user_id, Int)
	##
	Users = Table([:name => U_SN, :num_friends => U_IN];
		pkey=(:user_id => Int))
	@assert length(Users) == 0
	Users;
end

# ╔═╡ 650237ee-928e-11eb-0e43-17ab98a0cc11
begin
	##
	## API for Table (cont'ed)
	##

	function insert(self::Table, row::Vector{Pair{Symbol, DT}}) where DT <: Any
	  """
	  row is something like [:name => "FooBar", :num_friends => 3, id(Users) => 3]
	  """
	  res = filter(p -> p.first == id(self), row)
	  has_pkey = length(res) > 0
	  ##
	  ## NULL values permitted
	  #length(row) ≠ length(self.types) && has_pkey &&
	  #  throw(ArgumentError("Mismatch with expected number of columns"))
	  ##
	  check_value_dtype(self, row)
	  ## find the pair <pkey, value> pkey is given by id(self)
	  row_ids = filter(p -> p.first == id(self), row)
	  if length(row_ids) == 0
		pk_id =  gen_pkey_value(self)
		row = [row..., id(self) => pk_id]
	  else
		id_val = row_ids[1][2]  ## value assoc with this pkey
		row_already_inserted(self, id_val) && (return nothing)
	  end
	  push!(self.rows, Dict(row...))
	end

	function insert(self::Table, row::Vector{Any})
	  """
	  row is something like: [9, "Foo", 2 ] - just pure values
	  """
	  length(row) ≠ length(self.types) && id(self) ∈ map(p -> p[1], row) &&
		throw(ArgumentError("Mismatch with expected number of columns "))
	  #
	  check_value_dtype(self, row)
	  ## row[1] is the value assoc. with pkey
	  row_already_inserted(self, row[1]) && (return nothing)
	  push!(self.rows, Dict(zip(self.columns, row)))
	end

	function insert(self::Table, row::Row)
	  """
	  row is a  Dict, like: insert(Users, Dict(:name => "Foo", :num_friends => 5))
	  """
	  length(row) ≠ length(self.types) && haskey(row, id(self)) &&
		throw(ArgumentError("Mismatch with expected number of columns"))
	  check_value_dtype(self, row)
	  if haskey(row, id(self))
		row_already_inserted(self, row[id(self)]) && (return nothing)
	  else
		row[id(self)] = gen_pkey_value(self)
	  end
	  push!(self.rows, row)
	end

	insert(self::Table, rows::Vector{T}) where T <: GRow = insert.(Ref(self), rows)

	function coltype(self::Table, colname::Symbol)::UDT
	  ix = findfirst(col -> col == colname, self.columns)
	  ix === nothing && throw(ArgumentError("column $(colname) inexistent"))
	  self.types[ix]
	end

	# function Base.show(io::IO, self::Table)
	# 	s = "num. records: $(length(self)):\n"
	# 	for rd ∈ self.rows
	# 		s₁ = []
	# 		for (k, v) ∈ rd
	# 			push!(s₁, "$(k): $(v)")
	# 		end
	# 		s = string(s, "  <", join(s₁, ", "), ">\n")
	# 	end
	# 	print(io, "$(s)")
	# end


	##
	## Internal checkers
	##

	function check_value_dtype(self::Table, values::Vector{DT}) where DT <: Any
	  dtypes = self.types
	  for (v, dt) ∈ zip(values, dtypes)
		!(typeof(v) <: dt) && v !== nothing &&
		  throw("Expected type for <$(v)>: $(dt), got: $(typeof(v))")
	  end
	end


	function check_value_dtype(self::Table,
							   row::Union{Row, Vector{Pair{Symbol, DT}}}) where DT <: Any
	  (cols, types) = self.columns, self.types
	  col_type = Dict(zip(cols, types))
	  for (k, v) ∈ row
		(haskey(col_type, k) && typeof(v) <: col_type[k]) ||
		  throw("Expected type/2: $(col_type[k]), got: $(typeof(v))")
	  end
	end

	function row_already_inserted(self::Table, id_val::Any)::Bool
		id(self) === nothing && return false  ## no pkey => ignore check
		#
		res = filter(r -> r[id(self)] == id_val, self.rows)
		length(res) > 0    ## row already inserted id > 0
	end

end

# ╔═╡ d146a8ac-92cc-11eb-29b1-bb065a468477
md"""
Insert using an array/vector:
"""

# ╔═╡ 13a0940e-8ce4-11eb-231c-f331a607203c
begin
	insert(Users, [0, "Hero", 0])
	@assert length(Users) ≥ 1
end

# ╔═╡ e3458d34-92cc-11eb-2426-79f229abd908
md"""
Insert using a vector of pairs:
"""

# ╔═╡ 96c2a668-9290-11eb-074d-19ffeb68eba6
begin
	insert(Users, [id(Users) => 1, :name => "Dunn", :num_friends => 2])
	@assert length(Users) ≥ 2
end

# ╔═╡ f1357972-92cc-11eb-1f73-43aae5a43aa5
md"""
Insert using a dictionary
"""

# ╔═╡ 5a3a8fdc-929d-11eb-25e3-e309dffdb455
begin
	## Insert with a Dict
	insert(Users, Dict(id(Users) => 2, :name => "Sue", :num_friends => 3))
	@assert length(Users) ≥ 3
end

# ╔═╡ 0292e48e-92cd-11eb-1882-81a2faaad136
md"""
Insert using a dictionary, no primary key value specified:
"""

# ╔═╡ 8545d17c-929e-11eb-0989-ffd4749bbb25
begin
	## Insert with a Dict no pkey/1
	insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
	@assert length(Users) ≥ 4
end

# ╔═╡ 95d2b19e-92a4-11eb-0f91-e343c9317983
begin
	## Insert with a Dict no pkey/2
	insert(Users, [:name => "PasMas", :num_friends => 5])
	@assert length(Users) ≥ 5
end

# ╔═╡ 8a945abc-012f-4ace-a67a-b7e0f520346b
begin
	## Insert with a Dict no pkey/2 + null value (encoded as nothing)
	# insert(Users,
	# 	[:name => "Foobar", :num_friends => nothing])
	insert(Users,
		[:name => "Foobar", :num_friends => nothing, :user_id => 17])
end

# ╔═╡ 28ba0bf6-92cd-11eb-0669-75eadb768518
md"""
Insert using a collection (vector of rows):
"""

# ╔═╡ d4562f7e-9290-11eb-2d8c-952f2e0edfed
begin
	## Insert a collection (Vector of) of Records 
	insert(Users, [
		[5, "Chi", 3],
		[6, "Thor", 3],
		[7, "Clive", 2],
		[8, "Devin", 2],
		[9, "Kate", 2],
		[10, "Kaze", nothing]
	])
	@assert length(Users) ≥ 10
end

# ╔═╡ f877c3e6-929c-11eb-00cd-c15568f99627
Users

# ╔═╡ d5657a88-92c4-11eb-2a4f-c7dcaa97bcf6
begin
	@test_throws ArgumentError  coltype(Users, :foobar)
	@test coltype(Users, :num_friends) == U_IN
	@test coltype(Users, :name) == U_SN
end

# ╔═╡ 80ddf0f4-8ce2-11eb-3046-331119a0dc9b
html"""
<p style="text-align: right;">
  <a id='update'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 80a71408-8ce2-11eb-3978-75a4a2df9116
md"""
#### Update
"""

# ╔═╡ d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
md"""
The key features for an update:
  - what table,
  - which fields/rows 
  - what their new values will be
"""

# ╔═╡ 4ccdb1ce-92c2-11eb-18dd-c510e88474c6
##
## API (cont'ed)
##
function update(self::Table, updates::Row, pred::WhereClause=row -> true)
	## 1 - Make sure key/columns and values are consistent with column types
	for (col, val) ∈ updates
		col ∉ self.columns && throw(ArgumentError("invalid column $(col)"))
		col_type = coltype(self, col)
		!(typeof(val) <: col_type) && val !== nothing && 
			throw(ArgumentError("Expected $(col_type), got $(typeof(val))"))
	end

	## 2 - OK, update
	rows_to_update = filter(((ix, r)=t) -> pred(r), collect(enumerate(self.rows)))
	for (ix, row) ∈ rows_to_update
		# self.rows[ix] = Row(row..., updates...)
		for (k, v) ∈ updates
			self.rows[ix][k] = v
		end
	end
	nothing
end

# ╔═╡ 2af6dbec-92c6-11eb-1155-596ed44b04f8
begin
	update(Users, Dict{Symbol, Any}(:num_friends => 7),
		row -> row[:name] == "Ayumi")
	Users
end

# ╔═╡ 2abb0114-92c6-11eb-01d5-cd34aa6426b2
begin
	update(Users, Dict{Symbol, Any}(:num_friends => 4), row -> row[:num_friends] == 2)
	Users
end

# ╔═╡ bc1fb8d2-92ca-11eb-14e0-c9586461bc1e
begin
	update(Users, Dict{Symbol, Any}(:num_friends => 1))
	Users
end

# ╔═╡ d2b198b6-8ce2-11eb-170e-0f17904c9f2c
html"""
<p style="text-align: right;">
  <a id='delete'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d37f37b8-8ce8-11eb-2c00-3f98ca407f41
md"""
#### Delete
"""

# ╔═╡ 5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
##
## API (cont'ed)
##
function delete(self::Table, pred::WhereClause=row -> true)|
	self.rows = [
		row for row ∈ self.rows if !pred(row)
	]
	nothing
end

# ╔═╡ 394093fa-8cea-11eb-0071-eff3045a012b
begin
	n = length(Users)
	delete(Users, row -> row[id(Users)] == 1)
	@assert length(Users) == n - 1
end

# ╔═╡ 435c4444-8dfd-11eb-24e8-5543f905f199
begin
	delete(Users)
	@assert length(Users) == 0
end

# ╔═╡ e95983ba-8ceb-11eb-38fd-ed92cdcf754c
html"""
<p style="text-align: right;">
  <a id='select'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d3a749a2-8cec-11eb-1f06-b568f244b576
md"""
#### Select
"""

# ╔═╡ 31d3226a-8cf4-11eb-0897-39989ba76b58
md"""
We will give our Table struct a select method that returns a new Table . The
method accepts two optional arguments:
  - `keep_cols` which specifies the names of the columns we want to
keep in the result. if none supply, the result contains all the columns, and

  - `add_cols` is a dictionary whose keys are new column names and whose values are functions specifying how to compute the values of the new columns. 
"""

# ╔═╡ 3ec9f5d5-6d6d-4586-b68b-84e3ee5aee27
## Utility function
##
function create_res_table(self::Table, new_cols, new_types;
                          pred::Function=_a -> true)
  ## keep pkey or not...
  pred(self) ?
	Table(new_cols, new_types; pkey=id(self) => coltype(self, id(self))) :
    Table(new_cols, new_types; pkey=nothing => Nothing)
end

# ╔═╡ a56253c8-92cd-11eb-31b9-51e1fd5ae026
function select(self::Table;
		keep_cols=Vector{Symbol}[], add_cols=D_SF())::Table
	##
	length(keep_cols) == 0 && (keep_cols = self.columns)

	## New column names and types
	new_cols = [keep_cols..., collect(keys(add_cols))...]
	keep_types = [coltype(self, col) for col in keep_cols]

	## collect the rows for result table
	n_rows = Vector{Any}[]
	add_types = Any[]
	for (ix, row) ∈ enumerate(self.rows)
		n_row = Any[row[col] for col ∈ keep_cols]
		## as we process the first row, we can get the return type...
		## ...of each function defined in add_cols
		## What if no row to process => tag with Any
		for (_col_name, fn) ∈ add_cols
			r = fn(row)
			ix == 1 && push!(add_types, typeof(r))
			push!(n_row, r)
		end
		push!(n_rows, n_row)
	end

	if length(add_cols) > 0 && length(add_types) == 0
		## add as many Any as column in add_cols
		push!(add_types, repeat(Any[Any], inner=length(add_cols)))
	end

	## Create result table
	new_types = UDT[keep_types..., add_types...]
	@assert(length(new_cols) == length(new_types),
		"length(new_cols) == length(new_types)")

	n_table = create_res_table(self, new_cols, new_types;
		pred=s -> id(s) ∈ keep_cols)

	insert(n_table, n_rows)
	n_table
end

# ╔═╡ e6348294-92cb-11eb-3bfd-09d80933b33a
begin
	delete(Users)
	insert(Users, [[0, "Hero", 0],
			[1, "Dunn", 2],
			[2, "Sue", 3],
			[3, "Chi", 3],
			[4, "Thor", 3],
			[5, "Clive", 2],
			[6, "Hicks", 3],
			[7, "Devin", 2],
			[8, "Kate", 2]
	])
	insert(Users, Dict(:name => "Ayumi", :num_friends => 5))
	insert(Users, [:name => "PasMas", :num_friends => 5])
end

# ╔═╡ 96386ab8-93ef-44c7-a524-1246379d7103
Table([:user_id, :name, :num_friends], UDT[Int64, Union{Nothing, String}, Union{Nothing, Int64}])

# ╔═╡ a5441766-92cd-11eb-1c8e-edcf3db0022e
begin
	## SELECT * FROM Users;
	n₀ = length(Users)
	all_users = select(Users)
	@assert length(all_users) == n₀
end

# ╔═╡ 3bfad78b-2ebd-4067-b306-b687f5a92a10
begin
	## SELECT id FROM Users;
	user_ids = select(Users, keep_cols=[:name])
end

# ╔═╡ cfed19ac-94e2-4c84-85b4-6134765cce0b
md"""
##### Limit
"""

# ╔═╡ 386a0591-92ce-4267-b1e6-73e293eb727c
##
## API (cont'ed)
##
function limit(self::Table, num_rows::Int=5)::Table
	"""
	Only the first num_rows are returned
	"""
	@assert 1 ≤ num_rows ≤ length(self.rows) "1 ≤ $(num_rows) ≤ $(length(self.rows))"

 	n_table = create_res_table(self, self.columns, self.types;
		pred=s -> id(s) !== nothing)

	## NOTE: mark vector as GRow type
	rows = Vector{Any}[]
	for row ∈ self.rows[1:num_rows]
		push!(rows, Any[v for (_, v) ∈ row])
	end
	insert(n_table, rows)
	n_table
end

# ╔═╡ 53c15148-1b04-4d85-aac6-874a6f750a00
user_names₁ = select(Users, keep_cols=[:name]) |> limit

# ╔═╡ 1ac32ed0-6e47-4606-8b70-524159660d93
user_names₂ = select(Users, keep_cols=[:name]) |>
  u -> limit(u, 2)

# ╔═╡ be425e03-c7b4-401d-9d29-fa2b07618ee5
md"""
###### Where
"""

# ╔═╡ e99eab12-08d9-4955-ba10-2eb46f74bd85
##
## API (cont'ed)
##
function where(self::Table, pred::WhereClause=row -> true)::Table
	"""
	Only the rows that satisfy pred are returned
	"""
	n_table = create_res_table(self, self.columns, self.types;
		pred=s -> id(s) !== nothing)

	n_rows = Vector{Any}[]
	for row ∈ self.rows
		pred(row) && (push!(n_rows, [row[col] for col ∈ n_table.columns]))	
	end

	insert(n_table, n_rows)
	n_table
end

# ╔═╡ b08b9470-5d53-4420-bef6-ef1c0bb4414c
begin
	dunn_ids = where(Users, row -> row[:name] == "Dunn") |> 
		u -> select(u, keep_cols=[id(Users)])
	# @assert length(dunn_ids) == 1
end

# ╔═╡ 955fe2a1-22b3-44db-b23d-d595d58bac3d
begin
	amp_ids = where(Users, row -> row[:name][1] ∈ ['A', 'P']) |> 
		u -> select(u, keep_cols=[id(Users), :name])
end

# ╔═╡ 964507de-c48d-4f7c-ab05-9b7739ecd5f3
begin
	ncol = length(Users.columns)
	function name_len_fn(row)::Int 
		length(row[:name])
	end

	name_lengths = select(Users;
		add_cols=D_SF(:name_length => name_len_fn))
end

# ╔═╡ 13c464eb-2a59-488b-b0ab-922ecda91bbd
begin
	name_lengths₂ = select(Users;
		add_cols=Dict{Symbol, Function}(
			:name_ini => row -> string(row[:name][1]),
			:len_name => row -> length(row)
		)
	)
end

# ╔═╡ 95ae9db4-f9ba-4fde-a021-0fc952550627
md"""
##### Aside on introspection
"""

# ╔═╡ 17b2e439-4f70-4db6-a01f-638ae2f88b6f
begin
	## with explicit return type
	##
	str_fn = """
function name_len_fn(row, bar, vargs...)::UInt16
	length(row[:name])
end
"""
	expr = Meta.parse(str_fn)
end

# ╔═╡ a57b3859-d026-4325-a5b2-7d4e7b4db408
begin
	## w/o explicit return type
	##
	str_fn₂ = """
function name_len_fn(row1, bar1; foo1=10)
	length(row[:name])
end
"""
	expr₂ = Meta.parse(str_fn₂)
end

# ╔═╡ 8e25eb57-b6f0-4c61-b657-4d815f1eb31f
with_terminal() do
	dump(expr)
end

# ╔═╡ 8ea2ba50-ad35-40b2-ab2d-1c34c9d90bd9
expr.args[1], expr₂.args[1]

# ╔═╡ b34d8aaa-7696-452f-9fd7-1002aa771547
## get return type
expr.args[1].args, length(expr.args[1].args), expr.args[1].args[end]

# ╔═╡ 4ff7e8e9-354e-4c99-b6f8-aedbf7ce1f3f
expr₂.args[1].args, length(expr₂.args[1].args)

# ╔═╡ 3a438295-3d30-41cc-95bd-db3b93e62d12
function get_fn_retype(str_fn::String)::DataType
	"""
	Return output type of a user function if such type is available...
	...which is the case iff expr.args[1].args has length of 2
	Otherwise fallback to Any
	"""
	expr = Meta.parse(str_fn)
	length(expr.args[1].args) == 2 ? eval(expr.args[1].args[end]) : Any
end

# ╔═╡ 9b24fead-ccfd-43ed-afa8-ed5ef6c4cf8f
get_fn_retype(str_fn), get_fn_retype(str_fn₂)

# ╔═╡ 6e7e7896-8cf8-11eb-062e-99492ec8cff8
html"""
<p style="text-align: right;">
  <a id='group-by'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 70f707c0-8cf6-11eb-11c2-73d7b28f7a0c
md"""
#### Group by
"""

# ╔═╡ 70d84470-8cf6-11eb-23b6-c7ba506d8552
md"""
This function will take a list of columns we want to group by and a dictionary of aggragation functions plus an optional predicate parameter (having clause) that can operate on multiple rows. 
"""

# ╔═╡ c451451a-8cf7-11eb-183b-e358c9d618e0
##
## API (cont'ed)
##

function group_by(self::Table; group_by_cols::Vector{Symbol}, agg::D_SF,
	having=HavingClause=row_gp -> true)::Table
	grouped_rows = Dict{}()

	## 1 - Populate groups
	for row ∈ self.rows
		key = Tuple(row[col] for col ∈ group_by_cols)
		ary = get(grouped_rows, key, Row[])
		push!(ary, row)
		grouped_rows[key] = ary
	end

	## 2 - populate rows
	n_rows = Vector{Any}[]
	agg_types = Any[]
	for (ix, (key, rows)) ∈ enumerate(grouped_rows)
		agg_row = Any[]
		if having(rows)
			agg_row = Any[agg_row..., key...]  ## Keep Any[]
			for (_, agg_fn) ∈ agg
				r = agg_fn(rows)
				ix == 1 && push!(agg_types, typeof(r))
				push!(agg_row, r)
			end
		end
		length(agg_row) > 0 && (push!(n_rows, agg_row))
	end

	## 3 - res. table consists of group_by columns and aggregates
	new_cols = [group_by_cols..., collect(keys(agg))...] |> unique
	gp_by_types = [coltype(self, col) for col ∈ group_by_cols]
	new_types = [gp_by_types..., agg_types...]

	n_table = create_res_table(self, new_cols, new_types;
		pred=s -> id(s) ∈ new_cols)
	insert(n_table, n_rows)
	n_table
end

# ╔═╡ 30bdc788-8d01-11eb-2f8f-9fd79593ddb8
begin
	"""
	-- find number of users and smallest user_id for each possible name length:
	SELECT LENGTH(name) as name_length, MIN(user_id) AS min_user_id,
		COUNT(*) AS num_users
	FROM users
	GROUP BY LENGTH(name);
	"""
	min_user_id = rows -> minimum(row[id(Users)] for row ∈ rows)
	num_rows = rows -> length(rows)

	stats_by_len = select(Users, add_cols=D_SF(:name_length => name_len_fn)) |>
		u -> group_by(u,
				group_by_cols=[:name_length],
				agg=D_SF(:min_user_id => min_user_id, :num_users => num_rows))
	#
end

# ╔═╡ c5bac3ae-c63b-44ba-9b10-75144410f456
Users

# ╔═╡ e696c2dd-b250-418c-9161-9fd87bfc378e
begin
	"""
	-- average number of friends for users whose names start with specific letters
	-- but see only the results for letters whose corresponding average is greater
	-- than 1
	SELECT SUBSTR(name, 1, 1) AS first_letter,
		AVG(num_friends) AS avg_num_friends
	FROM users
	GROUP BY SUBSTR(name, 1, 1)
	HAVING AVG(num_friends) > 1;
	"""
	first_letter_fn = row -> row[:name] !== nothing ? string(row[:name][1]) : ""

	avg_num_friends_fn =
		rows -> sum([row[:num_friends] for row in rows]) / length(rows)

	enough_friends_fn = rows -> avg_num_friends_fn(rows) > 1.

	avg_friends_by_letter =
		select(Users, add_cols=D_SF(:first_letter => first_letter_fn)) |>
		u -> group_by(u, group_by_cols=[:first_letter],
				agg=D_SF(:avg_num_friends => avg_num_friends_fn),
				having=enough_friends_fn)
end

# ╔═╡ 84946000-8d02-11eb-3160-571efee8fb0b
html"""
<p style="text-align: right;">
  <a id='order-by'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d05f1c40-8d17-11eb-2724-4d989c4c6b92
md"""
#### Order by
"""

# ╔═╡ 848fd812-8d02-11eb-01d6-75965b08bcc5
##
## API (cont'ed)
##
function order_by(self::Table, order::Function)::Table
	n_table = select(self)
	sort!(n_table.rows, by=order)
	n_table
end

# ╔═╡ 6cde1330-e1bb-419e-87f3-cf73c0e11e3d
friendliest_letters =  avg_friends_by_letter |>
	u -> order_by(u, row -> -row[:avg_num_friends])
# NOTE: -row(...) to reverse the sort

# ╔═╡ 7d35f85e-8e07-11eb-228c-81d28a444b52
friendliest_letters₂ =  avg_friends_by_letter |>
	u -> order_by(u, row -> -row[:avg_num_friends]) |>
	u -> limit(u, 3)
# NOTE: -row(...) to reverse the sort

# ╔═╡ 40d46802-8e0f-11eb-2e47-53096e24dbd8
html"""
<p style="text-align: right;">
  <a id='join'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 80dff352-8d02-11eb-06b1-5f5e325046f5
md"""
#### Join
"""

# ╔═╡ f1af4256-8e02-11eb-0238-2515d39a89cd
##
## API (cont'ed)
##
function join(self::Table, otable::Table; left_join=false)::Table
	join_on_cols = [c for c ∈ self.columns if c ∈ otable.columns]

	add_cols = [c for c ∈ otable.columns if c ∉ join_on_cols && c != id(otable)]
	new_cols = [self.columns..., add_cols...]
	new_types = UDT[self.types..., coltype.(Ref(otable), add_cols)...]

	n_table = Table(new_cols, new_types; pkey=nothing => Nothing)

	n_rows = Vector{Any}[]
	for row ∈ self.rows
		is_join = orow -> all(orow[c] == row[c] for c ∈ join_on_cols)

		o_rows = where(otable, is_join).rows
		for o_row ∈ o_rows
			push!(n_rows, Any[[row[c] for c ∈ self.columns]...,
					[o_row[c] for c ∈ add_cols]...])
		end

		if left_join && length(o_rows) == 0
			push!(n_rows, Any[[row[c] for c ∈ self.columns]...,
					[nothing for _ ∈ add_cols]...])
		end
	end
	@show "join/4", n_rows, length(n_rows)
	insert(n_table, n_rows)
	n_table
end

# ╔═╡ 26571096-f30c-476a-ad0e-ef133ba2562f
begin
	User_Interests = Table([:user_id => Int, :interest => String]) ## Default pkey
	insert(User_Interests, [
			[1, 0, "SQL"],
			[2, 0, "NoSQL"],
			[3, 2, "SQL"],
			[4, 2, "MySQL"],
			[5, 7, "PostgreSQL"],
			[6, 7, "SQL"]
	])
end

# ╔═╡ a1a91e04-ffdb-49b1-a999-e1cf1a730cb4
begin
	sql_users = join(Users, User_Interests) |>
		u -> where(u, r -> r[:interest] == "SQL") |>
		u -> select(u, keep_cols=[:name])
end

# ╔═╡ 43a52692-8e10-11eb-2043-8f0be195f58a
begin
	sql_users₂ = join(Users, User_Interests; left_join=true) |>
		u -> where(u, r -> r[:interest] !== nothing &&
							occursin(r"SQL\z", r[:interest])) |>
		u -> select(u, keep_cols=[:name])
	@test length(sql_users₂.rows) == 6
end

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═de098278-8e74-11eb-13e3-49c1b6e06e7d
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╟─f5ee64b2-8b59-11eb-2751-0778efd589cd
# ╟─81290d1c-8ce2-11eb-3340-337957fd81b7
# ╟─8ff1bb20-8ce2-11eb-1de6-fd84daec8930
# ╟─d3ee2138-8ce2-11eb-0b29-659a3be01512
# ╠═6d759180-928b-11eb-1cc1-0593c7f3b0c2
# ╟─2e8684fc-2ba6-48ec-81b3-f1c31cdde43a
# ╠═53accaea-92d4-11eb-0bc2-3d2ee10f9bfb
# ╟─1b1b8d8c-3803-43fa-b3af-7a58d75bb13b
# ╠═6f9c58d4-92d1-11eb-2c09-cb1ea5afcd6d
# ╠═040a7354-92d2-11eb-2825-7bac34b9fdf9
# ╠═17d214a7-be15-4236-a614-3127b535ef66
# ╠═85211d8a-be50-454d-a6c5-cd820a20f8d4
# ╠═adf67244-92d4-11eb-3004-41e62e906e32
# ╠═650237ee-928e-11eb-0e43-17ab98a0cc11
# ╟─d146a8ac-92cc-11eb-29b1-bb065a468477
# ╠═13a0940e-8ce4-11eb-231c-f331a607203c
# ╟─e3458d34-92cc-11eb-2426-79f229abd908
# ╠═96c2a668-9290-11eb-074d-19ffeb68eba6
# ╟─f1357972-92cc-11eb-1f73-43aae5a43aa5
# ╠═5a3a8fdc-929d-11eb-25e3-e309dffdb455
# ╟─0292e48e-92cd-11eb-1882-81a2faaad136
# ╠═8545d17c-929e-11eb-0989-ffd4749bbb25
# ╠═95d2b19e-92a4-11eb-0f91-e343c9317983
# ╠═8a945abc-012f-4ace-a67a-b7e0f520346b
# ╟─28ba0bf6-92cd-11eb-0669-75eadb768518
# ╠═d4562f7e-9290-11eb-2d8c-952f2e0edfed
# ╠═f877c3e6-929c-11eb-00cd-c15568f99627
# ╠═d5657a88-92c4-11eb-2a4f-c7dcaa97bcf6
# ╟─80ddf0f4-8ce2-11eb-3046-331119a0dc9b
# ╟─80a71408-8ce2-11eb-3978-75a4a2df9116
# ╟─d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
# ╠═4ccdb1ce-92c2-11eb-18dd-c510e88474c6
# ╠═2af6dbec-92c6-11eb-1155-596ed44b04f8
# ╠═2abb0114-92c6-11eb-01d5-cd34aa6426b2
# ╠═bc1fb8d2-92ca-11eb-14e0-c9586461bc1e
# ╟─d2b198b6-8ce2-11eb-170e-0f17904c9f2c
# ╟─d37f37b8-8ce8-11eb-2c00-3f98ca407f41
# ╠═5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
# ╠═394093fa-8cea-11eb-0071-eff3045a012b
# ╠═435c4444-8dfd-11eb-24e8-5543f905f199
# ╟─e95983ba-8ceb-11eb-38fd-ed92cdcf754c
# ╟─d3a749a2-8cec-11eb-1f06-b568f244b576
# ╟─31d3226a-8cf4-11eb-0897-39989ba76b58
# ╠═3ec9f5d5-6d6d-4586-b68b-84e3ee5aee27
# ╠═a56253c8-92cd-11eb-31b9-51e1fd5ae026
# ╠═e6348294-92cb-11eb-3bfd-09d80933b33a
# ╠═96386ab8-93ef-44c7-a524-1246379d7103
# ╠═a5441766-92cd-11eb-1c8e-edcf3db0022e
# ╠═3bfad78b-2ebd-4067-b306-b687f5a92a10
# ╟─cfed19ac-94e2-4c84-85b4-6134765cce0b
# ╠═386a0591-92ce-4267-b1e6-73e293eb727c
# ╠═53c15148-1b04-4d85-aac6-874a6f750a00
# ╠═1ac32ed0-6e47-4606-8b70-524159660d93
# ╟─be425e03-c7b4-401d-9d29-fa2b07618ee5
# ╠═e99eab12-08d9-4955-ba10-2eb46f74bd85
# ╠═b08b9470-5d53-4420-bef6-ef1c0bb4414c
# ╠═955fe2a1-22b3-44db-b23d-d595d58bac3d
# ╠═964507de-c48d-4f7c-ab05-9b7739ecd5f3
# ╠═13c464eb-2a59-488b-b0ab-922ecda91bbd
# ╟─95ae9db4-f9ba-4fde-a021-0fc952550627
# ╠═17b2e439-4f70-4db6-a01f-638ae2f88b6f
# ╠═a57b3859-d026-4325-a5b2-7d4e7b4db408
# ╠═8e25eb57-b6f0-4c61-b657-4d815f1eb31f
# ╠═8ea2ba50-ad35-40b2-ab2d-1c34c9d90bd9
# ╠═b34d8aaa-7696-452f-9fd7-1002aa771547
# ╠═4ff7e8e9-354e-4c99-b6f8-aedbf7ce1f3f
# ╠═3a438295-3d30-41cc-95bd-db3b93e62d12
# ╠═9b24fead-ccfd-43ed-afa8-ed5ef6c4cf8f
# ╟─6e7e7896-8cf8-11eb-062e-99492ec8cff8
# ╟─70f707c0-8cf6-11eb-11c2-73d7b28f7a0c
# ╟─70d84470-8cf6-11eb-23b6-c7ba506d8552
# ╠═c451451a-8cf7-11eb-183b-e358c9d618e0
# ╠═30bdc788-8d01-11eb-2f8f-9fd79593ddb8
# ╠═c5bac3ae-c63b-44ba-9b10-75144410f456
# ╠═e696c2dd-b250-418c-9161-9fd87bfc378e
# ╟─84946000-8d02-11eb-3160-571efee8fb0b
# ╟─d05f1c40-8d17-11eb-2724-4d989c4c6b92
# ╠═848fd812-8d02-11eb-01d6-75965b08bcc5
# ╠═6cde1330-e1bb-419e-87f3-cf73c0e11e3d
# ╠═7d35f85e-8e07-11eb-228c-81d28a444b52
# ╟─40d46802-8e0f-11eb-2e47-53096e24dbd8
# ╟─80dff352-8d02-11eb-06b1-5f5e325046f5
# ╠═f1af4256-8e02-11eb-0238-2515d39a89cd
# ╠═26571096-f30c-476a-ad0e-ef133ba2562f
# ╠═a1a91e04-ffdb-49b1-a999-e1cf1a730cb4
# ╠═43a52692-8e10-11eb-2043-8f0be195f58a
