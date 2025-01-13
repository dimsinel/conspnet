using PDFIO
import DataFrames


struct bibnames
    name::RegexMatch
    ref::String
    function bibnames(ref::String)
        # a word, a comma a space, a wor d, a possible '.', space, a third possible word 
        single_name = r"^(\w+),\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        second_name = r"(\w+)\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        etal = r"^(\w+),\s(\w+)+,\set\sal[.,]\s(\d{4})"

    end
end

mutable struct MyData
    biblio::Dict{Any,Any}
    fullref2short::Dict{String,Any}  # Dict{String,SSubString{String}}
    shortref2full::Dict{String,Any}  # {String,String}

    #   
    title::String
    start_search::Int64
    n::Integer # 1
    noDate::String #"No_Date"
    breaker::Bool
    ref_end::Int64 # where the next item starts
end

mutable struct Texts
    txt::String
    ency::String
end


"""
​```
    getPDFText(src, out) -> Dict 
​```
- src - Input PDF file path from where text is to be extracted
- out - Output TXT file path where the output will be written
return - A dictionary containing metadata of the document
"""
function getPDFText(src, out)
    # handle that can be used for subsequence operations on the document.
    doc = pdDocOpen(src)

    # Metadata extracted from the PDF document. 
    # This value is retained and returned as the return from the function. 
    docinfo = pdDocGetInfo(doc)
    open(out, "w") do io

        # Returns number of pages in the document       
        npage = pdDocGetPageCount(doc)

        for i = 1:npage

            # handle to the specific page given the number index. 
            page = pdDocGetPage(doc, i)

            # Extract text from the page and write it to the output file.
            pdPageExtractText(io, page)

        end
    end
    # Close the document handle. 
    # The doc handle should not be used after this call
    pdDocClose(doc)
    return docinfo
end

#################################################################333
function find_title(sym::AbstractString, txt::String, in_page::UnitRange)
    mysym = strip(sym)
    @show mysym
    title = findnext(mysym, txt, in_page[1])
    if isnothing(title)
        change_linefeed = false
        if occursin(r"\n$", mysym)
            change_linefeed = true
            mysym = replace(mysym, "\n" => "")
        end
        mysym = change_symbols(mysym)
        if change_linefeed
            mysym = mysym * "\n"
        end
        println("changed $sym, $mysym")
    end

    title = findnext(mysym, txt, in_page[1])
    println(mysym, "  $title   ", in_page[1])
    # check if this is the first word in the page: in this case it is a headr, ignore it
    if title[1] == in_page[1] # this is the header
        title = findnext(mysym, txt, title[end])
    end

    # check that this is in the correct page!
    if title[end] > in_page[end]

        #in_page = (in_page[1]+1):in_page[end]
        title = findnext(mysym, txt, in_page[1] + 1)
        #usethis = replace(mysym,"\n"=>"")

        #println(title, in_page[end])
        #println("Error at page $in_page, title $mysym, $title.")
        #return nothing
    end

    return title

end



##############################################

