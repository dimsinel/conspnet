using PDFIO
import DataFrames

datematcher = r"(\(\d{4}([,\/\-;])?(\s?\d{4})?(.)?\))"
#namematcher = r"(((?:De )|(?:V[ao]n )|(?:[DO]\S))?\w+,\s*[A-Z]?\.?,*\s?[[A-Z]\.]?)"  #r"(\w+),\s*[A-Z]?\.?,*\s?[A-Z]?\.?"
# possible 3 parts in name: Either Aaaaa Bbbbb B. , pr Aaaaa, A. B.
first = r"(((?:De )|(?:V[ao]n )|(?:[DO]\S))?\w+,?)"
webdubois = r"((?:Du )?\w+,\s(?:[A-Z]\.){3}?)"
second = r"(\s*(\w+|([A-Z]))[,\.\s])"
#third = r"\s?((\w+|[A-Z]\.)[,\.\s]?)?" # 
#third = r"\s?((\w+|[A-Z]\.){1-2}[,\.\s]?)?" # 
third = r"\s?(((?:[A-Z]\.(?:[A-Z]\.))|\w+)[,\.\s]?)?" # 
m
namematcher = first * second * third
namematcheralt = webdubois


mutable struct Texts
    txt::String
    titles::Vector{String}
    filename::String
end

######################
struct Dicts
    namedate2short::Dict{String,String}  # Dict{String,SSubString{String}}
    short2namedate::Dict{String,String}  # {String,String}
end

#################################################3
abstract type AbsBibitem end

mutable struct Bibitem{S<:AbstractMatch} <: AbsBibitem

    authors::Union{Nothing,Vector{S}} # Union{Nothing,RegexMatch{String}}[]
    etal::Union{Nothing,S}
    datematch::Union{Nothing,S}
    andmatch::Union{Nothing,S}
    title::Union{Nothing,String}
    names_date_str::Union{Nothing,String}

end

Bibitem() = Bibitem(RegexMatch[], nothing, nothing, nothing, nothing, nothing)


function Bibitem(ref::S) where S<:AbstractString

    ref2d = ref
    authors = Vector{RegexMatch{S}}

    # A regex that (hopoefully) finds "Name, A. J", "Van Name, A.J","Von Name, A.J" , "De Name, A J", "D'Name, AJ"
    global namematcher
    global datematcher

    # this should have a differetn name, there is a global datematch already
    datematch = match(datematcher, ref)
    matches = [r"(\(forthcoming\))", r"(\(n.d.\))", r"(\(no date\))", r"(\(No Date\))"]
    if isnothing(datematch)
        # check for other rare cases
        for match_it in matches
            datematch = match(match_it, ref)
            if !isnothing(datematch)
                break
            end
        end
    end
    #     datematch = match(r"(\(forthcoming\))", ref)
    #     if isnothing(datematch)
    #         # check for other rare cases
    #         datematch = match(r"(\(forthcoming\))", ref)
    #         if isnothing(datematch)
    #             datematch = match(r"(\(n.d.\))", ref)
    #         end
    #     end
    # end
    if isnothing(datematch)
        return special_cases(ref)
    end
    #@show ref


    # All the names must be before the date
    ref2d = ref[1:datematch.offsets[1]-1]
    # we dont need any editiors
    eds = r"\([Ee]ds?\.?\)\.?"
    edmatch = match(eds, ref2d) 
    if !isnothing(edmatch)
        ref2d = replace(ref2d, edmatch.match=>"")
    end


    etal = match(r"\set\sal[.,]?", ref2d)
    andmatch = match(r"\s(and)\s", ref2d)
    #println("$ref, $(datematch.offsets)")
    tit_start = findnext(")", ref, datematch.offsets[1])[end]
    title = ref[tit_start:end]

    firsttime = true
    while true

        # we try first with namematcheralt which captures names like du bois w.w.w.
        single_name = match(namematcheralt, ref2d)

        # and then w/ normal match
        if isnothing(single_name)
            single_name = match(namematcher, ref2d)
        end


        # if this didn't work
        if isnothing(single_name)
            # this might be the case of a newspaper article with no authors
            single_name = ref2d |> strip
            # convert to a match
            @show single_name
            single_name = match(Regex(single_name), single_name)
        end

        if isnothing(single_name)
            if firsttime
                return Bibitem()
            else
                break
            end
        end

        # we have a match for at least a name
        if firsttime
            authors = [single_name]
            firsttime = false
        else
            push!(authors, single_name)
        end

        try 
            firstnonzero = findfirst(>(0), single_name.offsets)
            offs = single_name.offsets[firstnonzero] + length(single_name.match)
        catch e 
            println(e)
            println("auhtor is $(single_name)")
            break
        end

        if length(ref2d) - offs < 2 # no name of 1 char or less
            break
        end

        try
            ref2d = ref2d[offs:end]
        catch e
            @warn "Error in Bibitem cstor"
            println(e)
            @show single_name
            println("Using graphemes to get the rest of the string")
            ref2d = graphemes(ref2d, offs:(length(ref2d)-1))
            @show ref2d
        end
        #n_of_authors += 1
        #@show single_name, single_name.offsets
    end

    up2date = datematch.offsets[1] + length(datematch.match)
    return Bibitem(authors, etal, datematch, andmatch, title, ref[1:up2date-1] |> String)
