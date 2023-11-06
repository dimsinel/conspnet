from pyzotero import zotero
zot = zotero.Zotero('11080161', 'user','NtXorJanzgDmXMJ6uSbpvA2J')
# Start at the begining, take at most 
limit = 20
start = 1
zot.add_parameters(limit=limit, start=start)
#a = zot.top(limit=limit, start=start, q="garr")
zot.count_items()

References = dict()
References["Bryan, William Jennings"] = []
References["Bureau of Alcohol, Tobacco, and Firearms"] = []
References["Burr, Aaron"] = []
References["Burroughs, William S."] = []
References["Bush, George"] = []

References["Cambodia, Secret Bombing of"] = []
References["Castro, Fidel"] = []
References["Cattle Mutilations"] = []

References["CIA"] = []
References["Chambers, Whittaker"] = []
References["Chappaquiddick"] = []
References["Chicago 7"] = []
References["Christian Identity"] = []
References["Christian Science"] = []
References["Church of the SubGenius"] = []
References["Civil Rights Movement"] = []
References["Clan of the Mystic Confederacy"] = []

a = zot.top(q="Burroughs")
len(a[0])
#zot.add_parameters(format=“bibtex”)


def getTaggedBib(tag):
    b = zot.items(tag=tag) 
    for i in b:
        isbn = 'n/a'
        doi = 'n/a' 
        if 'ISBN' in i['data'] and i['data']['ISBN'] != '':
            isbn = i['data']['ISBN']
        if 'DOI' in i['data'] and i['data']['DOI'] != '': 
            doi = i['data']['DOI']
        print(f"{i['data']['title']}, isbn: {isbn}, DOI: {doi}") 

tag =  "Bush, George"
getTaggedBib(tag)      
    
for kk in References.keys():
    print('\n---- >  ', kk)
    getTaggedBib(kk) 




import os,re


def getDate(entry, date):
    for ent in entry:
        dd = ent['data']['date']
        if dd.isdigit():
            dd=int(dd)
        else:
            dd = max(ent['data']['date'].split('-'))
            if dd.isdigit():
                dd=int(dd)
        
        if int(dd) == date: 
            return ent
        
    return False 
        
    #print('from getDate:',ent["data"]["title"], dd, date)
        
def getRefFromLine(line):
    ll = line.split()
    name = ll[0].strip(',')
    lst = [int(x.strip('.')) for x in ll if x.strip('.').isdigit()]
    ent = zot.top(q=name)
    if len(ent) > 1 and len(lst) == 1: 
        ent = getDate(entry, lst[0])
    return ent
    


cwd = os.getcwd()
with open(os.path.join(os.getcwd(),'refstemp.txt'),'r') as myfile:
    firstLine = True
    for line in myfile:
        #print(line) 
        if firstLine:
            print('--->', line)
            entry = getRefFromLine(line)
            #print(name) #, lst[0])
            if not entry :
                print('Could not find a reference w/ the correct date!')
                firstLine = False
                continue
            else:
                #zz = zot.top(q=name)
                #print(f'There are {len(entry)} entries')
                print(entry[0]["data"]["title"], entry[0]["data"]["date"], entry[0]["data"]["key"])
                firstLine = False
        if not line.strip(): # in ['\n', '\r\n']:
            #print(firstLine, line.strip())
            firstLine = True
            
    #aaa=re.split('\n\s*\n', myfile)
    # for line in myfile:
        
    #     print( line)
        
        
        
        
# def findRefsAuthors(msg): 
#     txt = io.StringIO(msg)
#     firstLine = True
#     for line in txt:
#         #print(line) 
#         if firstLine:
#             print('--->', line)
#             firstLine = False
#         if line.strip(): # in ['\n', '\r\n']:
#             print(firstLine, line.strip())
#             firstLine = True
            
# findRefsAuthors(aa)         
            
# aa= 
# aaaa=re.split('\n\s*\n', aa)
# len(aaaa)
import re 
brefs=['Goldberg (2001)', 'Blacks and Jews (No_Date)', 'Lee (1996)', 'Bennett (1988)','Cose (1992)','Higham (1988)','Jones (1992)','Lee (1970)','Blacks and Jews (No_Date) (1)','Lee (1996) (1)' ]
# if occursin(r".*(\(\d{4}\)).*(\(\d{1}\))", ii)
#             println(k, " - () - ",ii)
#         elseif occursin(r".*(\(no_date\)).*(\(\d{1}\))", lowercase(ii))
#             println("no date -", k, " - ",ii)
#         elseif occursin(r".*\(.*(.*\(\d{4}\))", ii)
#             println("### -", k, " - ",ii)
for x in brefs:
    
    m1 = re.match(r".*(\(\d{4}\)).*(\(\d{1}\))", x)
    m2 = re.match(r".*(\(no_date\)).*(\(\d{1}\))", x, re.IGNORECASE)
    m3 = re.match(r".*\(.*(.*\(\d{4}\))", x)
    if type(m1) == re.Match  and len(m1.groups()) == 2: 
         print("OK      --> ",m1.groups(), x)
    else:
        if type(m2) == re.Match  and len(m2.groups()) == 2: 
            print("No date --> ", m2.groups(), x) 
        else: 
            if type(m2) == re.Match : 
                print("2 parens -->", m2.groups(), x) 

    
         
         
m = re.match(r"(\(\d{4}\)).*(\(\d{1}\))", 'Lee (1996) (1)')