function change_symbols(sym)
    mysym = nothing
    if occursin("Reserve Bank", sym)
        mysym = replace(sym, "Bank" => "System")

    elseif occursin("Zionist Occupied Government", sym)
        mysym = replace(sym, "Zionist Occupied Government" => "ZOG")

    elseif occursin("Liddy, G Gordon", sym)
        mysym = replace(sym, "G G" => "G. G")

    elseif occursin("F, Assassin", sym)
        mysym = replace(sym, "F," => "F.,")

    elseif sym == "Warren Commission"
        mysym = "Warren Commission Report"

    elseif sym == "Hoover, Edgar J"
        mysym = "Hoover J Edgar"

    elseif sym == "mk-ultra"
        mysym = "MK-ULTRA"

    elseif sym == "Johnson, Lyndon B"
        mysym = "Johnson, Lyndon Baines"

    elseif sym == "Smith, Gerald L K"
        mysym = "Smith, Gerald L. K."

    elseif sym == "The Manchurian Candidate"
        mysym = "Manchurian Candidate"

    elseif sym == "King, Martin Luther, Jr, Assassination of"
        mysym = "King, Martin Luther, Jr., Assassination of"

    elseif sym == "Ruby Ridge Incident"
        mysym = "Ruby Ridge"

        # elseif sym == "Burroughs, William S"
        #     mysym = "Burroughs, William S."

    elseif sym == "Central Ingelligence Agency"
        mysym = "Central Intelligence Agency"

    elseif sym == "CIA"
        mysym = "Central Intelligence Agency"

    elseif sym == "Venona Project"
        mysym = "Venona"

    elseif sym == "Roosevelt, Franklin Delano"
        mysym = "Roosevelt, Franklin D"

    elseif sym == "Roosevelt, Franklin D."
        mysym = "Roosevelt, Franklin D"

    elseif occursin("Larouche", sym)
        mysym = replace(sym, "Larouche" => "LaRouche")

    elseif occursin("Tonkin Gulf", sym)
        mysym = "Tonkin Gulf Incidents"

    elseif occursin("USS Maine", sym)
        mysym = "USS Maine"

    elseif occursin("House UnAmerican", sym)
        mysym = replace(sym, "UnAm" => "Un-Am")

    elseif occursin("Molly Maguires", sym)
        mysym = "Molly Maguires"

    elseif occursin("Pakula", sym)
        mysym = "Pakula, Alan J."

    elseif occursin("immerman", sym)
        mysym = "Zimmermann Telegram"

    elseif occursin("Rockefeller Family", sym)
        mysym = "Rockefeller Family"

    elseif sym == "The X-Files"
        mysym = "X-Files"

    elseif sym == "The Spotlight"
        mysym = "Spotlight"

    elseif sym == "Warren Commission"
        mysym = "Warren Commission Report"

    elseif sym == "KnowNothings"
        mysym = "Know-Nothings"

    elseif sym == "The Illuminatus! Trilogy"
        mysym = "Illuminatus! Trilogy"

    elseif sym == "The Iron Heel"
        mysym = "Iron Heel"

    elseif sym == "Pan Am Flight 103"
        mysym = "Pan Am 103"

    elseif sym == "Mae Brussel"
        mysym = "Brussell, Mae"

    elseif sym == "MJ12"
        mysym = "MJ-12"

    elseif sym == "House Un-American Activities  Committee"
        mysym = "House Un-American Activities Committee"

    elseif sym == "Kennedy, Robert, Assassination of"
        mysym = "Kennedy, Robert F., Assassination of"

    elseif occursin("Pierce, William", sym)
        mysym = "Pierce, William L."

    elseif occursin("Constitution", sym)
        mysym = "Constitution, U.S."

    elseif occursin("OneWorld", sym)
        mysym = "One-World Government"

    elseif occursin("Johnson, Lyndon", sym)
        mysym = "Johnson, Lyndon Baines"

    end
    if isnothing(mysym)
        return sym
    end
    return mysym
end
#######################################3333

