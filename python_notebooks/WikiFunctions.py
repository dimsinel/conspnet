"""Some helper functions for wikipedia notebooks"""
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
    """Get entry by node name in tree"""
    flist = [ob for ob in objlist if nodeName.lower() in ob.nodeName.lower() ]
     
    if len(flist) == 1:
        return flist[0]
    elif len(flist) > 1:
        print('Multiple entries found')
        for i in flist:
            i.print()
    else: 
        print("Nothing found")

    return wikiItem(None)   


def findByWikiName(wikiName, objlist):
    """Get entry by wikipedia  name"""
    flist = [ob for ob in objlist if wikiName.lower() in ob.wikiName.lower() ]
  
    if len(flist) == 1:
        return flist[0]
    elif len(flist) > 1:
        print('Multiple entries found')
        for i in flist:
            i.print()
    else: 
        print("Nothing found")

    return wikiItem(None)      
    
    
def printCommentsOnly(objlist):
    """Get all comments in list of entries"""
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
