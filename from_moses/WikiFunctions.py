def revco(s):
    s = s.strip()
    if 'alcolm' in s:
        return s
    if "," in s:
        sl=s.split(", ")
        if len(sl) > 2:
            return s
        s=sl[1]+" "+sl[0]
        
    return s

def findByNodeName(nodeName, objlist):
    for ob in objlist:
        if ob.nodeName == nodeName:
            return ob
    # if not found, check if this is only a part of the name
    flist = []
    for ob in objlist:
        if nodeName.lower() in ob.nodeName.lower() :
            flist.append(ob)    
    # if not found, return an empty-name oblject
    if len(flist) > 0:
        print('Multiple entries found')
        for i in flist:
            i.print()

    return wikiItem(None)


def findByWikiName(wikiName, objlist):
    for ob in objlist:
        if ob.wikiName.strip() == wikiName:
            return ob
    # if not found, check if this is only a part of the name
    flist = []
    for ob in objlist:
        if wikiName.lower() in ob.wikiName.lower() :
            flist.append(ob)    
    #if nothing found,  return an empty-name oblject
    if len(flist) > 0:
        print('Multiple entries found')
        for i in flist:
            i.print()

    return wikiItem(None)      
    
    
def printCommentsOnly():
    for ob in objlist:
        if ob.comment != None:
            ob.print()
            print()
########################################################################        
class wikiItem:
       
    def __init__(self, dictname=None, wikiname=None):
        self.nodeName = dictname
        self.wikiName = wikiname
        self.wikiSummary =None
        self.comment = None
        self.tag = None
        self.tag2 = None
        
    def print(self):
        print(f'node name: {self.nodeName}')
        print(f'wiki name: {self.wikiName}')
        print(f'tag1:      {self.tag} ') 
        if self.tag2 != None:
            print(f'tag2:      {self.tag2} ') 
        if self.comment != None:
            print(f'comment:   {self.comment}')
           
########################################################################        