function make_replacements(txt)

    txt = replace(txt, "eserve Bank" => "eserve System")

    txt = replace(txt, "Zionist Occupied Government" => "ZOG")

    txt = replace(txt, "Liddy, G Gordon" => "Liddy, G. G")

    txt = replace(txt, "F, Assassin" => "F., Assassin")

    txt = replace(txt, "Warren Commission" => "Warren Commission Report")

    txt = replace(txt, "Hoover, Edgar J" => "Hoover, J Edgar")

    txt = replace(txt, "mk-ultra" => "MK-ULTRA")

    txt = replace(txt, "Johnson, Lyndon B" => "Johnson, Lyndon Baines")

    txt = replace(txt, "Smith, Gerald L K" => "Smith, Gerald L. K.")

    txt = replace(txt, "The Manchurian Candidate" => "Manchurian Candidate")

    txt = replace(txt, "King, Martin Luther, Jr, Assassination of" => "King, Martin Luther, Jr., Assassination of")

    txt = replace(txt, "Ruby Ridge Incident" => "Ruby Ridge")

    txt = replace(txt, "Burroughs, William S.." => "Burroughs, William S.")

    txt = replace(txt, "Central Ingelligence Agency" => "Central Intelligence Agency")

    txt = replace(txt, "CIA" => "Central Intelligence Agency")

    txt = replace(txt, "Venona Project" => "Venona")

    txt = replace(txt, "Roosevelt, Franklin Delano" => "Roosevelt, Franklin D")

    txt = replace(txt, "Roosevelt, Franklin D." => "Roosevelt, Franklin D")

    txt = replace(txt, "Larouche" => "LaRouche")

    txt = replace(txt, "Tonkin Gulf Incidents" => "Tonkin Gulf")

    # elseif occursin("USS Maine", txt)
    #     txt = "USS Maine"

    txt = replace(txt, "House UnAmerican" => "House Un-American")

    # elseif occursin("Molly Maguires", txt)
    #     txt = "Molly Maguires"

    txt = replace(txt, "Pakula, Alan J." => "Pakula, Alan")

    txt = replace(txt, "immerman " => "immermann")

    txt = replace(txt, "Rockefeller family" => "Rockefeller Family")

    txt = replace(txt, "The X-Files" => "X-Files")

    txt = replace(txt, "The Spotlight" => "Spotlight")

    txt = replace(txt, "Warren Commission" => "Warren Commission Report")

    txt = replace(txt, "KnowNothings" => "Know-Nothings")

    txt = replace(txt, "The Illuminatus! Trilogy" => "Illuminatus! Trilogy")

    txt = replace(txt, "The Iron Heel" => "Iron Heel")

    txt = replace(txt, "Pan Am Flight 103" => "Pan Am 103")

    txt = replace(txt, "Mae Brussel" => "Brussell, Mae")

    txt = replace(txt, "MJ12" => "MJ-12")

    txt = replace(txt, "House Un-American Activities  Committee" => "House Un-American Activities Committee")

    txt = replace(txt, "Kennedy, Robert, Assassination of" => "Kennedy, Robert F., Assassination of")

    txt = replace(txt, "Pierce, William L." => "Pierce, William L.")

    txt = replace(txt, "Constitution, U.S." => "Constitution, U.S.")

    txt = replace(txt, "One-World" => "OneWorld")

    txt = replace(txt, "Johnson, Lyndon Baines" => "Johnson, Lyndon")

    txt = replace(txt, "Johnson, Lyndon B" => "Johnson, Lyndon")

    txt = replace(txt, "Hollywood 10" => "Hollywood Ten")
    txt = replace(txt, "Hoover, J." => "Hoover J")
end
#######################################3333

# function f1!(x)
#     replace(x,"a"=>"A")
# end
# function f2(x)
#     x="f2"
# end

#################################################3
function find_page(positio::Int, pages::Dict)
    for (key, val) in pages
        if val[1] <= positio < val[end]
            return key
        end
    end
    println("Given position not found")
    return nothing
end

###########################################33
function get_refs(a::UnitRange, b::UnitRange, txt::String)
    #for every see also there is a References afterwards
    ref = findnext("Reference", txt, a[end])
    #@show a, b
    #what if there are no refs in this item?
    if ref[1] > b[end]
        #In this case just use the next title
        println("no References in this item!")
        ref = b
    else
        refs
    end

    salsos = txt[(a[end]+2):(ref[1]-1)]
    #println("salsos _______ $salsos")
    # check if there is a page break here -- it should also contain a page number
    if occursin("\f", salsos)
        #@show salsos
        # the first word after the page break is a header
        salsos = split(salsos, "\f")
        # page braks are of the form "\n\n57\n\n\f"
        salsos[1] = replace(salsos[1], r"\W{1,}\d{1,}?\W{1,}" => " ")
        splitsalsos = split(salsos[2], ";")[2:end]
        #@show salsos[1], splitsalsos, length(splitsalsos)
        #if length(splitsalsos) != 0\
        salsos = length(splitsalsos) > 0 ? salsos[1] * splitsalsos[1] : salsos[1]
    end

    salsos = replace(salsos, "." => "")
    salsos = replace(salsos, "\n" => " ")
    salsos = split(salsos, ";") .|> strip
    #println("2 --- a=$a, b=$b, txt[b]=$(txt[b])" )
    #println("2 salsos ------ " , salsos)
    return salsos
end
##################################################

function load_df(df::DataFrames.DataFrame, salsos::Vector{SubString{String}})

    for sym in salsos
        mysym = change_symbols(sym)

        #@show sym, mysym
        mysymrow = findfirst(x -> x == Symbol(mysym), df.Index)
        @show sym, mysym, mysymrow
        # localtes the index no of row with the element salsos in its first column
        df[mysymrow, mysym] += 1

    end

end



