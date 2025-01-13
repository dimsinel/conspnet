using DrWatson
quickactivate("conspnet")

using TextAnalysis
using Pipe: @pipe
using DataStructures
#using Debugger
using Revise

includet(srcdir("functions.jl"))
#################################

#infile = datadir("ConspiracyKnight_byhand.txt")
infile = datadir("Snow.txt")
dat = loop_refs_from_txt(infile) 
#################################


 for (i, k) in dat.biblio
    println("$i => $k")
 end
 #################################