end

#################################################3
mutable struct MyData
    # This should be 2 structs, one for the containers, 
    # and one (immutabel) for the item relevant quantities 
    # like title, start_search etc

    biblio::Dict{Any,Any}     # item title => list of namedates

    biblio_item::Dict{String,Bibitem}  # biblio => bibitems

    fullref2short::Dict{String,String}  # Dict{String,SSubString{String}}
    shref2full::Dict{String,String}  # {String,String}
    see_also::Dict{String,Any}
    #   
    namedates::Set{String}

    title::String
    start_search::Int64
    n::Integer # 1
    noDate::String #"No_Date"
    #breaker::Bool
    ref_end::Int64 # where the next item starts
end

######################

function bootstrap(infilename::String)
    ###3
    infile = infilename |> FileDocument
    txt = Texts(text(infile),
        [""],
        infilename)
    #(datadir("exp_pro", "ency_items.txt") |> FileDocument |> text),)

    txt.txt = replace(txt.txt, "\u201c" => String(raw"\""))
    txt.txt = replace(txt.txt, "’" => String(raw"'"))

    txt.txt = replace(txt.txt, "”" => String(raw"\""))
    txt.txt = replace(txt.txt, "“" => String(raw"\""))

    txt.txt = replace(txt.txt, "della Port" => "dellaPort", "Opp, K.-D" => "Opp, K.D")
    #txt.txt = replace(txt.txt, "Opp, K.-D" => "Opp, K.D")

    txt.txt = Unicode.normalize(txt.txt)

    tits = findall(r"##\s(.*)\n", txt.txt)
    txt.titles = map(tits) do x

        beg = x[begin] + 3
        en = x[end] - 1
        txt.txt[beg:en]

    end .|> strip


    # txt.ency = (datadir("exp_pro", "ency_items.txt") |> FileDocument |> text)
    # txt.ency = replace(txt.ency, "\u201c" => String(raw"\""))
    # txt.ency = replace(txt.ency, "’" => String(raw"'"))

    # This is ufortunate, but due to misspellings int ie book...
    #txt =  make_replacements(txt)
    #"""

    dat = MyData(Dict{String,Vector{String}}(),
        Dict{String,Bibitem}(),
        Dict{String,String}(),
        Dict{String,String}(),
        Dict{String,String}(),
        Set{String}([]),
        "",
        1,
        1,
        "No_Date",
        #false,
        0,)

    #dicts = Dicts(Dict{String,String}(), Dict{String,String}())

    return dat, txt
