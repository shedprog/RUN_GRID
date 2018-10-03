# import matplotlib
# matplotlib.rcParams['text.usetex'] = True
# matplotlib.rcParams['text.latex.unicode'] = True
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import fsolve
from scipy.optimize import curve_fit
from scipy.special import erf
import numpy as np
import math, sys, os, re
import ROOT
from matplotlib.patches import Rectangle

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

        # Build histogram for every point:
        # plt.rc('text', usetex=True)
        #plt.rc('font', family='serif')
        extra = Rectangle((0, 0), 1, 1, fc="w", fill=False, edgecolor='none', linewidth=0)
        a1 = plt.axvline(x=3.13397e-07,color='black', linestyle='dashed', linewidth=1)
        # a2 = plt.axvline(x=sum(eta)/float(len(eta)), linestyle='dashed', color='green', linewidth=1)
        a3 = plt.axvline(x=0.0, linestyle='dashed', color='m', linewidth=1)
        # av = sum(eta)/float(len(eta))
        # plt.legend([a1,a2,a3], ["Attr A", "Attr A+B","s"])
        plt.legend([a1,a3,extra], [r"$\eta^{Data}$ = 3.13 $GeV^{-2}$", r"$\eta^{True}$ = 0.0 $GeV^{-2}$",r"Fraction of $\eta^{Fit}>\eta^{Data}$: 0.75%"],loc='upper left')
        # plt.legend([a1,a3,a2], [r"$\eta^{Data} = 3.13 GeV^{-2}$", r"$\eta^{True} = 0.0 GeV^{-2}$","Mean: %f" % av])

        plt.hist(eta, 200, alpha = 1, lw=3, histtype='bar',color='plum')
        # edgecolor='black', linewidth=0.002,
        plt.ylabel('Entries', fontsize=14)
        plt.xlabel(r'$\eta^{Fit} (GeV^{-2}$)',fontsize=14)

        # plt.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
        # plt.grid(True)
        plt.show()
		# except:
		# 	print 'ERROR: File "%s" cannot be calculated' %file