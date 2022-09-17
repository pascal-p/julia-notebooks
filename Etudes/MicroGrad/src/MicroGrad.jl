module MicroGrad

# Write your package code here.
import Base: +, -, *, /, ^, show, promote_rule, convert

include("./engine.jl")
include("./nn.jl")

export Value, YaValue, Neuron, Neuron_f64, Layer, MLP, forward, parameters

end
