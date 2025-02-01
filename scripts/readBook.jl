using DrWatson
quickactivate("conspnet")
begin
   import JSON
   using TextAnalysis
   using Pipe: @pipe
   using DataStructures
   #using Debugger
   using Revise
   using Unicode
end
includet(srcdir("functions.jl"))

#################################

#infile = datadir("ConspiracyKnight_byhand.txt")
infile = datadir("Snow.txt")
dat = loop_refs_from_txt(infile);

#################################
#@run dat = loop_refs_from_txt(infile)
#################################
#sortedrefs  = sort!([dat.namedates...])
###########################################
function shortenref(dat)
   shortrefs = Dict{String,String}()
   # namedates is a set, so its entries are unique
   # test
   @assert length(dat.namedates) == length(dat.shref2full)

   global datematch

   x = 1
   for i in dat.namedates

      if length(dat.biblio_item[i].authors) <= 2
         if i ∈ values(shortrefs)
            println("shortrefs[$i] = $(shortrefs[i])")
            x = 2

         end
         shortrefs[i] = i
         # we may continue since the uniqueness of these namedates are checjed elsewere
         continue
      end

      println("$i => $(length(dat.biblio_item[i].authors))")
      shdate = findfirst(datematch, i)
      a = false
      if shdate === nothing
         a = true
         shdate = findfirst(r"(?!\(eds\))(\(.*\))", i) # what is in parentehses, but not (eds)
         #leaves unchanged
         println("NO date in $i, using $(i[shdate])")
      end
      #@show  i[shdate]
      #@show dat.biblio_item[i].authors
      newshortref = dat.biblio_item[i].authors[1].match * " et al " * i[shdate]

      println("newshortref = $newshortref")

      notfoundeq = true
      while notfoundeq
         oldshortref = newshortref
         newshortref = change_shortref(dat, i, oldshortref, shortrefs)
         if newshortref == oldshortref
            notfoundeq = false
         end
      end
      shortrefs[i] = newshortref

   end
   return shortrefs
end

##############################
function change_shortref(dat, i, newshortref, shortrefs)
   # we need the new shortre to already exist in values(hortrefs)
   # and at the same time the old shortref to be different from the new one
   # remove all spaces and commas to Compare 
   replacer = x -> replace(x, r"\s" => "", r"," => "", r"\." => "") |> lowercase

   for (j, k) in shortrefs
      if replacer(newshortref) == replacer(k)
         #
         println("newshortref  $newshortref")
         println("$i already exists \n$j\n")
         if replacer(dat.shref2full[i]) == replacer(dat.shref2full[j])
            println("But it's ok , they are the same ref")
         else
            println(dat.shref2full[i])
            println(dat.shref2full[j])

            println(dat.biblio_item[i].title)
            println(dat.biblio_item[j].title)

            t1 = dat.biblio_item[j].title |> replacer
            t2 = dat.biblio_item[i].title |> replacer
            csub = common_substrings(t1, t2)
            println("common_substring $csub")
            lcsub = length(csub)
            lt12 = min(length(t1), length(t2)) * 0.3
            if lcsub > lt12
               println("No Change needed here! Continue.")
               x = 1
               continue
            else
               # yesno = readline()
               # @show yesno
               # if yesno == "n" || yesno == "N"
               dmat = match(datematch, newshortref) ##dat.shref2full[refanalysis.names_date_str])
               @show dmat
               if dmat === nothing
                  error("No date found for $(dat.shref2full[i])")
               end
               if isnothing(dmat.captures[end])
                  # no a, b, etc found after the year
                  println("No a, b, etc ext after date in $(newshortref), $(dmat.captures)")
                  # add an 'a' after the year
                  startref = newshortref[1:findfirst(datematch, newshortref)[end]-1]
                  endref = newshortref[findfirst(datematch, newshortref)[end]:end]
                  newshortref = startref * "a" * endref
                  @show newshortref
                  # also we must
                  #@show dat.names_date_str
               else
                  # we have a, b, etc
                  ch = dmat.captures[end][1] + 1 #next character
                  # if shref is "asdasdf (2001a)", then shref)[end]-2] = "asdasdf (2001"
                  # then we can add ch (which is b,c, d etc) after the year
                  newshortref = newshortref[1:findfirst(datematch, newshortref)[end]-2] * ch * newshortref[findfirst(datematch, newshortref)[end]:end]
                  @show newshortref
               end
            end
         end
         #change_shortref(i, newshortref, shortrefs)
         x = 2
      end
   end
   return newshortref
