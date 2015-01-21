import scipy.ndimage as nd
from scipy.misc import imsave, imread
import numpy as np
import os
from itertools import product
from glob import glob

inF = glob('*.png')

for f in inF:
	outF = f.replace('.png', '_out.png')
	if os.path.exists(outF):
		os.remove(outF)
	os.system('./strip %s %s' % (f, outF))
