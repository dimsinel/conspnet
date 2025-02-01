using DrWatson
@quickactivate "conspnet"

using TextAnalysis
using Pipe
using DataStructures
using Revise

includet(srcdir("functions.jl"))




struct bibnames
    name::RegexMatch
    ref::String
    function bibnames(ref::String)
        # a word, a comma a space, a word, a possible '.', space, a third possible word 
        single_name = r"^(\w+),\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        second_name = r"(\w+)\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        etal = r"^(\w+),\s(\w+)+,\set\sal[.,]\s(\d{4})"

    end
end


begin
    # cant remember why i called it outf, this is the input file, annotated...
    #outf = FileDocument(datadir("ConspiracyKnight_byhand.txt"))
    outf = FileDocument(datadir("Snow.txt"))
    outf = StringDocument(text(outf))
end

#=
begin
    #prepare!(outf, strip_punctuation)
    #remove_words!(outf,[","])
    #stem!(outf)
    ngram = NGramDocument(text(outf),2)   

    crp = Corpus([outf]) 
    update_lexicon!(crp)
    update_inverse_index!(crp)

    lexicon(crp)
    inverse_index(crp)
end
=#


txt = text(outf)

txt = replace(txt, "\u201c" => String(raw"\""))
txt = replace(txt, "’" => String(raw"'"))

ency = (datadir("exp_pro", "ency_items.txt") |> FileDocument |> text)
ency = replace(ency, "\u201c" => String(raw"\""))
ency = replace(ency, "’" => String(raw"'"))

# This is ufortunate, but due to misspellings int ie book...
#txt =  make_replacements(txt)
#"""
#################################################3

knightfile = datadir("ConspiracyKnight_byhand.txt")
#knightfile = datadir("Snow.txt")


function find_refs(knightfile::String)
    #   open(knightfile, "r") do io
    #         write(io, "JuliaLang is a GitHub organization.\n It has many members.\n");
    #     end;

    return nothing
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
    # if startswith(ref, "U.S. House")
    #     ref = replace(ref, "U.S. House" => "US_House")
    # end

    splitref = (@pipe split(ref, ",") |> split.(_, "."))

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


############################################3
################################################
function get_shortref2(ref, date)
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
#############################################
# function get_second_author(ref, shortref, refanalysis)

#     # lets look if there is a "and" here
#     #@show refanalysis.fname.captures[end]

#     if !isnothing(refanalysis.andmatch)

#         #@show andmatch  andmatch.offsets
#         if max(refanalysis.fname.offsets...) <= andmatch.offsets[1] <= max(datematch.offsets...)
#             #second_name = r"(\w+)\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
#             second_name = r"(\w+),\s*[A-Z]\.,\s[A-Z]?"
#             # this is an author 'and'
#             sname = match(second_name, ref, andmatch.offsets[1]) # + length("and"))
#             @show sname
#             if !isnothing(sname)
#                 # find the last non-nothing entry, which must also starts w/ a capital letter name
#                 my_cond = x -> isnothing(x) || isnothing(match(r"^[A-Z]", x))
#                 last_non_nothing = findlast(!my_cond, sname.captures)
#                 first_non_nothing = findfirst(!my_cond, sname.captures)
#                 ##last_non_nothing = findlast( !isnothing, sname.captures)

#                 # Knight uses the format A. B. Cdefg for the second author
#                 #capts = sname.captures[1:last_non_nothing]

#                 # this is for the format of the second author same as the first
#                 capts = sname.captures[1:first_non_nothing]

#                 #now first eliminate any numbers that are here (ie dates)
#                 capts = capts[findall(isnothing, match.(r"\s?\d+\s?", capts))]
#                 addedstring = "and " * capts[end] * " "
#                 shortref = replace(shortref, date => addedstring * date)
#             end
#         end
#     end

#     return shortref
# end


###############################################
################################################33
function is_in_biblio(shortref, bibitem_string)
    made_changes = false
    if shortref ∈ bibitem_string # tehre is already a ref from the same authtor and year
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


#

############################################3
function get_shortref(ref, date)

    datepoint = findfirst(date, ref)


    # if startswith(ref, "Staggenborg, S., Eder, D., and")
    #     datepoint = "(1993-1994)"
    # end

    if startswith(ref, "Indymedia Documentation Project")
        shortref = "Indymedia Documentation Project (No Date)"
        l = length(ref)
        datepoint = l:l
    end

    splitref = (@pipe split(ref[1:datepoint[begin]], ",") |> split.(_, "."))

    shortref = replace(splitref[1][1], "_" => ". ")
    shortref = shortref * "  " * date


    return splitref, strip(shortref)
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