end

#################################################

function find_title(txt::Texts, dat::MyData)
    """
    Find the title of the current entry, the references, and the see also entries
    Return the references and put teh see also into the dictionary of the dat struct
    """
    tit_start = findnext("## ", txt.txt, dat.start_search)
    if isnothing(tit_start)
        return nothing # Base.nothing_sentinel
    else
        tit_start = tit_start[end]
    end

    tit_end = findnext("\n", txt.txt, tit_start)[1]
    dat.title = strip(txt.txt[tit_start:tit_end])

    #dat.title = change_title(dat.title, txt.ency)

    # sanity 
    f = findall(==(dat.title), txt.titles)
    if length(f) != 1
        error("Error finding title $(dat.title)")
    end
    println("\n\n=========  ", dat.title)
    #occursin("Aryan", dat.title) && break

    seealso_start, seealso_end = 0, 0
    if occursin("Snow", txt.filename)
        seealso_start = findnext("SEE ALSO: ", txt.txt, tit_end)[end]
        seealso_end = findnext("\nREFERENCES AND", txt.txt, tit_end)[begin]
    end
    ref_start = findnext("RR ", txt.txt, tit_end)[end]
    dat.ref_end = findnext("++", txt.txt, ref_start)[1]
    #@show ref_end, typeof(ref_end)

    # if occursin("Visual analysis of social", dat.title)

    #     println(txt.txt[seealso_start:seealso_end])
    #     println(txt.txt[ref_start:dat.ref_end])

    # end



    #sanity
    if seealso_end > ref_start
        error("'SEE ALSO' ends _after_ References. Some mix up has happend ih source txt file.")
    end

    refs = split(txt.txt[ref_start:dat.ref_end], "RR ")
    refs = replace.(refs, "\n" => "")
    refs = filter(!=(""), refs)
    refs = filter(!=(" "), refs)

    if occursin("Snow", txt.filename)
        see_alsos = split(txt.txt[seealso_start:seealso_end], ";")
        see_alsos = replace.(see_alsos, "\n" => " ", r"\.\s*$" => " ")
        #, "." => " ")

        see_alsos = replace.(see_alsos, "\n" => " ")
        see_alsos = filter(!=(""), see_alsos) .|> strip
        # sanity \
        # Check that all of them are ina teh titles
        for sa in see_alsos
            # ssa = sa
            # if !occursin("Lenin", sa)
            #     ssa = replace(sa, "." => " ")
            # end
            f = findall(==(sa), txt.titles)
            if length(f) == 0
                error("Error finding title $(sa)")
            elseif length(f) > 1
                error("Error found $(length(f)) titles $(sa)")
            end
        end

        dat.see_also[dat.title] = see_alsos
    end

    return refs

end