function find_numeral_in_entry_line(line::String)

    bibitem = replace(line, "RR " => "", "." => " ") |> split
    #bibitem = [tryparse.(Int,x) for x in bibitem ]
    bibitem = filter.(isdigit, bibitem)
    bibitem = bibitem[bibitem.!=nothing]  # removes nothings

end


#
################################################
function get_shortref(ref, date)
    # For Knight book
    # tHIS is a pain. Depending on the way the second name is written, this 
    # function must change...
    if occursin("L.S.M", ref)
        ref = replace(ref, "L.S.M." => "L_S_M")
        @show ref
    end
    if occursin("A. B.", ref)
        ref = replace(ref, "A. B." => "A_B_ ")
        @show ref
    end

    if startswith(ref, "U.S. ")
        ref = replace(ref, "U.S. " => "US_")
    end


    splitref = (@pipe split(ref, ",") |> split.(_, "."))
    # datematch = match(r"(\(\d{4}\))", ref) # 4 digit number enclosed in parens(1234)
    # splitref = String[]

    # push!(splitref, ref1 )
    # ref2 = ref[findfirst(datematch.captures[1], ref)[end]+1:end]

    shortref = replace(splitref[1][1], "_" => ". ")
    shortref = shortref * "  " * date

    if startswith(ref, "A_B_ ")
        shortref = "A. B. 1972"
    end

    if startswith(ref, "Martin, Albro")
        shortref = "Martin No_Date"
    end

    if startswith(ref, "Steam")
        shortref = "Steamshovel No_Date"
    end

    if startswith(ref, "Institute of Medicine")
        shortref = "Institute of Medicine 1999"
    end
    if startswith(ref, "Subcommittee on Crime of the Committee")
        shortref = "Subcommittee on Crime 1996"
    end
    if startswith(ref, "Reefer Madness")
        shortref = "Reefer Madness 1938"
    end
    if startswith(ref, "Global Survival Network (GSN)")
        shortref = "Global Survival Network GSN 1997"
    end
    if startswith(ref, "Southern Poverty Law Center (SPLC)")
        shortref = "Southern Poverty Law Center SPLC 1997"
    end
    return ref, splitref, strip(shortref)
end
################################################
function get_shortref2(ref, date)

    datepoint = findfirst(date, ref)

    
    if startswith(ref, "Staggenborg, S., Eder, D., and")
    #     datepoint = "(1993-1994)"
    # end
    splitref = (@pipe split(ref[1:datepoint[begin]], ",") |> split.(_, "."))
    # datematch = match(r"(\(\d{4}\))", ref) # 4 digit number enclosed in parens(1234)
    # splitref = String[]

    # push!(splitref, ref1 )
    # ref2 = ref[findfirst(datematch.captures[1], ref)[end]+1:end]

    shortref = replace(splitref[1][1], "_" => ". ")
    shortref = shortref * "  " * date

    if startswith(ref, "Indymedia Documentation Project")
        shortref = "Indymedia Documentation Project (No Date)"
    end
    
    return ref, splitref, strip(shortref)
end

#############################################3
function change_title(title, ency)
    # try if tehre is a starting The
    tt = ""
    if startswith(title, "The ")
        tt = replace(title, "The " => "")

        if occursin(tt, ency)
            return tt
        end
    else
        #     println(title, occursin(title, ency))


        if title == "Roosevelt, Franklin D."
            tt = "Roosevelt, Franklin Delano"
            # elseif title == "The Dorr War"
            #     title = "Dorr War"

            return tt
        end
    end
    return title
end



################################################33
function is_in_biblio(shortref, bibitem_string)
    made_changes = false
    if shortref ∈ bibitem_string # tehre is oalready a ref fron thw same aytor and year
        made_changes = true # we are going to add something eventually
        notfoundityet = true

        while notfoundityet
            println(shortref, " ∈ bibitem_string:   ", bibitem_string)
            # this is either "ref (1234)", or "ref (1234) (1)
            m = match(r"\((\d{1})\)", shortref) # match the final "(i)"
            if isnothing(m) # no final number found
                shortref *= " (1)" # add one
            else
                new_num = tryparse(Int, m[1])

                if !isnothing(new_num)
                    new_num += 1
                    shortref = replace(shortref, r"(\(\d{1}\))" => string(" (", new_num, ")"))
                    @show shortref
                end
            end
            if shortref ∉ bibitem_string
                notfoundityet = false # found it!
                break
            end
        end

    end
    return strip(shortref), made_changes