##############################################

#################################################################333
function find_title(sym::AbstractString, txt::String, in_page::UnitRange)
    mysym = strip(sym)
    #@show mysym
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
############################################
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


#############################################
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

############################################3
# if shortref  ∈ bibitem_string # tehre is oalready a ref fron thw same aytor and year
#     println(shortref, " ∈ bibitem_string:   ", bibitem_string)
#     count = 1
#     not_found = true
#     while not_found
#         tempshortref = shortref*" ("*string(count)*")"
#         if tempshortref  ∉ bibitem_string
#             shortref = tempshortref
#             not_found = false
#             @show tempshortref, not_found
#             break
#         else
#             count += 1
#         end

#     end
# end

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
############################################3

begin # 172
    biblio = Dict()
    fullref2short = Dict()
    shortref2full = Dict()

    title = nothing

    global start_search = 1
    n = 1
    global noDate = "No_Date"
end
#################################
#################################
while true # loop over titles
    global n += 1
    global start_search
    global breaker = false
    bibitem_string = String[]

    tit_start = findnext("## ", txt, start_search)
    if isnothing(tit_start)
        break
    else
        tit_start = tit_start[end]
    end
    tit_end = findnext("\n", txt, tit_start)[1]

    tit_end = findnext("\n", txt, tit_start)[1]
    title = strip(txt[tit_start:tit_end])
    # @show tit_start, title, tit_end

    #println("=========  ",title)
    title = change_title(title, ency)
    println("=========  ", title)
    #occursin("Aryan", title) && break

    ref_start = findnext("RR ", txt, tit_end)[end]
    ref_end = findnext("++", txt, ref_start)[1]

    refs = split(txt[ref_start:ref_end], "RR ")
    refs = replace.(refs, "\n" => "")
    refs = filter(!=(""), refs)
    refs = filter(!=(" "), refs)

    for refwBlanks in refs #loop over references of the current title
        ref = strip(refwBlanks)
        if ref == ""
            @show title, refs
            global breaker = true
        end
        # if startswith(ref, "Waco breaker") 
        #     println(">>>>>>>>>>>> ",title)
        #     global breaker = true
        # end
        if startswith(ref, '"')
            ref = replace(ref, "\"" => "")
        end


        datematch = match(r"[^\[](\d{4})", ref) # 4 digit numbers, but not if thery are of the form [1234]

        # a word, a comma a space, a word, a possible '.', space, a third possible word 
        single_name = r"^(\w+),\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        single_backup = r"^(\w+)"
        second_name = r"(\w+)\s(\w+)+[.,]{0,2}\s(\w+)?[.,]{0,2}?"
        etal = r"^(\w+),\s(\w+)+,\set\sal[.,]\s(\d{4})"

        #@show title
        println()#@show ref
        found_single = false

        fname = match(single_name, ref)
        if isnothing(fname)
            println("single name fname is nothing.")
            fname = match(single_backup, ref)
            println("trying backup for ref:", ref)
        end
        #if this is still empty, then there are no references
        if isnothing(fname)
            biblio[title] = []
            continue
        end

        date = noDate
        if !isnothing(datematch)
            date = datematch.captures[1]
            #@show datematch.offsets
        end

        # # is this enough?
        # we might have a date as the last part of the name
        if length(fname.captures) == 3
            if !isnothing(datematch)

                if fname.captures[3] == date
                    # ok get the name and date and get out 
                end
            end
        end


        found_etal = false
        if occursin(etal, ref)
            #@show ref
            found_etal = true
            #readline()
        end


        ref, splitref, shortref = get_shortref(ref, date)

        # if startswith(ref,"Martin, Alb")
        #     breaker = true
        # end

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
            #@show fname
            #@show date, shortref
            if !isnothing(datematch)
                @show max(fname.offsets...), max(datematch.offsets...)
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
                            sname = match(second_name, ref, andmatch.offsets[1] + length("and"))
                            @show sname
                            if !isnothing(sname)
                                # find the last non-nothing entry, which must also starts w/ a capital letter name
                                my_cond = x -> isnothing(x) || isnothing(match(r"^[A-Z]", x))
                                last_non_nothing = findlast(!my_cond, sname.captures)
                                #last_non_nothing = findlast( !isnothing, sname.captures)
                                capts = sname.captures[1:last_non_nothing]
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
        if isnothing(matchdate_atend) && shortref[end] != noDate
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
        println("---> ", shortref)

        push!(bibitem_string, shortref)
        if ref ∉ keys(fullref2short)
            fullref2short[ref] = [shortref]
        else
            @pipe shortref |> push!(fullref2short[ref], _)
        end

        if shortref ∉ keys(shortref2full)
            shortref2full[shortref] = [ref]
        else
            @pipe ref |> push!(shortref2full[shortref], _)
        end

        if title ∉ keys(biblio)
            biblio[title] = [shortref]
        else
            @pipe shortref |> push!(biblio[title], _)
        end
        datematch = nothing
        date = nothing
        @show shortref

    end
    #biblio[title] = bibitem_string
    if breaker #
        break
    end

    start_search = ref_end