#################################################
function special_cases(ref)
    #@show ref, startswith("Indymedia Documentation", ref)
    if startswith(ref, "Indymedia Documentation Project")
        #retref = "Indymedia Documentation Project"
        return Bibitem([match(Regex(ref), ref)], nothing, match(r"No Date", "No Date"), nothing, String(ref), String(ref))
    end

    if startswith(ref, "Osborn, A. Violence and hatred in Russia")
        # this is a newspaper article, not easily found anymore
        return Bibitem()
    end
    if ref == "César Chávez Foundation. www.cesarechavezfoundation.org"
        ref1 = "César Chávez Foundation"
        ref2 = "www.cesarechavezfoundation.org"
        return Bibitem([match(Regex(ref1), ref1)], nothing, match(r"No Date", "No Date"), nothing, String(ref), match(Regex(ref), ref))

    end

    if ref == "North Dakota Democratic-NPL Party. http://www.demnpl.com."
        ref1 = "North Dakota Democratic-NPL Party"
        #ref2 = "http://www.demnpl.com"
        #rnd = r"North Dakota Democratic-NPL Party \(No Date\)"
        nd = "North Dakota Democratic-NPL Party (No Date)"
        return Bibitem([match(Regex(ref1), ref1)], nothing, match(r"No Date", "No Date"), nothing, String(ref1), nd)
    end

    if ref == "Digger Archives. http://www.diggers.org."

        return Bibitem([match(Regex("Digger Archives"), "Digger Archives")], nothing, match(r"No Date", "No Date"), nothing, "Digger Archives", ref * " (No Date)")
    end

    if occursin("Kirk Collected Papers", ref)
        auth = "Kirk Collected Papers"
        d = "(No Date)"
        return Bibitem([match(Regex(auth), auth)], nothing, match(r"No Date", "No Date"), nothing, auth, auth * " (No Date)")
    end

    if occursin(" www.", ref)
        @show ref
        return Bibitem([match(Regex(ref), ref)], nothing, match(r"No Date", "No Date"), nothing, String(ref), String(ref))

    end
    if startswith(ref, "Global Civil Society")
        short = "Global Civil Society Programme"
        return Bibitem([match(Regex(short), short)], nothing, match(r"No Date", "No Date"), nothing, String(ref), String(ref))

    end
    if startswith(ref, "U.S. Department of Health and Human")
        short = "U.S. Department Health"
        return Bibitem([match(Regex(short), short)], nothing, match(r"No Date", "No Date"), nothing, String(ref), String(ref))
    end

    if occursin("New Harmony Gazette", ref)
        auth = "New Harmony Gazette"
        return Bibitem([match(Regex(auth), auth)], nothing, match(r"No Date", "No Date"), nothing, auth, auth * " (No Date)")
    end

    if startswith(ref, "Why American Civil Liberties Does What It Does")
        auth = "U.S. News and World Report"
        date = "(1984)"
        return Bibitem([match(Regex(auth), auth)], nothing, match(r"(1984)", date), nothing, auth, auth * date)
    end
    if startswith(ref, "Dome Village/Justiceville")
        auth = "Dome Village-Justiceville"
        date = "No Date"
        return Bibitem([match(Regex(auth), auth)], nothing, match(Regex(date), date), nothing, auth, auth * '(' * date * ')')
    end

    if startswith(ref, "Dignity Village (Portland, OR)")
        auth = "Dignity Village (Portland, OR) "
        rauth = r"Dignity Village \(Portland, OR\) "
        ddate = "No Date"
        return Bibitem([match(rauth, auth)], nothing, match(Regex(ddate), ddate), nothing, auth, auth * '(' * ddate * ')')
    end


    #*New Harmony Gazette*. University of Wyoming. Microfiche HN 64N4.

end

###############################################
#=
1 find first author
2 find date
3 find etal
4 find and

5 if etal return
6 if and is after the first author, get the second author and return

7 if no and between 1st and 2nd, find all authors


-> return dict title => authors, date, and the originaal string up until date, in order to 
   be able to create the 


