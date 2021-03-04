from collections import defaultdict
import graphlib

def try_stock(new,old):
	return_list=[]
	# Driver Code 
	graph = defaultdict(list)
	for i in range(len(old)):
		graph[old[i]].append(new[i])
	ts = graphlib.TopologicalSorter(graph)
	out_list=list(ts.static_order())[::-1]
	for stock in out_list:
		if len(graph[stock])!=0:
			return_list.append([graph[stock][0],stock])
	return return_list
print("Following is a Topological Sort of the given graph")
  
# Function Call 

print(try_stock(['a','b','c','e','f','h','g'],['b','e','d','g','r','i','t']))



