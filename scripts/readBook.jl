using DrWatson
@quickactivate "conspnet"

using TextAnalysis
# 
using DataStructures
 
include(srcdir("functions.jl"))

begin 
    outf = FileDocument(datadir("ConspiracyKnight_byhand.txt"))
    outf = StringDocument(text(outf))

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

begin 
    txt = text(outf)

    # This is ufortunate, but due to misspellings int ie book...
    txt =  make_replacements(txt)

    gramdict = ngrams(ngram)
    gramdict["See also"]

    update_lexicon!(crp)
end

begin
    sortedgrams = sort(collect(gramdict), by=x->x[2], rev=true)

    contents_start = findfirst("Contents", txt)[end]
    contents_start = findnext("Abolition",txt, contents_start)[1]

    contents_end = findnext("ZOG",txt, contents_start)[end]
    contents_end = findnext("\n",txt, contents_end)[end]

    Contents = txt[contents_start:contents_end]
    Contents = split(Contents, '\n')
    Contents = [i for i in Contents if ( split(i)|> length ) >1]
end

begin
    content_dict = OrderedDict()
    leaveout_fromcontents = ["Primary Source Documents", "Index", "About the Editor"]
    duplicate_pages = Dict()
end

for c in Contents
    if ( occursin.(leaveout_fromcontents, c ) |> sum ) > 0
        @show c
        continue
    end 
    csplit = split(c)
    if length(csplit) > 1
        num = tryparse(Int,csplit[end])
        if !isnothing(num) 
            l = length(csplit[end]) 
            key = strip( c[1:end-l] )
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
        duplicate_pages[key] = sort( findall(x->x == key,content_dict))
    else 
        delete!(duplicate_pages, key)
    end
end
   
#duplicate_pages
pagecount = findall("\f",txt)
pages = Dict()
# page #1 is page 19 (I counted)...
# plus only odd pages do have the page no, even pages display the page no on the left, 
# ie in the first column -> not at the page break 
# pages is a dict  page_no => txt[start:end], ie 719 => 2862369:2866496 etc
previous_page = 1
for (i,pag) in enumerate( pagecount[19:end-1] ) # leave last page out
    ind1 = nextind(txt,pag[1][1]-6)
    #@show nextind(txt,pag[1][end]+10)
    # pag[1][end]
    ind2 = nextind(txt,pag[1][end])
    #@show i, ind2, txt[ind1:ind2]
    pages[i] = previous_page:ind2
    global previous_page = ind2
end 
 

using DataFrames

df = DataFrame()
df[!,:Index] = [[:page, :status]; [Symbol(k) for (k,v) in content_dict ]]
for (k,v) in content_dict 
    df[!,Symbol(k)] .= 0
    df[1,Symbol(k)] = v 
end

# we know there are at most maxt words in the title of the longest title (maxtitle)
#seealso = findnext("See also",txt, contents_end)
# seealso = findall("See also", txt) #[contents_end:end])
seealso = "See also"

# The first entry is calculated here
begin 
    prevtit, prevpag =  "Abolitionism", 27
    prevmytit = prevtit*"\n"
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
    prevtit, prevpag =  "Abolitionism", 27
    prevmytit = prevtit*"\n"
    prev_article_title = find_title(prevmytit, txt, pages[prevpag])
    findnext_seealso = findnext(seealso, txt, prev_article_title[end])
end

#@show txt[prev_article_title]
for (indexno, (tit, pag)) in enumerate(content_dict)
    # leave the fist entty - ablisionism - out
    if indexno == 1 || indexno > 3
        continue
    end
    
    # add a line feed 
    mytit = tit*"\n"
    
    if prevpag > pag 
        println("There is a problem: $tit @p. $pag is supposed to be BEFORE $(prevtit) @p. $prevpag")
        break
    end
       
    # 
    # find title page indepentently as a sanity check    
    @show indexno, mytit, pag
    article_title = find_title(mytit, txt, pages[pag])
    if isnothing(article_title)
        println("Could not find title $mytit.")
        
    end
    
    # sanity
    if txt[article_title] != tit
        println("Somethings amiss for title $tit around $article_title \n 
        txt[article_title] is $(txt[article_title]). ")
        break
    end
    
    # find the relevant 'see also'
    findnext_next_seealso = findnext(seealso, txt, article_title[end])
    # check if this see also is *after* the next title, ie the current item does not have a see also
    #next_article_title = find_title(nexttit, txt, pages[nextpage])

    #@show article_title prev_article_title
    println("1 --- prevti $prevtit, $prevpag, tit $tit, $pag, findnext_next_seealso $findnext_seealso =
    $(txt[findnext_seealso]),page= $(find_page(findnext_seealso[1], pages)), indnextnext_seealso $findnext_next_seealso $(txt[findnext_next_seealso]), page= $(find_page(findnext_next_seealso[1], pages))")
    ptit = txt[prev_article_title]
    println("2 ---  prev title =$ptit, page=$(find_page(prev_article_title[1], pages)) ")


    salsos = nothing
    # see also in a must be before tit.
    if findnext_seealso[end] > findnext_next_seealso[1]
        println("$mytit : No 'see also' found. Skip.")
    else
        salsos = get_refs(findnext_seealso, article_title,txt)
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
        salsos=["Militias", "One-World Government", "Posse Comitatus", "Ruby Ridge", "Pierce, William L."]
    end

    if !isnothing(salsos)
        load_df(df, salsos)
    end


    global findnext_seealso = findnext_next_seealso
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