end

##############################
#@run 

shortrefs = shortenref(dat)

@assert length(shortrefs) == length(dat.namedates)



###############################################
##################################
function get_bbdict(dat, shortrefs)
   bibdict = Dict{String,Any}()
   for (i, k) in dat.see_also # 
      println("$i => $k")
      for item in dat.biblio[i]
         println("-- $item => $(shortrefs[item])")
      end
      #println("$i => $(dat.biblio[i])\n") #
      # transform dat.biblio[i] to shortrefs
      bibdict[i] = (k, [shortrefs[x] for x in dat.biblio[i]])
   end
   bibdict = sort(bibdict);
end
bibdict=get_bbdict(dat, shortrefs)

 json_string = JSON.json(bibdict)

open(datadir("bibdict_for_Snow_etal.json"), "w") do f
   JSON.print(f, json_string)
end

#############################################
function reversegraph(dat, shortrefs)
   reversebibdict = Dict{String,Vector{String}}()

   for (tit, refs) in dat.biblio # 
      for ref in refs
         shref = shortrefs[ref]
         if shref ∈ keys(reversebibdict) && tit ∈ reversebibdict[shref]
            @show ref, shref, tit
         end
         reversebibdict[shref] = push!(get(reversebibdict, shref, []), tit)
      end

   end

   # bibdict[i] = (k, dat.biblio[i])
   sort(reversebibdict)
end

######
rdict = reversegraph(dat, shortrefs)

json_string = JSON.json(rdict)

open(datadir("reversebibdict_for_Snow_etal.json"), "w") do f
   JSON.print(f, json_string)
end


###############################################
x = 1



for i in dat.namedates
   if !isnothing(match(r"\d{4}-", i))
      println(i)
   end
end
###

rmatch = r"\d{4}[bc]"
rmatch = r"Gramsci"
for i in dat.namedates
   if !isnothing(match(rmatch, i))
      println(i)
      println(dat.shref2full[i], "\n")
   end
end

##############################
dat, txt = bootstrap(infile);
ind = findall(txt.titles) do x
   occursin("strumental", x)
end

txt.titles[ind]

####################################
dat

namematcher = r"(\w+),\s*[A-Z]?\.?,*\s?[A-Z]?\.?"
#single_name = r"^(\w+),(\s*[A-Z]\.),\s[A-Z]?"
fname = match(namematcher, ref)
andmatch = match(r"\s?(and)", ref, fname.offsets[end])
datematch = match(r"(\(\d{4}[a-d\s]?[\/,\–]*[\d{4}]*\))", ref)

ref2d = ref[1:datematch.offsets[1]-1]
andmatch = match(r"\s(and)\s", ref2d)
single_name = match(namematcher, ref2d)
isnothing(single_name)


function harmser(; n=2000)
   res = 0
   for i in 1:n
      res += 1. / i
   end
   return res
end

function lsum(; n=10000)
   res = 0
   for x in 1:n
      res += log(1 + 1 / x)
   end
   return res
end
a = lsum(n=1000000)

function mydifff(n)
   harmser(n=n) - lsum(n=n)
end

mydifff(10000000000)






length(values(shortrefs))
values(shortrefs) |> Set |> length
keys(shortrefs) |> Set |> length


for (i, h) in shortrefs
   a = findfirst(r"(\d{4}(.)\))", i)
   b = findfirst(r"(\d{4}(.)\))", h)
   if !isnothing(a)
      println("$i => $h")
      println("$(i[a])\n")
   end
   if !isnothing(b)
      println("$i => $h")
      println("$(i[b])\n")
   end
end

for (i, h) in dat.biblio
   for k in h
      a = findfirst(r"(\d{4}(.)\))", k)
      if !isnothing(a)
         println("$i => $k")
         println("$(k[a])\n")
      end
   end
end
###########

for i in dat.namedates

   a = findfirst(r"(\(\d{4}(.)\))", i)
   if !isnothing(a)
      println("$i")
      #println("$(k[a])\n") 
   end
end
##########################3
dat.biblio_item["Anderson, K.B. (2010)"].a