=#
##############################################3
function break_refs!(refs, dat) # , bibitem_string)

    for refwBlanks in refs #loop over references of the current title
        ref = strip(refwBlanks)
        ref = replace(ref, "( " => "(", " )" => ")")
        if ref == ""
            continue
        end

        if startswith(ref, '"')
            ref = replace(ref, "\"" => "", "*" => "")
        end

        refanalysis = Bibitem(ref) # 



        #if this is still empty, then there are no references
        try
            if isnothing(refanalysis.authors) || length(refanalysis.authors) == 0
                dat.biblio[dat.title] = []
                continue
            end

        catch e
            println("Error at $(dat.title)")
            println("ref: $ref")
            #println("After character $(dat.start_search)")
        end

        locshref = refanalysis.names_date_str

        println("=== $(locshref)")
        #@show refanalysis.names_date_str
        #
        check_refs!(dat, refanalysis)
        #is_in_biblio(locshref, bibitem_string) 

        push!(dat.namedates, refanalysis.names_date_str)

        # dicts.namedate2short[refanalysis.names_date_str] = locshref
        # dicts.short2namedate[locshref] = refanalysis.names_date_str

        #push!(bibitem_string, locshref)
        if ref ∉ keys(dat.fullref2short)
            dat.fullref2short[ref] = locshref
        else
            if replace(dat.fullref2short[ref], " " => "") != replace(locshref, " " => "")
                error("key $ref leads to $(dat.fullref2short[ref]) AND to $locshref")
            end
        end
        if locshref ∉ keys(dat.shref2full)
            dat.shref2full[locshref] = ref
        else
            s1 = dat.shref2full[locshref]
            s2 = ref
            if replace(s1, " " => "") |> lowercase != replace(s2, " " => "") |> lowercase
                # if dat.shref2full[locshref] != ref
                if compbychar(s1, s2)
                    #error("key $locshref leads to $(s1) AND to $(s2)")
                end
            end
        end

        if dat.title ∉ keys(dat.biblio)
            dat.biblio[dat.title] = [locshref]
        else
            push!(dat.biblio[dat.title], locshref)
        end
        dat.biblio_item[locshref] = refanalysis
    end
end
#  

##################################################
function check_refs!(dat::MyData, refanalysis::Bibitem)
    """
    """
    global datematch

    @show refanalysis.names_date_str, refanalysis.datematch.match
    # we need to make sure bibliographic entries are not dublicates 
    # first see if the refanalysis.names_date_str exists so far


    #println(refanalysis.names_date_str ∈ dat.namedates)
    #@show dat.namedates
    # Have we found this before?

    #  There are some refs where there is an extra space in the date.


    if refanalysis.names_date_str ∈ dat.namedates
        # now check if the 2 namedates reference the same full ref or they are different, 
        # in which case we have a dublicate and we need to change shref

        for (i, k) in dat.biblio
            fref = findall(==(refanalysis.names_date_str), k)

            if fref == []
                continue
            end

            println(">> found $(length(fref)) occurences of $(refanalysis.names_date_str) in $(i)")
            # see if the full ref is the same
            for j in fref
                oldref = k[j]
                oldfullref = dat.shref2full[oldref]
                println("new short ref $(refanalysis.names_date_str)")
                println("new full ref $(dat.shref2full[refanalysis.names_date_str])")
                println("old full ref --> $(oldfullref)")

                # These 2 refs share the sam authors and date. 
                # what happens after the date?
                newref_after_date = dat.shref2full[refanalysis.names_date_str]
                # if there is no date, finder will be nothing
                @show refanalysis.datematch.match
                finder = findfirst(refanalysis.datematch.match, newref_after_date)
                foundnouthing = isnothing(finder)
                if foundnouthing
                    finder = findfirst("(forthcoming)", newref_after_date)
                end
                @show finder

                newref_after_date = newref_after_date[finder[end]:end]
                newref_after_date = replace(newref_after_date, "," => "", " " => "", "*" => "") |> lowercase
                @show newref_after_date
                oldfullref_after_date = ""
                try
                    oldfullref_after_date = oldfullref[findfirst(datematcher, oldfullref)[end]:end]
                    oldfullref_after_date = replace(oldfullref_after_date, "," => "", " " => "", "*" => "") |> lowercase
                catch e
                    oldfullref_after_date = oldfullref[findfirst("(forthcoming)", oldfullref)[end]:end]
                    oldfullref_after_date = replace(oldfullref_after_date, "," => "", " " => "", "*" => "") |> lowercase
                end

                println("new = $(newref_after_date)")
                println("old = $(oldfullref_after_date)")
                if startswith(newref_after_date, oldfullref_after_date) || startswith(oldfullref_after_date, newref_after_date)
                    println("Both refer to the same reference: $refanalysis.names_date_str, we can continue")
                    continue
                end

                # Here we indeed have 2 different refs, going to the same refanalysis.names_date_str.
                # first check the date of the new reference

                dmat = match(datematcher, refanalysis.names_date_str) ##dat.shref2full[refanalysis.names_date_str])
                @show dmat
                if dmat === nothing
                    error("No date found for $(dat.shref2full[refanalysis.names_date_str])")
                end
                if isnothing(dmat.captures[end])
                    # no a, b, etc found after the year
                    println("No a, b, etc ext after date in $(refanalysis.names_date_str), $(dmat.captures)")
                    # add an 'a' after the year
                    startref = refanalysis.names_date_str[1:findfirst(datematcher, refanalysis.names_date_str)[end]-1]
                    endref = refanalysis.names_date_str[findfirst(datematcher, refanalysis.names_date_str)[end]:end]
                    refanalysis.names_date_str = startref * "a" * endref
                    @show refanalysis.names_date_str
                    # also we must
                    #@show dat.names_date_str
                else
                    # we have a, b, etc
                    ch = dmat.captures[end][1] + 1 #next character
                    # if shref is "asdasdf (2001a)", then shref)[end]-2] = "asdasdf (2001"
                    # then we can add ch (which is b,c, d etc) after the year
                    refanalysis.names_date_str = refanalysis.names_date_str[1:findfirst(datematcher, refanalysis.names_date_str)[end]-2] * ch * refanalysis.names_date_str[findfirst(datematcher, refanalysis.names_date_str)[end]:end]
                    @show refanalysis.names_date_str
                end
                @warn "Dublicate reference: $refanalysis.names_date_str"
                #@show("Dublicate reference: $shref")

            end
        end
        #println("shref $(shref) can be found in $(dat.biblio

    end