end

############################################3

# begin # 172
#     biblio = Dict()
#     fullref2short = Dict()
#     shortref2full = Dict()

#     title = nothing

#     global start_search =1; 
#     n = 1;
#     global noDate = "No_Date"
# end
#######################################
#
# sanity
j = 0
for (k, i) in biblio
    if startswith(k, "M")
        @show k
    end
    global j += 1
    if !occursin(k, ency)
        printl("Not: ", k)
        break
    end
end


println("biblio length = ", j, " ", length(biblio))

# whcih entries did not make it iinto biblio?
newtitles = @pipe replace(ency, "\n" => "   ") |> split(_, "   ")

lines = []
for (i, lin) in enumerate(newtitles)
    println(i, "  ", lin)
    if !haskey(biblio, lin)
        push!(lines, lin)
    end
end
lines


for (k, i) in biblio
    for ii in i

        # if occursin("SPLC",ii) || occursin("Reefer",ii)
        #      println("--> ",k, " - ",ii)
        # end
        if occursin(r".*(\(\d{4}\)).*(\(\d{1}\))", ii)
            println(k, " - () - ", ii)
        elseif occursin(r".*(\(no_date\)).*(\(\d{1}\))", lowercase(ii))
            println("no date -", k, " - ", ii)
        elseif occursin(r".*\(.*(.*\(\d{4}\))", ii)
            println("### -", k, " - ", ii)
        end
    end
end




using JSON

open("biblio.json", "w") do f
    JSON.print(f, biblio)
end
open("shortref2full.json", "w") do f
    JSON.print(f, shortref2full)
end
open("fullref2short.json", "w") do f
    JSON.print(f, fullref2short)
end

@show



@show

# for (i,line) in enumerate( eachline(knightfile) )

#     if startswith(line, "## ")

#         global entry = replace(line, "## "=> "" ,"." => "")
#         biblio[entry] = String[]
#         @show entry
#     elseif startswith(line, "RR ")

#     end
#     rstart = startswith(line, "RR ")
#     rend = endswith(line,"++")

#     if rstart
#         bibitem_string = line
#     else if rend
#         bibitem_string_final = bibitem_string * line
#         bibitem = "" 


#         # we reached a line with a bib item. 
#         bibitem = find_numeral_in_entry_line(line)
#         if length( bibitem ) != 1
#             @show length( bibitem),  line
#         end
#         push!( biblio[entry],  )
#     end
#     if rend
#         println("--> ", line)
#     end
# end

# begin 
#     gramdict = ngrams(ngram)
#     gramdict["See also"]
#     update_lexicon!(crp)
#    sortedgrams = sort(collect(gramdict), by=x->x[2], rev=true)
# end

begin
    contents_start = findfirst("Contents", txt)[end]
    contents_start = findnext("Abolition", txt, contents_start)[1]

    contents_end = findnext("ZOG", txt, contents_start)[end]
    contents_end = findnext("\n", txt, contents_end)[end]

    Contents = txt[contents_start:contents_end]
    Contents = split(Contents, '\n')
    Contents = [i for i in Contents if (split(i) |> length) > 1]
end


begin
    content_dict = OrderedDict()
    leaveout_fromcontents = ["Primary Source Documents", "Index", "About the Editor"]
    duplicate_pages = Dict()
