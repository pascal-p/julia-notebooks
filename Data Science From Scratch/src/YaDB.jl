module YaDB

import Base: length, show

export Table, Row, GRow, WhereClause, HavingClause,
  id, length, insert, update, delete, show, coltype


const Row = Dict{Symbol, Any}
const GRow = Union{Row, Vector{Pair{Symbol, Any}}, Vector{Any}}  ## Generic Row
const WhereClause = Function  # Base.Callable
const HavingClause = Function # Base.Callable
const PK = Pair{Symbol, DataType}


mutable struct Table
  columns::Vector{Symbol}
  types::Vector{DataType}
  pkey::Symbol
  rows::Vector{Row}

  function Table(col_types::Vector{Pair{Symbol, DataType}}; pkey::PK=(:id, Int))
    # vector of pairs keeps implicit order
    @assert length(col_types) ≥ 1
    #
    cols = map(((k, _)=p) -> k, col_types)
    types = map(((_, v)=p) -> v, col_types)
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey[1], Vector{Row}[])
  end

  function Table(cols::Vector{Symbol}, types::Vector{DataType}; pkey::PK=(:id, Int))
    cols, types = check_pk(cols, types, pkey)
    new(cols, types, pkey[1], Vector{Row}[])
  end
end


## ================================
## Public API
## ================================

id(self::Table) = self.pkey

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


function show(io::IO, self::Table)
  s = "num. records: $(length(self)):\n"
  for rd ∈ self.rows
    s₁ = []
    for (k, v) ∈ rd
      push!(s₁, "$(k): $(v)")
    end
    s = string(s, "  <", join(s₁, ", "), ">\n")
  end
  print(io, "$(s)")
end


function coltype(self::Table, colname::Symbol)::DataType
  ix = findfirst(col -> col == colname, self.columns)
  ix === nothing && throw(ArgumentError("column $(colname) inexistent"))
  self.types[ix]
end

## ================================
## Internals
## ================================

function check_pk(cols, types, pkey)
  @assert pkey[2] <: Integer "Expecting an Integer, got: $(pkey[2])"

  if pkey.first ∉ cols
    # check pkey[2] <: Integer
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
                           row::Union{Row,  Vector{Pair{Symbol, Any}}})
  (cols, types) = self.columns, self.types
  col_type = Dict(zip(cols, types))

  for (k, v) ∈ row
    (haskey(col_type, k) && typeof(v) <: col_type[k]) ||
    throw("Expected type: $(col_type[k]), got $(typeof(v))")
  end
end


function row_already_inserted(self::Table, id_val::Any)::Bool
  res = filter(r -> r[id(self)] == id_val, self.rows)
  length(res) > 0    ## row already inserted id > 0
end


end  # Module