end

#################################################
function compbychar(s1, s2)
    """
    Returns true if the 2 strings are nontrivially different
    """

    if startswith(s1, "McAdam, D. (1982) Political Process and") &&
       startswith(s2, "McAdam, D. (1982) Political Process and")
        # this is ok, the 2 strings are the same, small differences in the end
        return false
    end
    if startswith(s1, "Koopmans, R., Statham, P., Giugni, M., and Passy,F. (2005) Contested Citizenship") &&
       startswith(s2, "Koopmans, R., Statham, P., Giugni, M., and Passy,F. (2005) Contested Citizenship")
        return false
    end
    if startswith(s1, "Schussman, A., and Soule, S.A. (2005) Process andprotest") &&
       startswith(s2, "Schussman, A., and Soule, S.A. (2005) Process andprotest")
        return false
    end
    if startswith(s1, "Olson, M. (1965) The Logic of Collective Action") &&
       startswith(s2, "Olson, M. (1965) The Logic of Collective Action")
        return false
    end
    if occursin(lowercase("Klandermans, B., van der Toorn, J., and Van Stekelenburg, J. (2008)"), lowercase(s1)) &&
       occursin(lowercase("Klandermans, B., van der Toorn, J., and van Stekelenburg, J. (2008)"), lowercase(s2))
        return false
    end

    if startswith(lowercase(s1), lowercase("Melucci, A. (1989) Nomads of the Present")) &&
       startswith(lowercase(s2), lowercase("Melucci, A. (1989) Nomads of the Present"))
        return false
    end
    if startswith(lowercase(s1), lowercase("Simon, B., Loewy, M., stürmer, S., Weber, U., Freytag, P., Habig, C., Kampmeier, C., and Spahlinger, P. (1998) Collectiv")) &&
       startswith(lowercase(s2), lowercase("Simon, B., Loewy, M., stürmer, S., Weber, U., Freytag, P., Habig, C., Kampmeier, C., and Spahlinger, P. (1998) Collectiv"))
        return false
    end
    if startswith(lowercase(s1), lowercase("Klandermans, B. (1997) The Social Psychology ofProtest. Blackwell")) &&
       startswith(lowercase(s2), lowercase("Klandermans, B. (1997) The Social Psychology ofProtest. Blackwell"))
        return false
    end
    if startswith(lowercase(s1), lowercase("Lichterman, P. (1996) The Search for Poli")) &&
       startswith(lowercase(s2), lowercase("Lichterman, P. (1996) The Search for Poli"))
        return false
    end
    l1 = collect(eachindex(s1))
    l2 = collect(eachindex(s2))
    if l1 != l2
        println("Different length strings $(length(l1)), $(length(l2))")
    end
    llength = min(length(l1), length(l2))
    if s1 != s2
        for i in l1[1:llength]
            if s1[l1[1]:i] != s2[l2[1]:i]
                println("Strnigs differ at the $i char: \n$(s1[l1[1]:i]) vs \n$(s2[l2[1]:i])")
                break
            end
        end
        return true
    else
        return false
    end
