import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import fsolve
from scipy.optimize import curve_fit
from scipy.special import erf
import numpy as np
import math, sys, os, re

CIvarval = 4.03674E-08

def function(x, a, b, c):
	"""This function is exponent 
	for fitting procedure"""
	return a*exp((x-b)*c)

def read_to_array(file):
	"""This function for montecarlo replicas 
	for fixed ETA_mc reading and putting 
	it into an array
	Returns: chi^2, eta_true, eta_mc (if exists), 
	IREP2 (number of replica)
	"""
	global CIvarval
	f = open(file,'r')
	chi2_mc = []
	eta_mc = []
	eta_true = []
	IREP2 = []
	for line in f:
		try:
			a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?',line)
			if len(a)==5:
				if (sys.argv[1] == 'right' and float(a[1])>CIvarval) or float(a[1])==0.0:
					chi2_mc.append(float(a[0]))
					eta_true.append(float(a[1]))
					eta_mc.append(float(a[2]))
					IREP2.append(int(a[4]))

				if (sys.argv[1] == 'left' and float(a[1])<CIvarval) or float(a[1])==0.0:
					chi2_mc.append(float(a[0]))
					eta_true.append(float(a[1]))
					eta_mc.append(float(a[2]))
					IREP2.append(int(a[4]))
			if len(a)==3:
				if (sys.argv[1] == 'right' and float(a[1])>CIvarval) or float(a[1])==0.0:
					chi2_mc.append(float(a[0]))
					eta_true.append(float(a[1]))
					IREP2.append(int(a[2]))

				if (sys.argv[1] == 'left' and float(a[1])<CIvarval) or float(a[1])==0.0:
					chi2_mc.append(float(a[0]))
					eta_true.append(float(a[1]))
					IREP2.append(int(a[2]))
		except:
			pass
	f.close()
	if len(a)==3:
		return chi2_mc, eta_true, IREP2
	if len(a)==5:
		return chi2_mc, eta_true, eta_mc, IREP2

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
	This part read chi^2 SM, from:
	./simpfit/RESULTS_SM.txt 
	"""
	file_SM = open('%s/output/simpfit/RESULTS_SM.txt' % WORKDIR)
	a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?',file_SM.readline())
	chi2_DATA_0 = float(a[0]) 
	file_SM.close()

	print "chi2_SM: ",chi2_DATA_0

	"""
	This part calculate Q_mc and get eta_mc from all files
	./monte_carlo/RESULTS_VV_1_CI.txt ...
	"""
	# Create two arrays of files in ./monte_carlo/
	files_CI = sorted([f for f in os.listdir('%s/output/monte_carloLH' % WORKDIR) if re.match(r'.*CI\.txt', f)])
	files_SM = sorted([f for f in os.listdir('%s/output/monte_carloLH' % WORKDIR) if re.match(r'.*SM\.txt', f)])
	files_DATA = sorted([f for f in os.listdir('%s/output/monte_carloLH' % WORKDIR) if re.match(r'.*DATA\.txt', f)])

	probability=[]
	eta_true=[]
	error=[]

	"""
	This part read all heaps (5000)
	replicas for Eta_mc=0
	"""
	for file_CI, file_SM, file_DATA in zip(files_CI, files_SM, files_DATA):
		try:
			# Variables for CI+SM
			chi2_CI, eta_true_CI, eta_mc_CI, IREP2_CI = read_to_array('%s/output/monte_carloLH/%s' % (WORKDIR, file_CI))
			# Variables for SM only
			chi2_SM, eta_true_SM, IREP2_SM = read_to_array('%s/output/monte_carloLH/%s' % (WORKDIR, file_SM))
			# Variable for DATA fit at eta_true
			DATA = open('%s/output/monte_carloLH/%s' % (WORKDIR,file_DATA))
			a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?',DATA.readline())
			chi2_DATA_et = float(a[0]) 
			DATA.close()
			Q_data = math.exp( (chi2_DATA_0-chi2_DATA_et) / 2 )
			Q_mc=[]
			for IREP2 in IREP2_CI:
				try:
					Chi2_CI, Chi2_SM = chi2_CI[IREP2_CI.index(IREP2)],chi2_SM[IREP2_SM.index(IREP2)]
					Q_mc.append(math.exp( (Chi2_SM-Chi2_CI) / 2 ))
					# print "Chi2_SM: ", Chi2_SM, "Chi2_CI", Chi2_CI
					# print "Q_data: ", Q_data, "Q_current: ", math.exp( (Chi2_SM-Chi2_CI) / 2 )
				except ValueError:
					pass
			error.append(sqrt(0.95*0.05/len(chi2_CI)))
			eta_true.append(eta_true_CI[0])
			if CL_SIDE == 'right':
				probability.append(sum(i < Q_data for i in Q_mc)/float(len(Q_mc)))
			elif CL_SIDE == 'left':
				probability.append(sum(i < Q_data for i in Q_mc)/float(len(Q_mc)))
		except:
			print 'ERROR: File "%s" and _SM weren`t read' %file_CI
			# print "Empty histogram index:  ",j
			pass

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
	plt.ylabel(r'$Prob(Q^{mc}<Q^{Data})(\%)$')
	plt.title('VV model')
	plt.text(60, .025, r'$\mu=100,\ \sigma=15$')
	plt.grid(True)
	plt.show()