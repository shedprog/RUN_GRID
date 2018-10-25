# This script update minuit ewparam and steering
# according to the latex table created by Oleksii
import sys, os
import shutil
import re

from replica_error import systematic_shift_latex

path_to_latex = sys.argv[1]
path_to_param = sys.argv[2]
model = sys.argv[3]
ci_side = sys.argv[4]
pwd = os.getcwd() 

param, _civarval = systematic_shift_latex(path_to_latex,model,ci_side)

print 'directory exists: ', '%s/%s' % (path_to_param,param)
print os.path.exists("%s/%s" % (path_to_param,param))

print "copying minuit.in.txt"
shutil.copy("%s/%s/minuit.in.txt" % (path_to_param,param), './tmp_xfitter/minuit.in.txt')
print "copying steering.txt"
shutil.copy("%s/%s/steering.txt" % (path_to_param,param), './tmp_xfitter/steering.txt')
print "copying ewparam.txt"
shutil.copy("%s/%s/ewparam.txt" % (path_to_param,param), './tmp_xfitter/ewparam.txt')


print "parsing minuit.in.txt"
parsout = open("%s/%s/output/parsout_0" % (path_to_param,param))
pdfs_after_fit = parsout.read()

minuit = open('./tmp_xfitter/minuit.in.txt','r').read()
minuit = re.sub(r'parameters\n((.|\n)*)\n\*call fcn 3\n', 
                'parameters\n' + pdfs_after_fit\
                + '\n*call fcn 3\n', minuit,
                re.IGNORECASE|re.DOTALL|re.MULTILINE)

minuit_file = open('./tmp_xfitter/minuit.in.txt','w')
minuit_file.write(minuit)

print "parsing steering.txt"
steering = open('./tmp_xfitter/steering.txt','r').read()
steering= re.sub(r'\&CIstudy((.|\n)*)&End',
"""
&CIstudy
  ! Whether to do the Contact Interaction analysis:
  doCI = false

  ! Type of the analysis:
  CItype = 'VV'

  ! Enable/disable running alpha EM
  CIrunning_alphaem = True

	! 'ContAlph' : use function from "src/CI_models.f"
	! 'aemrun'   :              from "EW/src/formff.f"
            CIalphaemrun_func = 'aemrun'

  ! CI variable value and step
	CIvarval = 0.0 
	CIvarstep = 0.5E-08

  CIDoSimpFit = true
  CISimpFitStep = 'SimpFit'

&End
""", steering, re.IGNORECASE|re.DOTALL|re.MULTILINE)
steering_file = open('./tmp_xfitter/steering.txt','w')
steering_file.write(steering)