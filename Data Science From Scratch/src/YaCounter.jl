module YaCounter

import Base: getindex, keys, values,
  iterate, length, eltype

export Counter, getindex, keys, values,
  iterate, eltype

const DT{T} = Dict{T, Integer} where T <: Any
const VT{T} = AbstractVector{T} where T <: Any

struct Counter
  _hsh::DT
  _nonkey::Bool   ## if true throws an exception when trying to access a non existent key
  _defval::Integer

  function Counter(entry::VT{T};
                      nokey_exception=true, defval=0) where T <: Any
    counter_fn(entry) |> d -> new(d, nokey_exception, defval)
  end
end

## API
keys(self::Counter) = keys(self._hsh) |> collect

values(self::Counter) = values(self._hsh) |> collect

function getindex(self::Counter, key::T) where T  <: Any
  haskey(self._hsh, key) && (return self._hsh[key])
  self._nonkey && throw(KeyError("No such key $(key) in Counter"))
  self._defval  ## otherwise default value for non existent key (Int64)
end

function iterate(self::Counter, state=(collect(self._hsh), 1))
  lst, ix = state
  ix > length(self._hsh) && (return nothing)

  (lst[ix], (lst, ix + 1))
end

length(self::Counter) = length(self._hsh)

eltype(self::Counter) = eltype(self._hsh)


## internals

function counter_fn(v::VT{T})::DT{T} where T
  hcount = DT{T}()
  for x ∈ v
    hcount[x] = get(hcount, x, 0) + 1
  end
  hcount
end

end  ## module
