import logging
import os
from queue import Queue
from threading import Thread
from time import time
import sys, threading, time, os, sys
from queue import Queue
import queue
import concurrent.futures 
import json
import time
from multiprocessing import Process, Value, Array


with open('data_1.json') as f:
	data = json.load(f)
start=0
first_edges = queue.Queue()
print(data)
filled_edges=[]
comp=[]
exit_event = threading.Event()

for edges in data:
	try:
		start=data[edges]['start']
		for edge in list(data[edges]['edges'].items()):
			first_edges.put(edge)
	except Exception as e:
		if start:
			break
		else:
			print('not found yet')
def get_edges(edge,start_time_first):
	start_time = time.time()


	time.sleep(edge[1])


	here_time=time.time()
	print(edge[0],here_time-start_time,here_time-start_time_first)

	return edge
class DownloadWorker(Thread):

    def __init__(self,edge,time):
        Thread.__init__(self)
        self.queue = queue.Queue()
        self.queue.put(edge)
        self.time=time
    def run(self):
        while not self.queue.empty():
            # Get the work from the queue and expand the tuple
            if self.queue.empty():
                break
            edge = self.queue.get()

            realive=get_edges(edge,self.time)

            new_items=list(data[realive[0]]['edges'].items())

            if new_items:
               self.queue.put(new_items[0])
               del new_items[0]
 #           list(map(self.queue.put,list(data[realive[0]]['edges'].items())))
               list(map(first_edges.put,new_items))

     #   self.queue.join()


        check_comp()

      #  Thread.join(self)
        return realive
     
def start_thread(edge,start_time):
      worker = DownloadWorker(edge,start_time)
     
      #worker.daemon = True
      worker.start()
      return worker
def check_comp():
      for t in comp:
        if not t.is_alive():
             comp.remove(t)

        
def main():


    # Create a queue to communicate with the worker threads
    queue = first_edges
    # Create 8 worker threads
    start_time=time.time()


    while first_edges.qsize()>0 or len(comp)>1:

        if not first_edges.empty():
           edge=first_edges.get()
           worker=start_thread(edge,start_time)
           comp.append(worker)

           for t in comp:
             if not t.is_alive():
                 comp.remove(t)

   # print("donerrrrrrrrrrrrrrrrrrrrrrrrrrrrrr")


    # Causes the main thread to wait for the queue to finish processing all the tasks


if __name__ == '__main__':
    main()
