module YaDistances

using LinearAlgebra

export cosine_similarity

const AVT = AbstractArray{T, N} where {T <: Any, N}

function cosine_similarity(v₁::AVT, v₂::AVT)::Float64 # where {T <: Any}
	dot(v₁, v₂) / (norm(v₁) * norm(v₂))
end

end  ## Module
