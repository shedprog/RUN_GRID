import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import curve_fit
import numpy as np
import math, sys, os, re
import ROOT

# This program build plot: 
# P(\eta_true < \eta_DATA)
# P(\eta_true > \eta_DATA)
# P(\eta_true > \eta_SM)
# input: "monte_catlo", "simpfit"

def read_to_array(file):
    '''This function for montecarlo replicas reading
    and putting it into an array'''
    f = open(file,'r')
    eta = []
    eta_true = []
    for line in f:
        a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',line)
        if len(a) == 7 or len(a)==6:
            eta_true.append(float(a[2]))
            eta.append(float(a[3]))
    f.close()
    if eta_true == 0:
        print "Error: empty monte_carlo replica list"
    return eta_true,eta

if __name__ == "__main__":
    WORKDIR=sys.argv[1] # PATH/TO/OUTPUT
    model=sys.argv[2]

	# This part define CIvarval for the analysis of P(R<R_data)
    file_CI = open('%s/output/simpfit/RESULTS_CI.txt' % WORKDIR)
    a = re.findall(r'[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|^\w+',file_CI.readline())
    CIvarval_data = float(a[2])
    file_CI.close()
    CIvarval_SM = 0.0

    '''This part initiate variables'''
    probability_left, error_left = [], []
    probability_right, error_right = [], []
    probability_SM, error_SM = [], []
    eta_true = []

    files = sorted([f for f in os.listdir('%s/output/monte_carlo' % WORKDIR) if re.match(r'.*RES.*', f)])
    print files

    for file in files:
        try:
            eta_true_arr,eta = read_to_array('%s/output/monte_carlo/%s' % (WORKDIR, file))
            eta_true.append(eta_true_arr[0])
            print eta_true_arr[0]
            p_right = sum(i < CIvarval_data for i in eta)/float(len(eta))
            probability_right.append(p_right)
            error_right.append(sqrt((1-p_right)*p_right/len(eta)))

            p_left = sum(i > CIvarval_data for i in eta)/float(len(eta))
            probability_left.append(p_left)
            error_left.append(sqrt((1-p_left)*p_left/len(eta)))

            p_sm = sum(i > CIvarval_SM for i in eta)/float(len(eta))
            probability_SM.append(p_sm)
            error_SM.append(sqrt((1-p_sm)*p_sm/len(eta)))
        except:
			print 'ERROR: File "%s" cannot be calculated' %file


	# # Estimate parametrs for exponentia
	# A, B = estimate_par_exp(probability, eta_true)

	# Exponential fit with ROOT framework

	graph_L = ROOT.TGraphErrors()
    graph_R = ROOT.TGraphErrors()
    graph_SM = ROOT.TGraphErrors()
    

    for i in range(len(eta_true)):

        graph_L.SetPoint(i, eta_true[i], 100*probability_left[i])
        graph_L.SetPointError(i, 0, 100*error_left[i])
        graph_R.SetPoint(i, eta_true[i], 100*probability_right[i])
        graph_R.SetPointError(i, 0, 100*error_right[i])
        graph_SM.SetPoint(i, eta_true[i], 100*probability_SM[i])
        graph_SM.SetPointError(i, 0, 100*error_SM[i])

    canvas = ROOT.TCanvas("name", "Contact Interactions analysis", 824, 500)
    canvas.SetLogy()
    graph_L.GetXaxis().SetTitle('#eta_{True} (GeV^{-2})  ')
    graph_L.GetYaxis().SetTitle('Probability (%)')

    graph_L.SetTitle("ZEUS preliminary")
    graph_L.SetLineColor(9)
    graph_L.SetLineWidth(2)
    graph_L.SetMarkerColor(9)
    graph_L.SetMarkerSize(0.7)
    graph_L.SetFillColor(0)
    graph_L.SetMarkerStyle(25)
    graph_L.Draw("AP")

    graph_R.SetLineColor(9)
    graph_R.SetLineWidth(2)
    graph_R.SetMarkerColor(9)
    graph_R.SetMarkerSize(0.7)
    graph_R.SetFillColor(0)
    graph_R.SetMarkerStyle(24)
    graph_R.Draw("PSame")

    graph_SM.SetLineColor(8)
    graph_SM.SetLineWidth(2)
    graph_SM.SetMarkerColor(8)
    graph_SM.SetMarkerSize(0.7)
    graph_SM.SetFillColor(0)
    graph_SM.SetMarkerStyle(26)
    graph_SM.Draw("PSame")


    L = ROOT.TLegend(.55,.15,.75,.35)
    L.SetFillColor(0)
    L.SetBorderSize(0)
    L.AddEntry(graph_L,"Prob(#eta^{Fit}<#eta^{Data})")
    L.AddEntry(graph_R,"Prob(#eta^{Fit}>#eta^{Data})")
    L.AddEntry(graph_SM,"Prob(#eta^{Fit}>#eta^{SM})")
    L.Draw("Same")

    M = ROOT.TLegend(.15,.65,.3,.75)
    M.SetFillColor(0)
    M.SetBorderSize(0)
    M.AddEntry("","%s model" % model,"")
    M.Draw("Same")

    raw_input("Warning: press to save")
    canvas.SaveAs("%s/PRE_PLOT_%s.pdf" % (WORKDIR,model))
    raw_input("Warning: press to quite")