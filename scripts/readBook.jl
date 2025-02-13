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
#tit_snow = getalltitles(infile |> FileDocument |> text)
dat_snow = loop_refs_from_txt(infile);

infile = datadir("Ness.txt")
#tit_ness = getalltitles(infile |> FileDocument |> text)
dat_ness = loop_refs_from_txt(infile);

#################################
@run dat_ness = loop_refs_from_txt(infile)
#################################
#sortedrefs  = sort!([dat.namedates...])
###########################################
"""
    shortenref(dat)

TBW
"""
function shortenref(dat)
   shortrefs = Dict{String,String}()
   # namedates is a set, so its entries are unique
   # test
   @assert length(dat.namedates) == length(dat.shref2full)

   global datematcher

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
      shdate = findfirst(datematcher, i)
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
            csub = ""
            try
               csub = common_substrings(t1, t2)
               println("common_substring $csub")
            catch e
               println(e)
               csub = common_graphemes(t1, t2)
               println("common_grapheme $csub")
            end

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
               dmat = match(datematcher, newshortref) ##dat.shref2full[refanalysis.names_date_str])
               @show dmat
               if dmat === nothing
                  error("No date found for $(dat.shref2full[i])")
               end
               if isnothing(dmat.captures[end])
                  # no a, b, etc found after the year
                  println("No a, b, etc ext after date in $(newshortref), $(dmat.captures)")
                  # add an 'a' after the year
                  startref = newshortref[1:findfirst(datematcher, newshortref)[end]-1]
                  endref = newshortref[findfirst(datematcher, newshortref)[end]:end]
                  newshortref = startref * "a" * endref
                  @show newshortref
                  # also we must
                  #@show dat.names_date_str
               else
                  # we have a, b, etc
                  ch = dmat.captures[end][1] + 1 #next character
                  # if shref is "asdasdf (2001a)", then shref)[end]-2] = "asdasdf (2001"
                  # then we can add ch (which is b,c, d etc) after the year
                  newshortref = newshortref[1:findfirst(datematcher, newshortref)[end]-2] * ch * newshortref[findfirst(datematcher, newshortref)[end]:end]
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

shortrefs_snow = shortenref(dat_snow)
shortrefs_ness = shortenref(dat_ness)

@assert length(shortrefs_ness) == length(dat_ness.namedates)
@assert length(shortrefs_snow) == length(dat_snow.namedates)



###############################################
##################################
# function get_bbdict(dat, shortrefs)
#    bibdict = Dict{String,Any}()
#    for (i, k) in dat.see_also # 
#       println("$i => $k")
#       for item in dat.biblio[i]
#          println("-- $item => $(shortrefs[item])")
#       end
#       #println("$i => $(dat.biblio[i])\n") #
#       # transform dat.biblio[i] to shortrefs
#       bibdict[i] = (k, [shortrefs[x] for x in dat.biblio[i]])
#    end
#    bibdict = sort(bibdict)
# end
function get_bbdict(dat, shortrefs)
   bibdict = Dict{String,Any}()
   for (i, k) in dat.biblio # 
      println("$i => $k")
      for item in k # dat.see_also[i]
         println("-- $item => $(shortrefs[item])")
      end
      println("$i => $(dat.biblio[i])\n") #
      # transform dat.biblio[i] to shortrefsoffs = single_name.offsets[1] + length(single_name.match)
      if haskey(dat.see_also, i)
         bibdict[i] = (dat.see_also[i], k)
      else
         bibdict[i] = ([], k)
      end
   end
   bibdict = sort(bibdict)
end

#############################
bibdict_ness = get_bbdict(dat_ness, shortrefs_ness)
bibdict_snow = get_bbdict(dat_snow, shortrefs_snow)


bibdict_ness
bibdict_ness["AFRICAN-AMERICAN WOMEN'S MOVEMENT 1865-1920s"]
[x for x in keys(bibdict_ness) if occursin("AFRI", x)]

x = 0;


function check_shortrefs(bibdict, shortrefs)


   for (i, k) in bibdict
      # @show k
      @show bibdict[i][2]
      for item in k[2]

         @show item, shortrefs[item]
         @assert shortrefs[item] ∈ bibdict[i][2]
      end
   end
end

#check_shortrefs(bibdict_snow, shortrefs_snow)
check_shortrefs(bibdict_ness, shortrefs_ness)

fieldnames(typeof(dat_ness))
dat_ness.biblio
bibdict_ness["ABORTION RIGHTS MOVEMENT"]
bibdict_snow["Abeyance"][2]

shortrefs["Lipset, S.M. et al (1956)"]
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
##############################################
function find_etals(bibdict)
   for (i,k) in bibdict
      if occursin("et al", i)
         auths = [String(c.match) for c in k.authors ]
         println("$i => n_auth=$(length(k.authors)), $(auths)\n")
      end
   end

end
find_etals(dat_ness.biblio_item)
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

ref = "Lerner,  Gasdf (1967; 1998). *The Grimké́ Sisters from South Carolina: Pioneers for Women's Rights and Abolition.* New York: Houghton Mifflin Company; Reprint, New York: Oxford University Press"
datematch = match(datematcher, ref)
ref2d = ref[1:datematch.offsets[1]-1]

match(namematcher, ref2d)
match(namematcher, ref)
begin #r"(\w+),\s*[A-Z]?\.?,*\s?[A-Z]?\.?"
   first = r"(?:((?:De )|(?:V[ao]n )|(?:[DO]\S))?\w,?)"
   a = findfirst(first, ref2d)
   @show ref2d[a]
   second = r"(\s*(\w+|([A-Z]))[,\.])"
   #b = findfirst(second, ref) , @show ref[b]
   third = r"\s?([A-Z][,\.])?" #    \s[A-Z])"
   namematcher = first * second * third
   c = findfirst(namematcher, ref2d)
   ref2d[c]
end


relength(values(shortrefs))
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



ref = "*New Harmony Gazette*. Unive|rsity of Wyoming. Microfiche HN 64N4."
auth = "New Harmony Gazette"
a = Bibitem([match(Regex(auth), auth)], nothing, match(r"No Date", "No Date"), nothing, auth, auth * " (No Date)")
a


##############################
intext = infile |> FileDocument |> text
tits = findall(r"##\s(.*)\n", intext)
alltitles = map(tits) do x

   beg = x[begin] + 3
   en = x[end] - 1
   intext[beg:en]

end .|> strip


ref = "Kelley, Robin D.G. (2002)" #Horton, James O., and Lois E. Horton (1979). *Black Bostonians: Family Life and Community Struggle in the Antebellum North.* New York: Holmes and Meier."
ref = "Horton, W.W.W., asdfasf, (9999) dddd"#, James O., and Lois E. Horton (1979). *Black Bostonians: Family Life and Community Struggle in the Antebellum North.* New York: Holmes and Meier."

begin
   ref = "Acuña, Rodolfo (2000)"
   #datematcher

   datematch = match(datematcher, ref)
   ref2d = ref[1:datematch.offsets[1]-1] |> strip
end

for (i,k) in dat_ness.shref2full
if occursin("et al", k) && !occursin("et al", i)
   @show i,k 
end

end


