# join all the sprites images to one ram file, using img2binary
from glob import glob
import os

files = glob('towers/fire/*.png') + glob('towers/poison/*.png') + glob('towers/ice/*.png')
files += ['grass.png', 'background.png']
files += glob('monsters/*.png')
files += ['misc_colors.png']

outFiles = [f.replace('.png', '.bin') for f in files]

for f, outF in zip(files, outFiles):
	if os.path.exists(outF):
		os.remove(outF)
	print 'processing', f, 'to', outF
	os.system('../img2binary %s %s' % (f, outF))

os.system('cat %s > allsprites.bin' % ' '.join(outFiles))
