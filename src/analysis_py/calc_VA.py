from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import curve_fit
import numpy as np
import math, sys, os, re
import ROOT
import matplotlib.pyplot as plt


from replica_error import *

def read_to_array(file):
	f = open(file,'r')
	eta = []
	eta_true = []
	for line in f:
		try:
			a = re.split(r' ',line)
			eta_true_all, chi1, eta_n, chi2, eta_p = \
					float(a[2]), float(a[3]), \
					float(a[4]), float(a[6]), \
					float(a[7])
			if eta_n <= 0.0 and eta_p >= 0.0:
				if chi1 < chi2:
					eta_true.append(eta_true_all)
					eta.append(eta_n)
					label = 'negative min chi'
				else:
					eta_true.append(eta_true_all)
					eta.append(eta_p)
					label = 'positive min chi'
			elif eta_n >= 0.0 and eta_p >= 0.0:
				# print 'first', eta_true_all, chi1, eta_n, chi2, eta_p
				eta_true.append(eta_true_all)
				eta.append(eta_p)
				label = 'positive 0'
			elif eta_n <= 0.0 and eta_p <= 0.0:
				# print 'second', eta_true_all, chi1, eta_n, chi2, eta_p
				eta_true.append(eta_true_all)
				eta.append(eta_n)
				label = 'negative 0'
			
			print eta_true_all, chi1, eta_n, chi2, eta_p, label
		except:
			pass
	f.close()

	# print eta_true,eta
	# plt.hist(eta , len(eta)/20, alpha = 0.8, lw=3,range=(min(eta),max(eta)),color='green')
	# plt.ticklabel_format(style='sci', axis='x', scilimits=(0,0))
	# plt.show()
	# raw_input()
	# print eta_true_all, chi1, eta_n, chi2, eta_p, label
	return eta_true,eta

if __name__ == "__main__":

	param = "data fit"

	CL_SIDE=sys.argv[1]         # right or left
	LIMIT_SETTING=sys.argv[2]   # measured or expected
	WORKDIR=sys.argv[3]         # PATH/TO/OUTPUT
	model=sys.argv[4]

	probability=[]
	eta_true=[]
	error=[]

	eta_data_path = "/home/nikita/Projects_physics/DESY_work_dir/Results/NEW_2018/GENERAL/output/simpfit"
	CIvarval = get_CIvarval('%s/RESULTS_CI_%s.txt' % (eta_data_path,model),LIMIT_SETTING)
	print "This is CIvarval: ",CIvarval

	reg_exp = re.compile(r'.*RESULTS_.*')
	files = sorted([f for f in os.listdir('%s/output/monte_carlo' % WORKDIR) if re.match(reg_exp, f)])
	print files
	
	for file in files:
		try:
			eta_true_arr,eta = read_to_array('%s/output/monte_carlo/%s' % (WORKDIR, file))
			eta_true_one = eta_true_arr[3]
			print 'calculate:', eta_true_one, np.mean(eta)
			print sum(i < 0.0 for i in eta),sum(i < CIvarval for i in eta)

			is_cut = False
			is_cut = True
			# print file, eta_true_arr, eta
			# raw_input("Warning: press to quite")
			if is_cut == True:
				# cut = eta_true_one > 1.18E-6 and eta_true_one < 1.29E-6
				cut = eta_true_one > 3.5E-06
			else:
				cut = True

			if sys.argv[1] == 'right' and cut:
				p_temp = sum(i < CIvarval for i in eta)/float(len(eta))
				probability.append(p_temp)
				error.append(sqrt((1-p_temp)*p_temp/len(eta)))
				eta_true.append(eta_true_one)
			elif sys.argv[1] == 'left' and cut:
				p_temp = sum(i > CIvarval for i in eta)/float(len(eta))
				probability.append(p_temp)
				error.append(sqrt((1-p_temp)*p_temp/len(eta)))
				eta_true.append(eta_true_one)
			print 'File "%s" was calculated' %file, p_temp, eta_true_one
		except:
			print 'ERROR: File "%s" cannot be calculated' %file


	for i in range(len(eta_true)):
		print probability[i], eta_true[i]
	# Estimate parametrs for exponentia
	A, B = estimate_par_exp(probability, eta_true)
	print A,B

	# Exponential fit with ROOT framework

	graph = ROOT.TGraphErrors()
	for i in range(len(eta_true)):
		graph.SetPoint(i, eta_true[i], probability[i])
		graph.SetPointError(i, 0, error[i])


	func = ROOT.TF1("Exponent",function_ROOT,
					min(eta_true),max(eta_true),2)
	func.SetParameters(A,B)
	graph.Fit(func)
	print "CIvarval = ", CIvarval
	eta = func.GetParameter(0)
	eta_error = func.GetParError(0)

	Lambda = math.sqrt(4*math.pi/abs(eta))/1000
	Lambda_er = math.sqrt(math.pi/abs(eta**3))*eta_error/1000

	# ML = math.sqrt(1/abs(eta))/1000
	# ML_er = math.sqrt(math.pi/abs(eta**3))*eta_error/1000


	canvas = ROOT.TCanvas("name", "Contact Interactions analysis", 1524, 800)
	# canvas = ROOT.TCanvas("name", "Contact Interactions analysis")
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
		L = ROOT.TLegend(.1,.6,.3,.9,"Fit results: "+"%s sys"%param )
	elif CL_SIDE == 'right':
		L = ROOT.TLegend(.7,.6,.9,.9,"Fit results: "+"%s sys"%param )
	L.SetFillColor(0)
	# L.AddEntry(graph,"monte carlo results")
	# L.AddEntry(func,"exponential fit")
	L.AddEntry("","#eta_{data} = " + "%.2le" % CIvarval + " GeV^{-2}    ","")
	L.AddEntry("", "#eta = " + "%.2le" % eta + " GeV^{-2}    ","")
	L.AddEntry("", "#Delta#eta = " + "%.2le" % eta_error + " GeV^{-2}    ","")
	# L.AddEntry("","M_{LQ}/#lambda_{LQ} = %.2f" % ML,"")
	# L.AddEntry("","#Delta M_{LQ}/#lambda_{LQ} = %.2f" % ML_er,"")
	L.AddEntry("","#Lambda^{" + ('+' if CL_SIDE == 'right' else '-') + "} = "
	 		 + "%.2f" % Lambda + " TeV    ","")
	L.AddEntry("","#Delta#Lambda^{" + ('+' if CL_SIDE == 'right' else '-') + "} = "
	 		 + "%.2f" % Lambda_er + " TeV    ","")
	L.Draw("Same")

	# # Draw 5% line
	# ly = ROOT.TLine(graph.GetXaxis().GetXmin(),0.05,eta,0.05)
	# ly.SetLineColor(1)
	# ly.SetLineWidth(2)
	# ly.SetLineStyle(4)
	# ly.Draw("Same")

	# lx = ROOT.TLine(eta,graph.GetYaxis().GetXmin(),eta,0.05)
	# lx.SetLineColor(1)
	# lx.SetLineWidth(2)
	# lx.SetLineStyle(4)
	# lx.Draw("Same")

	raw_input("Warning: press to save")

	canvas.SaveAs("%s/%s_%s_%s.pdf" % (WORKDIR,model,CL_SIDE,LIMIT_SETTING) )

	raw_input("Warning: press to quite")