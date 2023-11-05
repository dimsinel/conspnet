using DrWatson
@quickactivate "conspnet"

using TextAnalysis
using Pipe
using DataStructures
using Plots

function collatz(n::Int)::Int
    if mod(n,2) == 0
        return Int(n/2)
    else
        return (3n+1)/2
    end
end
    
function Collsec(n::Int)::Int
    time = Int(0)
    diffone = true
    while diffone
        time += 1
        n = collatz(n)
        #@show n
        if n == 1
            return time
        end
    end

end

prang = 2:10000
tts = [Collsec(i) for i in prang]
scatter(prang,tts,ms=1)
