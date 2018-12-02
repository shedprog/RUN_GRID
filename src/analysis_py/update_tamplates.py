# This script update minuit ewparam and steering
# according to the latex table created by Oleksii
import sys, os
import shutil
import re

from replica_error import systematic_shift_latex

def systematic_param_expected(path_to_latex,model,CL_SIDE):
	'''This function read latex file,
	that was formed by Oleksii Turkot
	and returns parametr
	'''

	print "Systematic shifts will be choosen from latex:"
	print path_to_latex
	print "Minimal and maximal will be choosen for %s model" % model

	file = str(open(path_to_latex).read())

	model_to_latex = {
		"RR":r'RR', "LL":r'LL', "RL":r'RL', "LR":r'LR', "VV":r'VV', "VA":r'VA', "AA":r'AA',
		"X1":r'X1', "X2":r'X2', "X3":r'X3', "X4":r'X4', "X5":r'X5', "X6":r'X6',
		"S_o" : None,
		"S_o_L":r'\$\\textrm\{S\}\_0\^\{\\textrm\{\\scriptsize L\}\}\$',
		"S_o_R":r'\$\\textrm\{S\}\_0\^\{\\textrm\{\\scriptsize R\}\}\$',
		"~S_o":r'\$\\widetilde\{\\textrm\{S\}\}\_0\$',
		"S_1div2_L":r'\$\\textrm\{S\}_\{\\frac\{1\}\{2\}\}\^\{\\textrm\{\\scriptsize L\}\}\$',
		"S_1div2_R":r'\$\\textrm\{S\}\_\{\\frac\{1\}\{2\}\}\^\{\\textrm\{\\scriptsize R\}\}\$',
		#"S_1div2_R":'',
		"~S_1div2":r'\$\\widetilde\{\\textrm\{S\}\}\_\{\\frac\{1\}\{2\}\}\$',
		"S_1":r'\$\\textrm\{S\}\_1\$',
		#"V_o":'',
		"V_o_L":r'\$\\textrm\{V\}\_0\^\{\\textrm\{\\scriptsize L\}\}\$',
		"V_o_R":r'\$\\textrm\{V\}\_0\^\{\\textrm\{\\scriptsize R\}\}\$',
		"~V_o":r'\$\\widetilde\{\\textrm\{V\}\}\_0\$',
		#"V_1div2":'',
		"V_1div2_L":r'\$\\textrm\{V\}\_\{\\frac\{1\}\{2\}\}\^\{\\textrm\{\\scriptsize L\}\}\$',
		"V_1div2_R":r'\$\\textrm\{V\}\_\{\\frac\{1\}\{2\}\}\^\{\\textrm\{\\scriptsize R\}\}\$',
		"~V_1div2":r'\$\\widetilde\{\\textrm\{V\}\}\_\{\\frac\{1\}\{2\}\}\$',
		"V_1":r'\$\\textrm\{V\}\_1\$'
	}
	# print model
	model_latex = model_to_latex[model]
	print model_latex

	# Parse table object for fixed model
	reg_exp_table = r'(\\begin\{table\}((?!\\end\{table\}).)*\\caption\{Results for the '\
					+ model_latex \
					+ r' fits\.\}((?!\\end\{table\}).)*\\end\{table\})'
	print reg_exp_table
	# reg_exp_table = r'(\\begin\{table\}((?!\\end\{table\}).)*\\caption\{Results for the \$\\textrm\{S\}\_1\$ fits\.\}((?!\\end\{table\}).)*\\end\{table\})'
	reg_exp_table = re.compile(reg_exp_table,
							   re.IGNORECASE|re.DOTALL|re.MULTILINE)
	table = reg_exp_table.search(file).group(1) # group(1) doesn't  include outside expression
												# group(0) includes outside expression

	reg_exp_lines = r'\\hline\n(exp(.|\n)*)\\\\\n\\hline'
	reg_exp_lines = re.compile(reg_exp_lines,
							   re.IGNORECASE|re.DOTALL|re.MULTILINE)
	lines = reg_exp_lines.search(table).group(1)

	print "%s MODEL"%model_latex
	print lines

	data_table = []
	error = []
	param_list = []

	for line in lines.split('\\\\\n'): # \\ + \n in the end of lines
		data_line = line.replace(" ", "").split('&')
		error += [float(data_line[3])]
		param_list += [data_line[0]]

	print param_list
	param = param_list[error.index(max(error))]
	print param

	return param

path_to_latex = sys.argv[1]
path_to_param = sys.argv[2]
model = sys.argv[3]
ci_side = sys.argv[4]
# pwd = os.getcwd()
out_dir = sys.argv[5]
ci_mode = sys.argv[6]

if ci_mode == "measured":
  param, _civarval = systematic_shift_latex(path_to_latex,model,ci_side)
elif ci_mode == "expected":
  param = systematic_param_expected(path_to_latex,model,ci_side)
  print '~~~~~~~~~~expected~~~~~~~~~~~'
else:
  print 'Erorr: no such CI mode'

# raw_input('stop')

print 'directory exists: ', '%s/%s' % (path_to_param,param)
print os.path.exists("%s/%s" % (path_to_param,param))

print "copying minuit.in.txt"
shutil.copy("%s/%s/minuit.in.txt" % (path_to_param,param), '%s/minuit.in.txt'%out_dir)
print "copying steering.txt"
shutil.copy("%s/%s/steering.txt" % (path_to_param,param), '%s/steering.txt'%out_dir)
print "copying ewparam.txt"
shutil.copy("%s/%s/ewparam.txt" % (path_to_param,param), '%s/ewparam.txt'%out_dir)


print "parsing minuit.in.txt"
parsout = open("%s/%s/output/parsout_0" % (path_to_param,param))
pdfs_after_fit = parsout.read()

minuit = open('%s/minuit.in.txt'%out_dir,'r').read()
minuit = re.sub(r'parameters\n((.|\n)*)\n\*call fcn 3\n', 
                'parameters\n' + pdfs_after_fit\
                + '\n*call fcn 3\n', minuit,
                re.IGNORECASE|re.DOTALL|re.MULTILINE)

minuit_file = open('%s/minuit.in.txt'%out_dir,'w')
minuit_file.write(minuit)

print "parsing steering.txt"
steering = open('%s/steering.txt'%out_dir,'r').read()
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
steering_file = open('%s/steering.txt'%out_dir,'w')
steering_file.write(steering)