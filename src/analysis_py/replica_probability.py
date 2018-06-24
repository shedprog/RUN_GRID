import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import fsolve
from scipy.optimize import curve_fit
from scipy.special import erf
import numpy as np
import math, sys, os, re
import ROOT

def function(x, a, b, c):
	'''This function is exponent 
	for fitting procedure'''
	return a * exp((x-b)*c)

def read_to_array(file):
	'''This function for montecarlo replicas reading
	and putting it into an array'''
	global CIvarval
	f = open(file,'r')
	eta = []
	eta_true = []
	for line in f:
		try:
			a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',line)
			if len(a)>=6:
				# print a
				eta_true.append(float(a[2]))
				eta.append(float(a[3]))

		except:
			pass
	f.close() 
	return eta_true,eta

if __name__ == "__main__":

	WORKDIR=sys.argv[1]         # PATH/TO/OUTPUT
	CIvarval=[]
	files = sorted([f for f in os.listdir('%s/output/simpfit' % WORKDIR) if re.match(r'.*RESULTS_CI.*', f)])
	for file in files:
		file_CI = open('%s/output/simpfit/%s' % (WORKDIR,file))
		a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',file_CI.readline())
		# print a
		print file, float(a[2])
		file_CI.close()
		CIvarval.append(float(a[2]))
		file_CI.close()


	probability=[]
	eta_true=[]
	error=[]

	files = sorted([f for f in os.listdir('%s/output/monte_carlo' % WORKDIR) if re.match(r'.*RES.*', f)])
	print files

	n=0
	for file in files:
		# try:
		eta_true_arr,eta = read_to_array('%s/output/monte_carlo/%s' % (WORKDIR, file))
		eta_true_one = eta_true_arr[3]
		if CIvarval[n]>=0.0:
			p_temp = sum(i > CIvarval[n] for i in eta)/float(len(eta))
			probability.append(p_temp)
			error.append(sqrt((1-p_temp)*p_temp/len(eta)))
			eta_true.append(eta_true_one)
		elif CIvarval[n]<=0.0:
			p_temp = sum(i < CIvarval[n] for i in eta)/float(len(eta))
			probability.append(p_temp)
			error.append(sqrt((1-p_temp)*p_temp/len(eta)))
			eta_true.append(eta_true_one)
		print file[8:13], round(p_temp*100,2),'% ', CIvarval[n],'GeV ', len(eta), 'Replicas'
		n=n+1
		# except:
		# 	print 'ERROR: File "%s" cannot be calculated' %file
