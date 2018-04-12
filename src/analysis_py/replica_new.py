import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import fsolve
from scipy.optimize import curve_fit
from scipy.special import erf
import numpy as np
import math, sys, os, re

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
			if sys.argv[1] == 'right':
				if float(a[2])>CIvarval:
					eta_true.append(float(a[2]))
					eta.append(float(a[3]))
			if sys.argv[1] == 'left':
				if float(a[2])<CIvarval:
					eta_true.append(float(a[2]))
					eta.append(float(a[3]))
		except:
			pass
	f.close() 
	return eta_true,eta

if __name__ == "__main__":

	"""This part checks if arguments are right"""
	try:
		if (sys.argv[1] != 'right') and (sys.argv[1] != 'left'):
			print "Please, put 'right' or 'left' as an argument",
			sys.exit()
	except IndexError:
		print "Please, put 'right' or 'left' as an argument"
		sys.exit()

	CL_SIDE=sys.argv[1]
	WORKDIR=sys.argv[2]

	"""
	This part CIvarval, from:
	./simpfit/RESULTS_SM.txt 
	"""
	file_CI = open('%s/output/simpfit/RESULTS_CI.txt' % WORKDIR)
	a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',file_CI.readline())
	# CIvarval = float(a[2]) 
	file_CI.close()

	CIvarval=0.0

	'''This part initiate variables'''
	probability=[]
	eta_true=[]
	error=[]

	files = sorted([f for f in os.listdir('%s/output/monte_carlo' % WORKDIR) if re.match(r'.*RES.*', f)])
	print files

	for file in files:
		try:
			eta_true_arr,eta = read_to_array('%s/output/monte_carlo/%s' % (WORKDIR, file))
			eta_true.append(eta_true_arr[0])
			error.append(sqrt(0.95*0.05/len(eta)))
			if sys.argv[1] == 'right':
				probability.append(sum(i < CIvarval for i in eta)/float(len(eta)))
			elif sys.argv[1] == 'left':
				probability.append(sum(i > CIvarval for i in eta)/float(len(eta)))
		except:
			print 'ERROR: File "%s" cannot be calculated' %file


	# Exponential fit
	best_vals = [0.05, -0.07e-7, -22e4] 
	best_vals, covar = curve_fit(function, eta_true,
		probability, p0=best_vals)
	x = linspace(min(eta_true),max(eta_true),300)
	y = function(x, best_vals[0],best_vals[1],best_vals[2])

	# Exponent values
	CL_prob=0.05
	func = lambda x : function(x,best_vals[0], best_vals[1],
		best_vals[2])-CL_prob
	print "5% :", fsolve(func, 9.5e-8)
	print "\Lambda- :", math.sqrt(4*math.pi/abs(fsolve(func, 9.5e-8)))
	print "CIvarval:", CIvarval


	#Plot exponent for x,y and results woth error
	fig, ax = plt.subplots()
	plt.plot(x,y)
	ax.errorbar(eta_true, probability,
		yerr=error,linestyle='',marker='o',
		markerfacecolor='k', markersize=5,elinewidth=2)
	plt.xlabel(r'$\eta_{True} [GeV]$')
	plt.ylabel(r'$Prob(\eta^{Fit}<\eta^{Dara})(\%)$')
	plt.title('AA model')
	plt.text(60, .025, r'$\mu=100,\ \sigma=15$')
	plt.grid(True)
	plt.show()