end
#########################################

#################################################3
function bootstrap(infile::String)
    ###3
    infile = infile |> FileDocument
    txt = Texts(text(infile),
        (datadir("exp_pro", "ency_items.txt") |> FileDocument |> text))

    txt.txt = replace(txt.txt, "\u201c" => String(raw"\""))
    txt.txt = replace(txt.txt, "’" => String(raw"'"))

    txt.ency = (datadir("exp_pro", "ency_items.txt") |> FileDocument |> text)
    txt.ency = replace(txt.ency, "\u201c" => String(raw"\""))
    txt.ency = replace(txt.ency, "’" => String(raw"'"))

    # This is ufortunate, but due to misspellings int ie book...
    #txt =  make_replacements(txt)
    #"""

    dat = MyData(Dict{String,String}(),
        Dict{String,String}(),
        Dict{String,String}(),
        "",
        1,
        1,
        "No_Date",
        false,
        0,)

    return dat, txt
end

#################################################3
function find_title(txt::Texts, dat::MyData)

    tit_start = findnext("## ", txt.txt, dat.start_search)
    if isnothing(tit_start)
        return nothing # Base.nothing_sentinel
    else
        tit_start = tit_start[end]
    end

    tit_end = findnext("\n", txt.txt, tit_start)[1]
    dat.title = strip(txt.txt[tit_start:tit_end])
    #println("=========  ",title)
    dat.title = change_title(dat.title, txt.ency)
    println("=========  ", dat.title)
    #occursin("Aryan", dat.title) && break
    ref_start = findnext("RR ", txt.txt, tit_end)[end]
    dat.ref_end = findnext("++", txt.txt, ref_start)[1]
    #@show ref_end, typeof(ref_end)

    refs = split(txt.txt[ref_start:dat.ref_end], "RR ")
    refs = replace.(refs, "\n" => "")
    refs = filter(!=(""), refs)
    refs = filter(!=(" "), refs)

    return refs

end

###############################################

