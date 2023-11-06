def revco(s):
    s = s.strip()
    
    if "," in s:
        sl=s.split(", ")
        s=sl[1]+" "+sl[0]
        
    return s

def findByNodeName(nodeName, objlist):
    for ob in objlist:
        if ob.nodeName == nodeName:
            return ob
    # if not found, return an empty-name oblject
    return wikiItem("")

def findByWikiName(wikiName, objlist):
    for ob in objlist:
        if ob.wikiName.strip() == wikiName:
            return ob
    # if not found, return an empty-name oblject
    return wikiItem("")      
    

########################################################################        
class wikiItem:
       
    def __init__(self, dictname=None, wikiname=None):
        self.nodeName = dictname
        self.wikiName = wikiname
        self.wikiSummary =None
        self.comment = None
        self.tag = None
        
    def print(self):
        print(f'node name {self.nodeName}, wiki name {self.wikiName}')
        
########################################################################        
