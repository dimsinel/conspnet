using DrWatson
quickactivate("conspnet")

using TextAnalysis
using Pipe: @pipe
using DataStructures
#using Debugger
using Revise
using Unicode 

includet(srcdir("functions.jl"))
#################################
function loop_refs_from_txt(infile::String)
   # begin # 172

   dat, txt = bootstrap(infile)

   while true # loop over dat.titles
      dat.n += 1
      dat.breaker = false
      bibitem_string = String[]

      refs = find_title(txt, dat)
      @show refs

      if isnothing(refs)
         break
      end
      if dat.n > 100
          break
      end

      break_refs(refs, dat, bibitem_string)


      #println(ref_vect)
      #return ref_vect


      if dat.breaker #
         break
      end

      dat.start_search = dat.ref_end
   end

   return dat
end

#################################

#infile = datadir("ConspiracyKnight_byhand.txt")
infile = datadir("Snow.txt")
#@run 
dat = loop_refs_from_txt(infile)
#################################


 Van De Von D’Anieri

for (i, k) in dat.biblio
   println("$i => $k")
end
#################################

namematcher = r"(\w+),\s*[A-Z]?\.?,*\s?[A-Z]?\.?"
#single_name = r"^(\w+),(\s*[A-Z]\.),\s[A-Z]?"
fname = match(namematcher, ref)
andmatch = match(r"\s?(and)", ref, fname.offsets[end])
datematch = match(r"(\(\d{4}[a-d\s]?[\/,\–]*[\d{4}]*\))", ref)

ref2d = ref[1:datematch.offsets[1]-1]
andmatch = match(r"\s(and)\s", ref2d)
single_name = match(namematcher, ref2d)
isnothing(single_name)

s.captures
s.offset
ref = "Wickham-Crowley, T.P. (1992) Guerrillas and Revolution in Latin America: A Comparative Study of Insurgents and Regimes since 1956. Princeton University Press, Princeton, NJ."
ref = "Indymedia Documentation Project. http://docs.indymedia.org/."
#ref = "Sturmer, S., Simon, B., Loewy, M., and Jörger, H. (2003) The dual-pathway model of social movement participation:"
ref = "Grey, S. J., asdfsdf, A. B and Serge, M. J. (eds) (2008) Women's Movements: Flourishing or in Abeyance? Routledge, NewYork."
#
ref = "Almeida, P.D. (2003) Opportunity organizationsand threat-induced contention: Protest waves inauthoritarian settings. American Journal of Sociology 109, 345–400."
ref = "Sōmuchō (1995) Tenkanki o Mukaeta Dōwa
Mondai: Heisei gonendo dōwa chiku jittai
haakutō chōsa kekka no kaisetsu (A Turning
Point for the Dōwa Mondai: Analysis of the
Results of the 1993 Survey to Assess Conditions in Dōwa Districts). Chūōhōki Shuppan,
Tokyo."
ref = "Губин, О.И. (2009) От парадигмы к структуризирика-нному лексикону: лингвиситческий и социологическ-ий поворт Томаса Куна (From paradigm to structured lexicon: Thomas Kuhn's linguistic and sociological turn.) Сониология 4, 28-48. Available online at: [invalid URL removed]."
single_name = match(r"(\w+),\s*(\w+\.*\w\.)*\s*", ref)
datematch = match(r"\(\d{4}\)", ref)
single_name.offsets
datematch.offsets
offs = single_name.offsets[1] + length(single_name.match)
ref[offs:end]

graphemes(ref, offs:(length(ref)-1))



@run  aa = Bibitem(ref)

ref = "Constitution of the Bolivarian Republic of Venezuela
(1999)."
ref = "César Chávez Foundation. www.cesarechavez
foundation.org."
ref = "O’Brien, K.J. (ed.) (2008) Popular Protest in China.
Harvard University Press, Cambridge, MA."

ref = "Ó Dochartaigh, N. (2005) From Civil Rights to
Armalites: Derry and the Birth of the Irish Troubles.
Palgrave Macmillan, Basingstoke."
ref ="Martin Luther King, Jr. Research and Education Institute (2012) Stanford University. www.stanford.edu/group/King/liberation_
curriculum/resources/, accessed Mar. 12, 2012."
ref = "Губин, О.И. (2009) От парадигмы к структуризирика-нному лексикону: лингвиситческий и социологическ-ий поворт Томаса Куна (From paradigm to structured lexicon: Thomas Kuhn's linguistic and sociological turn.) Сониология 4, 28-48. Available online at: [invalid URL removed]"
ref = "Osborn, A. Violence and hatred in Russia's new skinhead playground. Independent (Jan. 25). www.independent.co.uk/news/world/europe/violence-and-hatred-in-russias-new-skinhead-playground-488154.html, accessed Apr. 16, 2012."





for (i,c) in enumerate(ref)
   println("$i => $c")
end


aa = Bibitem(ref)
aa
@run a= Bibitem(match(r"a","awsdf"), nothing, nothing, nothing)

Vector{RegexMatch{S}} where {S<: AbstractString} <: Vector

=#