#python3
import sys


def overlap_graph(patterns):
    """Creates an overlap graph from a list of k-mers

    Args:
        patterns:       a list of string k-mers

    Returns:
        a string containing an adjacency list representation of the overlap
        graph as described in the problem specification
    """
    # TODO: your code here
    patterns=list(set(patterns))
    return_list=[]
    for i in range(0,len(patterns)):
        node=patterns[i]
       # print(node)
        return_string=node+"->"
        if len(node)>2:
            for k in range(0,len(patterns)):
             #   print(k,"burrow")
                for p in range(1,len(node)):
                    if patterns[k]!=node:
                        if node[len(node)-1-p:]==patterns[k][:p+1]:

                            return_string=return_string+patterns[k]+","
            if len(list(set(node)))==1:
                return_string=node+"->"+node+','
        else:
            for k in range(0,len(patterns)):
                if patterns[k]!=node:
                    if node[len(node)-1]== patterns[k][0]:
                        return_string=return_string+patterns[k]+","
                if len(list(set(node)))==1 :
                    return_string=return_string+node+","


            
        if return_string[-1]!=">":
            return_list.append(return_string[:-1])
#        for j in range(1,len(node)):
 #           code=node[len(node)-j:]
  #          for k in range(0,len(patterns)):
   #             if patterns[k]!=node:s
    #                if code==patterns[k][j:]
    for i,lists in enumerate(return_list,0):
        place=return_list[i].index('->')
        if ',' in return_list[i] and place>4:
            edge=return_list[i][0:place]
            for d,lister in enumerate(return_list,0):
                if edge in return_list[d][4:]:
                    remover=return_list[d][:return_list[d].index('->')]
                    return_list.remove(return_list[d])
                    d,i=0,0
                    for g in range(0,len(return_list)):
                        if remover in return_list[g] and ',' in return_list[g]:
                            return_list[g]=return_list[g].replace(remover,'')
                            return_list[g]=return_list[g].replace(',,',',')

                            
     
    for a in return_list:
       if a[-1]==',':
          a=a[:-1]
       print(a)
            
    return ""


if __name__ == "__main__":
    patterns = sys.stdin.read().strip().splitlines()
    print(overlap_graph(patterns))