end

for c in Contents
    #@show c
    if (occursin.(leaveout_fromcontents, c) |> sum) > 0
        @show c
        continue
    end
    csplit = split(c)
    if length(csplit) > 1
        num = tryparse(Int, csplit[end])
        if !isnothing(num)
            l = length(csplit[end])
            key = strip(c[1:end-l])
            content_dict[key] = num
            # dict_content[num] = c[1:end-l]
            if haskey(duplicate_pages, num)
                println("Duplicate page $num")
                duplicate_pages[num] += 1
            else
                duplicate_pages[num] = 1
            end
        end
    end
end


for (key, val) in duplicate_pages
    if val > 1
        println("Page $(key) has $(val) entries ")
        duplicate_pages[key] = sort(findall(x -> x == key, content_dict))
    else
        delete!(duplicate_pages, key)
    end
end




#
#Letsmove to items themselves
begin
    outf = FileDocument(datadir("ConspiracyKnight_byhand_itemsOnly.txt"))
    outf = StringDocument(text(outf))
    txt = text(outf)
    txt = make_replacements(txt)

end
pagecount = findall("\f", txt)
pages = Dict()

# We dont need the introductury  pages in latin numerals.
# page #1 is page 27 (I counted)...
first_page = 27
# plus only odd pages do have the page no, even pages display the page not on the left, 
# ie in the first column -> not at the page break 
# pages is a dict  page_no => txt[start:end], ie 719 => 2862369:2866496 etc
previous_page = 1
for (i, pag) in enumerate(pagecount[begin:end]) #begin+3] )#end-1] ) # leave last page out
    # use nextind becaus of possible unicode characthers 
    # is check that sizeof("a") ==1, sizeof("∀") == 3 etc
    ind1 = nextind(txt, pag[1][1] - 6)
    #@show nextind(txt,pag[1][1]-6)
    ind2 = nextind(txt, pag[1][end])

    pages[i+first_page-1] = previous_page:ind2
    @show i, ind1, ind2, ind1 - ind2
    global previous_page = ind2
end


using DataFrames

df = DataFrame()
df[!, :Index] = [[:page, :status]; [Symbol(k) for (k, v) in content_dict]]
for (k, v) in content_dict
    df[!, Symbol(k)] .= 0
    df[1, Symbol(k)] = v
end

#Count by hand entries in contents
count_pages = zip([Char(i) for i in 97:122], [23, 28, 29, 10, 3, 11, 6, 16, 9, 8, 8, 13, 25, 11, 9, 16, 1, 14, 28, 8, 5, 2, 10, 2, 4, 3])# |> zip )# |> Dict 
count_pages = Dict(count_pages)
num_of_entries = sum([i[2] for i in count_pages])

#sanity 
length(content_dict)
@assert length(content_dict) == num_of_entries

#we know there are at most maxt words in the title of the longest title (maxtitle)
#seealso = findnext("See also",txt, contents_end)
# seealso = findall("See also", txt) #[contents_end:end])
seealso = "See also"
refs = "References\n"


# The first entry is calculated here
begin
    prevtit, prevpag = "Abolitionism", 27
    prevmytit = prevtit * "\n"
    prev_article_title = find_title(prevmytit, txt, pages[prevpag])
    findnext_seealso = findnext(seealso, txt, prev_article_title[end])
end