end
#############################################
# function getalltitles(infile)
#     begin
#         n = 1
#         tstart = 1
#         tend = 1
#         mytitles = Dict()
#     end
#     while tend < length(infile) # loop over dat.titles
#         #global n += 1

#         tstartr, tendr = gettitles(infile, tend)

#         if isnothing(tstartr)
#             break
#         end

#         @show tstart, tendr
#         tstart = tstartr[end]
#         tend = tendr[begin]
#         tit = infile[tstart:(tend-1)]
#         mytitles[n] = tit
#         n += 1
#         println("title $n  $(tit)")
#     end
#     return sort(mytitles)
# end
################################################
# function gettitles(infile::String, startfrom::Int)

#     nextfind = findnext("## ", infile, startfrom)
#     if isnothing(nextfind)
#         return nothing, nothing
#     end
#     nextendline = findnext("\n", infile, nextfind[end])

#     return nextfind, nextendline

# end
#############################################
function loop_refs_from_txt(infile::String)
    # begin # 172

    dat, txt = bootstrap(infile)

    while true # loop over dat.titles
        dat.n += 1
        println("Item $(dat.n)")
        #dat.breaker = false
        #bibitem_string = String[]

        refs = find_title(txt, dat)
        @show refs
        try
            if dat.title != txt.titles[dat.n-1]
                @show dat.n - 1, dat.title, txt.titles[dat.n-1]
                if dat.n > 2
                    @show dat.n - 2, txt.titles[dat.n-2]
                    @show dat.n, txt.titles[dat.n]
                end
                break
            end
        catch e
            @show dat.n - 1, dat.title, txt.titles[dat.n-2]
        end

        if isnothing(refs)
            break
        end


        break_refs!(refs, dat) #

        println()

        dat.start_search = dat.ref_end
    end

    return dat
end
#############################


# Function to find common substrings between two strings
function common_substrings(s1::String, s2::String)
    common = "" #String[]  # Array to store common substrings
    len1, len2 = length(s1), length(s2)
    if len1 > len2
        s1, s2 = s2, s1
        len1, len2 = len2, len1
    end
    # Check all possible substrings of s1
    for start in 1:len1
        for stop in start:len1
            substring = s1[start:stop]
            if occursin(substring, s2) #&& !(substring in common)
                if length(substring) > length(common)
                    common = substring
                end
            end
        end
    end

    return common
end
#############################

# Function to find common substrings between two strings
function common_graphemes(ss1::String, ss2::String)
    common = "" #String[]  # Array to store common substrings
    s1, s2 = graphemes(ss1), graphemes(ss2)
    len1, len2 = length(s1), length(s2)
    if len1 > len2
        ss1, ss2 = ss2, ss1
        len1, len2 = len2, len1
        s1, s2 = s2, s1
    end
    # Check all possible substrings of s1
    for start in 1:len1
        for stop in start:len1
            substring = graphemes(ss1, start:stop)
            if occursin(substring, ss2) #&& !(substring in common)
                if length(substring) > length(common)
                    common = substring
                end
            end
        end
    end

    return common
end
#############################