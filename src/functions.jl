using PDFIO
import DataFrames

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
            mysym = replace(mysym, "\n"=>"")
        end
        mysym = change_symbols(mysym)
        if change_linefeed
            mysym = mysym*"\n"
        end
        println("changed $sym, $mysym")
    end
    
    title = findnext(mysym, txt, in_page[1])
    println("$title   ", in_page[1])
    # check if this is the first word in the page: in this case it is a headr, ignore it
    if title[1] == in_page[1] # this is the header
        title = findnext(mysym, txt, title[end])
    end

    # check that this is in the correct page!
    if title[end] > in_page[end]
        
        #in_page = (in_page[1]+1):in_page[end]
        title = findnext(mysym, txt, in_page[1]+1)
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
        mysym = "Hoover, J Edgar"

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

    elseif sym == "Burroughs, William S"
        mysym = "Burroughs, William S."

    elseif sym == "Central Ingelligence Agency"
        mysym = "Central Intelligence Agency"

    elseif sym == "CIA"
        mysym = "Central Intelligence Agency"

     elseif sym == "Venona Project"
         mysym = "Venona"

     elseif sym == "Roosevelt, Franklin Delano"
         mysym = "Roosevelt, Franklin D."
      
     elseif sym == "Roosevelt, Franklin D"
         mysym = "Roosevelt, Franklin D."

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
        mysym =  "Pierce, William L."

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

    txt = replace(txt,"Warren Commission" => "Warren Commission Report")

    txt = replace(txt,"Hoover, Edgar J" => "Hoover, J Edgar")

    txt = replace(txt,"mk-ultra" => "MK-ULTRA")

    txt = replace(txt, "Johnson, Lyndon B" => "Johnson, Lyndon Baines")

    txt = replace(txt, "Smith, Gerald L K" => "Smith, Gerald L. K.")

    txt = replace(txt, "The Manchurian Candidate" => "Manchurian Candidate")

    txt = replace(txt, "King, Martin Luther, Jr, Assassination of" => "King, Martin Luther, Jr., Assassination of")

    txt = replace(txt, "Ruby Ridge Incident" => "Ruby Ridge")

    txt = replace(txt, "Burroughs, William S" => "Burroughs, William S.")

    txt = replace(txt, "Central Ingelligence Agency" => "Central Intelligence Agency")

    txt = replace(txt, "CIA" => "Central Intelligence Agency")

     txt = replace(txt, "Venona Project" => "Venona")

     txt = replace(txt, "Roosevelt, Franklin Delano" => "Roosevelt, Franklin D.")
      
     txt = replace(txt, "Roosevelt, Franklin D" => "Roosevelt, Franklin D.")

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

    txt = replace(txt,"Hollywood 10"=>"Hollywood Ten")
    txt = replace(txt,"Hoover, J."=>"Hoover, J")
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
    end
    
    salsos = txt[(a[end]+2):(ref[1] -1)]
    #println("salsos _______ $salsos")
    # check if there is a page break here -- it should also contain a page number
    if occursin("\f", salsos)   
        #@show salsos
        # the first word after the page break is a header
        salsos = split(salsos,"\f")
        # page braks are of the form "\n\n57\n\n\f"
        salsos[1] = replace(salsos[1],r"\W{1,}\d{1,}?\W{1,}"=>" " )
        splitsalsos = split(salsos[2],";")[2:end]
        #@show salsos[1], splitsalsos, length(splitsalsos)
        #if length(splitsalsos) != 0\
       salsos = length(splitsalsos) > 0 ?  salsos[1]*splitsalsos[1] : salsos[1] 
    end
    
    salsos = replace(salsos, "." => "")
    salsos = replace(salsos, "\n" => " ")
    salsos = split(salsos,";") .|> strip
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