@show txt[prev_article_title]
#delete!(content_dict, "Abolitionism")
#######################################
######################################3
#= begin
    indexno = 2
    (tit, pag) = ("Abortion", 33)
    # add a line feed 
    mytit = tit*"\n"

    if prevpag > pag 
        println("There is a problem: $tit @p. $pag is supposed to be BEFORE $(prevtit) @p. $prevpag")
    end
    # 
    # find title page indepentently as a sanity check    
    @show indexno, mytit, pag
    article_title = find_title(mytit, txt, pages[pag])
    if isnothing(article_title)
        println("Could not find title $mytit.")
    end
    if txt[article_title] != tit
        println("Somethings amiss for title $tit around $article_title \n 
        txt[article_title] is $(txt[article_title]). ")
    end

    # find the relevant 'see also'
    findnext_next_seealso = findnext(seealso, txt, article_title[end])
    # check if this see also is *after* the next title, ie the current item does not have a see also
    #next_article_title = find_title(nexttit, txt, pages[nextpage])

    @show article_title prev_article_title
    println("1 --- $prevtit, $prevpag, $tit, $pag, $findnext_seealso, $findnext_next_seealso")
    nextseealsopage = find_page(findnext_seealso[1], pages)
    println("2 --- page= $(nextseealsopage),  prev title =$prev_article_title,  page=$(find_page(prev_article_title[1], pages)) ")
end
 =#

######################################
######################################33
# The first entry is calculated here
begin
    prevtit, prevpag = "Abolitionism", 27
    prevmytit = prevtit * "\n"
    prev_article_title = find_title(prevmytit, txt, pages[prevpag])
    findnext_seealso = findnext(seealso, txt, prev_article_title[end])
    findnext_refs = findnext(refs, txt, prev_article_title[end])
end

@show txt[prev_article_title]

salsos_counter = 0

for (indexno, (tit, pag)) in enumerate(content_dict)
    # leave the fist entty - ablisionism - out
    if indexno == 1 #|| indexno > 10
        continue
    end

    # add a line feed 
    mytit = tit * "\n"

    if prevpag > pag
        println("There is a problem: $tit @p. $pag is supposed to be BEFORE $(prevtit) @p. $prevpag")
        break
    end
    @show tit

    # 
    # find title page indepentently as a sanity check    
    @show indexno, mytit, pag
    article_title = find_title(mytit, txt, pages[pag])
    if isnothing(article_title)
        println("Could not find title $mytit.")

    end
    #@show tit
    #end
    # sanity
    if txt[article_title] != tit
        println("Somethings amiss for title $tit around $article_title \n 
        txt[article_title] is $(txt[article_title]). ")
        break
    end

    # find the relevant 'see also'
    findnext_next_seealso = findnext(seealso, txt, article_title[end])
    findnext_next_refs = findnext(refs, txt, article_title[end])
    # check if this see also is *after* the next title, ie the current item does not have a see also
    #next_article_title = find_title(nexttit, txt, pages[nextpage])

    #@show article_title prev_article_title

    println("1 --- prevtit = $prevtit, $prevpag, this tit $tit, $pag, 
    findnext_next_seealso $findnext_seealso = $(txt[findnext_seealso]),page= $(find_page(findnext_seealso[1], pages)), 
    findnextnext_seealso $findnext_next_seealso $(txt[findnext_next_seealso]), page= $(find_page(findnext_next_seealso[1], pages)), 
    next refs = $(findnext_next_refs)")
    ptit = txt[prev_article_title]
    println("2 ---  prev title =$ptit, page=$(find_page(prev_article_title[1], pages)) ")

    #=
    1   see also 
        references
    2   ----
        references
    3   see also 
        --------
    4   -
        -
    =#

    salsos = nothing
    bibrefs = nothing
    # see also in a must be before tit.
    if findnext_seealso[end] > findnext_next_seealso[1]
        println("$mytit : No 'see also' found. Skip.")
        # Check if we have references
        if findnext_refs[end] > findnext_next_refs[1]
            println("$mytit: No Refereces  found. Skip.")
            # else    
            #     println("looking for references")
            #     bibrefs = 0 #get_refs_no_salso()
        end
    else # we have see alsos
        global salsos_counter += 1
        salsos = get_refs(findnext_seealso, article_title, txt)
        if !isnothing(salsos) && max(length.(salsos)...) > 50
            println("salsos lengths: $(length.(salsos)). Break")
            break
        end
        # if (occursin.("40",salsos) |> sum ) > 0 
        #     break
        # end
    end
    # add this to ZOG, the last item :
    #See also: Militias; One-World Government, Posse Comitatus; Ruby Ridge; Pierce, William L.
    salsos = nothing
    if article_title == "ZOG"
        salsos = ["Militias", "One-World Government", "Posse Comitatus", "Ruby Ridge", "Pierce, William L."]
    end

    if !isnothing(salsos)
        load_df(df, salsos)
    end


    global findnext_seealso = findnext_next_seealso
    global findnext_refs = findnext_next_refs
    global prev_article_title = article_title
    global prevtit = tit
    global prevmytit = mytit
    global prevpag = pag

    #  if tit == "Bilderbergers"
    #      break
    #  end
end


# import XLSX
# # convert to string
# XLSX.writetable("df.xlsx", collect(DataFrames.eachcol(df)), DataFrames.names(df))