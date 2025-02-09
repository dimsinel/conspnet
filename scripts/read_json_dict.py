import json


with open('bibdict_for_Snow_etal.json') as json_file:
    dicttxt = json.load(json_file)
    
    
bibdict = json.loads(dicttxt)

# "Abeyance" is the first item in Snow et al.
# bibdict["Abeyance"][0] is the 'SWEE_ALSO items in Abeyance
print(bibdict["Abeyance"][0])
# and bibdict["Abeyance"][1] is the list of references in Abeyance
print(bibdict["Abeyance"][1])



