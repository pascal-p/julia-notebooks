module YaDB

import Base: length #, show

export Table, Row, GRow, WhereClause, HavingClause, D_SF,
  id, length, insert, update, delete, coltype,
  select, where, limit, group_by, order_by #, show


const Row = Dict{Symbol, Any}
const GRow = Union{Row, Vector{Pair{Symbol, Any}}, Vector{Any}}  ## Generic Row
const WhereClause = Function  # Base.Callable
const HavingClause = Function # Base.Callable
const S_N = Union{Symbol, Nothing}
# const PK = Pair{S_N, DataType}
const D_SF = Dict{Symbol, Function}


mutable struct Table
  columns::Vector{Symbol}
  types::Vector{DataType}
  _pkey::S_N
  rows::Vector{Row}

  function Table(col_types::Vector{Pair{Symbol, DataType}}; pkey::Pair=(:id => Int))
    # vector of pairs keeps implicit order
    @assert length(col_types) ≥ 1
    #
    cols = map(((k, _)=p) -> k, col_types)
    types = map(((_, v)=p) -> v, col_types)
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey.first, Vector{Row}[])
  end

  function Table(cols::Vector{Symbol}, types::Vector{DataType}; pkey::Pair=(:id => Int))
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey.first, Vector{Row}[])
  end
end


## ================================
## Public API
## ================================

id(self::Table) = self._pkey

length(self::Table) = length(self.rows)


function gen_pkey_value(self::Table)
  """
  Assuming pkey is instance of a numeric type
  """
  (map(r -> r[id(self)], self.rows) |> maximum)  + 1
end


function insert(self::Table, row::Vector{Pair{Symbol, Any}})
  res = filter(p -> p.first == id(self), row)
  has_pkey = length(res) > 0
  length(row) ≠ length(self.types) && has_pkey &&
  throw(ArgumentError("Mismatch with expected number of columns"))
  check_value_dtype(self, row)
  ## find the pair <pkey, value>  pkey is given by id(self)
  row_ids = filter(p -> p.first == id(self), row)
  if length(row_ids) == 0
    push!(row, id(self) => gen_pkey_value(self))
  else
    id_val = row_ids[1][2]  ## value assoc with this pkey
    row_already_inserted(self, id_val) && (return nothing)
  end
  push!(self.rows, Dict(row...))
end

function insert(self::Table, row::Vector{Any})
  length(row) ≠ length(self.types) &&
  throw(ArgumentError("Mismatch with expected number of columns"))
  check_value_dtype(self, row)
  ## row[1] is the value assoc. with pkey
  row_already_inserted(self, row[1]) && (return nothing)
  push!(self.rows, Dict(zip(self.columns, row)))
end

function insert(self::Table, row::Row)
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
    self.rows[ix] = Row(row..., updates...)
  end
  nothing
end


function delete(self::Table, pred::WhereClause=row -> true)|
  self.rows = [
    row for row ∈ self.rows if !pred(row)
  ]
  nothing
end


function select(self::Table;
    keep_cols=Vector{Symbol}[], add_cols=Dict{Symbol, Function}())::Table
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
    for (_col_name, fn) ∈ add_cols
      r = fn(row)
      ix == 1 && push!(add_types, typeof(r))
      push!(n_row, r)
    end
    push!(n_rows, n_row)
  end

  ## Create result table
  new_types = [keep_types..., add_types...]
  @assert(length(new_cols) == length(new_types),
    "length(new_cols) $(length(new_cols)) == length(new_types)")

  n_table = create_res_table(self, new_cols, new_types;
                             pred=s -> id(s) ∈ keep_cols)
  insert(n_table, n_rows)
  n_table
end


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


function limit(self::Table, num_rows::Int=5)::Table
  """
  Only the first num_rows are returned
  """
  @assert 1 ≤ num_rows ≤ length(self.rows) "1 ≤ $(num_rows) ≤ $(length(self.rows))"

  n_table = id(self) !== nothing ? Table(self.columns, self.types) :
    Table(self.columns, self.types; pkey=nothing => Nothing)

  ## NOTE: mark vector as GRow type
  # rows = GRow[Any[v] for r ∈ self.rows[1:num_rows] for (_, v) ∈ r]
  rows = Vector{Any}[]
  for row ∈ self.rows[1:num_rows]
    push!(rows, Any[v for (_, v) ∈ row])
  end
  insert(n_table, rows)
  n_table
end


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
    push!(n_rows, agg_row)
  end

  ## 3 - res. table consists of group_by columns and aggregates
  new_cols = [group_by_cols..., collect(keys(agg))...] |> unique
  gp_by_types = [coltype(self, col) for col ∈ group_by_cols]
  new_types = [gp_by_types..., agg_types...]

  n_table = create_res_table(self, new_cols, new_types;
                             pred=s -> id(s) ∈ new_cols )
  insert(n_table, n_rows)
  n_table
end


function order_by(self::Table, order::Function)::Table
  n_table = select(self)
  sort!(n_table.rows, by=order)
  n_table
end


# function show(io::IO, self::Table)
#   s = "num. records: $(length(self)):\n"
#   for rd ∈ self.rows
#     s₁ = []
#     for (k, v) ∈ rd
#       push!(s₁, "$(k): $(v)")
#     end
#     s = string(s, "  <", join(s₁, ", "), ">\n")
#   end
#   print(io, "$(s)")
# end


function coltype(self::Table, colname::Symbol)::DataType
  ix = findfirst(col -> col == colname, self.columns)
  ix === nothing && throw(ArgumentError("column $(colname) inexistent"))
  self.types[ix]
end

## ================================
## Internals
## ================================

function create_res_table(self::Table, new_cols, new_types;
                          pred::Function=_a -> true)
  pred(self) ? Table(new_cols, new_types) :
    Table(new_cols, new_types; pkey=nothing => Nothing)
end

function check_pk(cols, types, pkey) # ::Pair
  if pkey.first !== nothing
    @assert pkey[2] <: Integer "Expecting an Integer, got: $(pkey[2])"
  end

  if pkey.first !== nothing && pkey.first ∉ cols
    cols  = [pkey[1], cols...]
    types = [pkey[2], types...]
  end
  (cols, types)
end


function check_value_dtype(self::Table, values::Vector{Any})
  dtypes = self.types
  for (v, dt) ∈ zip(values, dtypes)
    !(typeof(v) <: dt) && !isnothing(v) &&
    throw("Expected type for $(v): $(dt), got $(typeof(v))")
  end
end


function check_value_dtype(self::Table,
                           row::Union{Row, Vector{Pair{Symbol, Any}}})
  (cols, types) = self.columns, self.types
  col_type = Dict(zip(cols, types))

  for (k, v) ∈ row
    (haskey(col_type, k) && typeof(v) <: col_type[k]) ||
    throw("Expected type: $(col_type[k]), got $(typeof(v))")
  end
end


function row_already_inserted(self::Table, id_val::Any)::Bool
  id(self) === nothing && return false  ## no pkey => ignore check
  #
  res = filter(r -> r[id(self)] == id_val, self.rows)
  length(res) > 0    ## row already inserted id > 0
end


end  # Module