function break_refs(refs, dat, bibitem_string)

    for refwBlanks in refs #loop over references of the current title
        ref = strip(refwBlanks)
        if ref == ""
            @show dat.title, refs
            dat.breaker = true
        end
        # if startswith(ref, "Waco dat.breaker") 
        #     println(">>>>>>>>>>>> ",title)
        #     global dat.breaker = true
        # end
        if startswith(ref, '"')
            ref = replace(ref, "\"" => "")
        end


        #datematch = match(r"[^\[](\d{4})", ref) # 4 digit number, but not if thery are of the form [1234]
        datematch = match(r"(\(\d{4}\))", ref) # 4 digit number enclosed in parens(1234)

        # a word, a comma a space, a word, a possible '.', space, a third possible word 
        # single_name = r"^(\w+),\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        single_name = r"^(\w+),\s*(\w+\.*\w\.)*\s*"
        single_backup = r"^(\w+)"
        second_name = r"(\w+)\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        etal = r"^(\w+),\s(\w+)+,\set\sal[.,]\s(\(\d{4}\))"

        @show dat.title
        #@show  etal

        #@show ref
        println()#
        found_single = false

        fname = match(single_name, ref)
        if isnothing(fname)
            println("single name fname is nothing.")
            fname = match(single_backup, ref)
            println("trying backup for ref:", ref)
        end
        #if this is still empty, then there are no references
        if isnothing(fname)
            dat.biblio[dat.title] = []
            continue
        end

        date = dat.noDate
        if !isnothing(datematch)
            date = datematch.captures[1]
            # remove parens, if they exist, eg in (1999)
            date = strip(date, ['(', ')'])
            #@show datematch.offsets
        end

        # # is this enough?
        # we might have a date as the last part of the name
        ## !!!!!!!!!!!!!!!! BUUUUG !!!!!!!!!!!!!!!!!!!!!!!
        if length(fname.captures) == 3
            if !isnothing(datematch)

                if fname.captures[3] == date
                    # ok get the name and date and get out ### WHAT??
                end
            end
        end


        found_etal = false
        if occursin(etal, ref)
            println("found etal in ", ref)
            found_etal = true
            #readline()
        end
        @show ref, date
        # choose get_shortref according to book...
        #ref, splitref, shortref = get_shortref(ref, date)
        ref, splitref, shortref = get_shortref2(ref, date)

        found_double = false
        sname = nothing
        if found_etal
            # there is already a date here, remove it first and then ad et al
            #shortref = replace(shortref, r"\s+\d{4}"=>"")*" et al "*date
            shortref = replace(shortref, date => "et al " * date)
        else
            #check for second author, in case no et al was found
            #tempslit = length(splitref) > 1 ? splitref[2] : splitref
            #@show tempslit
            @show ref
            @show fname
            #@show date, shortref
            if !isnothing(datematch)
                #@show max(fname.offsets...), max(datematch.offsets...)
                if max(fname.offsets...) + 3 <= max(datematch.offsets...)
                    # lets look if there is a "and" here
                    #@show fname.captures[end]
                    andmatch = match(r"\s?(and)", ref, max(fname.offsets...))
                    if !isnothing(andmatch)
                        #println("No 'and' found")
                        #else
                        #@show andmatch  andmatch.offsets
                        if max(fname.offsets...) <= andmatch.offsets[1] <= max(datematch.offsets...)
                            # this is an author 'and'
                            sname = match(second_name, ref, andmatch.offsets[1]) # + length("and"))
                            @show sname
                            if !isnothing(sname)
                                # find the last non-nothing entry, which must also starts w/ a capital letter name
                                my_cond = x -> isnothing(x) || isnothing(match(r"^[A-Z]", x))
                                last_non_nothing = findlast(!my_cond, sname.captures)
                                first_non_nothing = findfirst(!my_cond, sname.captures)
                                ##last_non_nothing = findlast( !isnothing, sname.captures)
                                
                                # Knight uses the format A. B. Cdefg for the second author
                                #capts = sname.captures[1:last_non_nothing]
                                
                                # this is for the format of the second author same as the first
                                capts = sname.captures[1:first_non_nothing]

                                #now first eliminate any numbers that are here (ie dates)
                                capts = capts[findall(isnothing, match.(r"\s?\d+\s?", capts))]
                                addedstring = "and " * capts[end] * " "
                                shortref = replace(shortref, date => addedstring * date)
                            end
                        end
                    end
                    #@show match(r"\w+"*date,ref, max(fname.offsets...) )
                end
            end
        end

        if !isnothing(sname)
            # add a second name to shortref
        end

        shortref = split(shortref)
        matchdate_atend = match(r"\d{4}", strip(shortref[end]))
        if isnothing(matchdate_atend) && shortref[end] != dat.noDate
            println(shortref, " There was a problem, Breaking")
            break
        end
        shortref[end] = "(" * shortref[end] * ")"
        shortref = join(shortref, " ")
        shortref = strip(shortref)
        @show "before show " shortref
        # this one just constructs a new name if the current name already exists in bibitem_string
        # made_changes == true means that a new name was constructed, otherwise the same name is reurnd
        shortref, made_changes = is_in_biblio(shortref, bibitem_string)
        # in both cases, shortref must be added in bibitem_string

        println("after show ", shortref, "  ", made_changes)
        println(bibitem_string)


        shortref = split(shortref)
        # check if the last term is (1), (2) etc
        last_term_multiplicity = match(r"\(\d{1}\)", strip(shortref[end]))
        last_term = ""
        if !isnothing(last_term_multiplicity)
            last_term = pop!(shortref)
        end

        push!(shortref, last_term)
        shortref = join(shortref, " ")
        shortref = strip(shortref)
        println("---> ", shortref, ", ", ref)

        push!(bibitem_string, shortref)
        if ref ∉ keys(dat.fullref2short)
            dat.fullref2short[ref] = [shortref]
        else
            @pipe shortref |> push!(dat.fullref2short[ref], _)
        end

        if shortref ∉ keys(dat.shortref2full)
            dat.shortref2full[shortref] = [ref]
        else
            @pipe ref |> push!(dat.shortref2full[shortref], _)
        end

        if dat.title ∉ keys(dat.biblio)
            dat.biblio[dat.title] = [shortref]
        else
            @pipe shortref |> push!(dat.biblio[dat.title], _)
        end
        datematch = nothing
        date = nothing
        @show shortref

    end
    # 
end
#################################################3

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
        # if dat.n > 10
        #     break
        # end

        #fullref2short, shortref2full = 
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


#


##############################3