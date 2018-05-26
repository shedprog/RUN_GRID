import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import curve_fit
import numpy as np
import math, sys, os, re
import ROOT

# This code is for analysis of 95% CL after generating of MC replicas
# In fact, the same code as replica_new.py but + correct fit + errors calc
# Also add sys.argv[3] - mesured or expected limits
# To run this code run it with command:
# > python <this code> <left/right> <measured/expected> <PATH TO RESULTS>
# in <PATH  TO RESULTS> has to be folders: "output"-folder (in output:)
# output: "monte_catlo", "simpfit"

def function(x, A, B):
	'''This function is exponent 
	for fitting procedure'''

	return 0.05 * exp((x-A)*B)

def function_ROOT(x,p):
	'''This function is exponent 
	for fitting procedure in ROOT'''

	return 0.05 * exp((x[0]-p[0])*p[1])

def estimate_par_exp(probability, eta_true):
	'''Thid function estimate best 
	parametrs for sucsesfull exp fit'''

	x1, x2 = eta_true[0], eta_true[-1]
	y1, y2 = 20*probability[0], 20*probability[-1]

	A = x1 * math.log(y2) - x2 * math.log(y1) 
	A = A / (math.log(y2) - math.log(y1))

	B = (math.log(y1) - math.log(y2)) / (x1-x2) 

	return A, B

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
			# len(a) == 6 to skip the 
			if sys.argv[1] == 'right' and len(a) == 6:
				if float(a[2])>CIvarval:
					eta_true.append(float(a[2]))
					eta.append(float(a[3]))
			if sys.argv[1] == 'left' and len(a) == 6:
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

	
	CL_SIDE=sys.argv[1]         # right or left
	LIMIT_SETTING=sys.argv[2]   # measured or expected
	WORKDIR=sys.argv[3]         # PATH/TO/OUTPUT
	model=sys.argv[4]

	# This part define CIvarval for the analysis of P(R<R_data)
	if (LIMIT_SETTING == 'measured'):
		file_CI = open('%s/output/simpfit/RESULTS_CI.txt' % WORKDIR)
		a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',file_CI.readline())
		CIvarval = float(a[2])
		file_CI.close()
	elif (LIMIT_SETTING == 'expected'):
		CIvarval = 0.0
	else:
		print "Error: wrong second <measured/expected> argument"
		sys.exit()

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
			if sys.argv[1] == 'right':
				p_temp = sum(i < CIvarval for i in eta)/float(len(eta))
				probability.append(p_temp)
			elif sys.argv[1] == 'left':
				p_temp = sum(i > CIvarval for i in eta)/float(len(eta))
				probability.append(p_temp)
			error.append(sqrt((1-p_temp)*p_temp/len(eta)))
		except:
			print 'ERROR: File "%s" cannot be calculated' %file


	# Estimate parametrs for exponentia
	A, B = estimate_par_exp(probability, eta_true)

	# Exponential fit with ROOT framework

	graph = ROOT.TGraphErrors()
	for i in range(len(eta_true)):
		graph.SetPoint(i, eta_true[i], probability[i])
		graph.SetPointError(i, 0, error[i])

	func = ROOT.TF1("Exponent",function_ROOT,
					min(eta_true),max(eta_true),2)
	func.SetParameters(A,B)
	graph.Fit(func)
	eta = func.GetParameter(0)
	eta_error = func.GetParError(0)

	Lambda = math.sqrt(4*math.pi/abs(eta))/1000
	Lambda_er = math.sqrt(math.pi/abs(eta**3))*eta_error/1000


	canvas = ROOT.TCanvas("name", "Contact Interactions analysis", 1524, 800)
	graph.GetXaxis().SetTitle('#eta_{True} [GeV]')
	graph.GetYaxis().SetTitle('Prob(#eta^{Fit} < #eta^{Data}) [%]')
	graph.SetTitle("%s - %s" % (model,LIMIT_SETTING) )
	graph.SetLineColor(1)
	graph.SetLineWidth(1)
	graph.SetMarkerColor(9)
	graph.SetMarkerSize(1.5)
	graph.SetFillColor(0)
	graph.SetMarkerStyle(20)
	func.Draw("C")
	graph.Draw("APSame")

	# LineX = ROOT.TLine(A,0.05,A,0) 
	# LineX.Draw("Same")

	if CL_SIDE == 'left':
		L = ROOT.TLegend(.1,.6,.3,.9,"Fit results:")
	elif CL_SIDE == 'right':
		L = ROOT.TLegend(.7,.6,.9,.9,"Fit results:")
	L.SetFillColor(0)
	L.AddEntry(graph,"monte carlo results")
	L.AddEntry(func,"exponential fit")
	L.AddEntry("", "#eta = " + "%.2le" % eta + " GeV^{-2}    ","")
	L.AddEntry("", "#Delta#eta = " + "%.2le" % eta_error + " GeV^{-2}    ","")
	L.AddEntry("","#Lambda^{" + ('+' if CL_SIDE == 'right' else '-') + "} = "
	 		 + "%.2f" % Lambda + " TeV    ","")
	L.AddEntry("","#Delta#Lambda^{" + ('+' if CL_SIDE == 'right' else '-') + "} = "
	 		 + "%.2f" % Lambda_er + " TeV    ","")
	L.Draw("Same")

	canvas.SaveAs("%s/%s_%s_%s.pdf" % (WORKDIR,model,CL_SIDE,LIMIT_SETTING) )

	raw_input("Warning: press to quite")