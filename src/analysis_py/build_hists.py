import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
from numpy import array, sqrt, pi, exp, linspace
from scipy.optimize import fsolve
from scipy.optimize import curve_fit
from scipy.special import erf
import numpy as np
import math, sys, os, re
from Q_method import read_to_array

CIvarval = 4.03674E-08

if __name__ == "__main__":
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
    print files_CI, files_SM,files_DATA    
    """
    This part read all heaps (5000)
    replicas for Eta_mc=0
    """ 
    # # HISTOGRAN Q_mc (*)
    hist_Q=[]
    hist_Qdata=[]
    hist_eta=[]
    j=-1    
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
                except ValueError:
                    pass
            hist_eta.append(eta_true_SM[0])
            hist_Q.append(Q_mc)
            hist_Qdata.append(Q_data)
        except:
            print 'ERROR: File "%s" and _SM weren`t read' %file_CI
    		# print "Empty histogram index:  ",j
            pass    
    #Plot len(Q) hists
    print len(hist_Qdata)
    leng = len(hist_Qdata)
    # fig = plt.figure()
    
    print int('%d%d%d' % (2,3,1+1))
    
    plt.subplot(int('%d%d%d' % (1,1,1)))
    
    plt.axvline(x=hist_Qdata[1],color='y')
    
    plt.hist(hist_Q[1], 80, alpha = 0.8, lw=3,range=(0,100))
    
    # ax.text(3, 8, r'\eta_{true}: %s' % hist_eta[i], style='italic',
    
    # bbox={'facecolor':'red', 'alpha':0.5, 'pad':10})
    
    # plt.xlabel('log(Q_mc), %s' % hist_eta[i])
    
    plt.ylabel('%s' % hist_eta[1])

    plt.show()

    for i in range(leng-1):
        print int('%d%d%d' % (2,3,i+1))
        plt.subplot(int('%d%d%d' % (3,3,i+1)))
        plt.axvline(x=hist_Qdata[i],color='y')
        plt.hist(hist_Q[i], 80, alpha = 0.8, lw=3,range=(0,100))
        # ax.text(3, 8, r'\eta_{true}: %s' % hist_eta[i], style='italic',
        # bbox={'facecolor':'red', 'alpha':0.5, 'pad':10})
        # plt.xlabel('log(Q_mc), %s' % hist_eta[i])
        plt.ylabel('%s' % hist_eta[i])
    plt.show()