
#!/prt1/PMO/liaoqp/software/python/python3/bin/python3
# -*- coding: utf-8 -*-
'''
author: liaoqp
'''
import sys, os, argparse, os.path, re
import operator, math, datetime, time
from multiprocessing.dummy import Pool as ThreadPool

parser = argparse.ArgumentParser(description='This script is used to mutil_threads.\n\n\
Example: python3 mutil_threads.py -c example_work.sh\n\
         python3 mutil_threads.py -c example_work.sh -m 4',formatter_class=argparse.RawTextHelpFormatter)

parser.add_argument('-c','--cmds',dest='cmds',required=True,help='Please input shell file')
parser.add_argument('-m','--mutil',dest='mutil',type=int,default=3,required=False,help='mutil_threads,default is 3')

args = parser.parse_args()
Bin = os.path.split(os.path.realpath(__file__))[0]
args.cmds = os.path.abspath(args.cmds)

def run_or_die(cmd):
	flag = os.system(cmd)
	if flag != 0:
		print('Error: command fail: '+cmd)
		exit(1)


if __name__ == '__main__':
	cmdss = []
	cmd_f = open(args.cmds,'r')
	for i in cmd_f:
		i = i.strip()
		cmdss.append(i)
	cmd_f.close

	# Make the Pool of workers
	pool = ThreadPool(args.mutil)#任务投递数
	# Open the urls in their own threads
	# and return the results
	results = pool.map(run_or_die,cmdss)
	#close the pool and wait for the work to finish
	pool.close()
	pool.join()
