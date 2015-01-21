# find color not used in any image, and flood fill top left of each image with it.
import scipy.ndimage as nd
import os
from itertools import product
from glob import glob

allPx = [set() for i in xrange(3)]

inF = glob('*.png')

def discr(px):
	return (px[0] / 4 * 4, px[1] / 8 * 8, px[2] / 8 * 8)

for f in inF:
	im = nd.imread(f)
	for row in im:
		for px in row:
			allPx[0].add(px[0] / 4 * 4)
			allPx[1].add(px[1] / 8 * 8)
			allPx[2].add(px[2] / 8 * 8)
	print f, len(allPx[0])

for r in xrange(0, 256, 4):
	if r not in allPx[0]:
		print r
		break
for g in xrange(0, 256, 8):
	if g not in allPx[1]:
		print g
		break
for b in xrange(0, 256, 8):
	if b not in allPx[2]:
		print b
		break

for f in inF:
	os.system("convert %s -fill 'rgb%s' -draw 'color 0,0 floodfill' %s" % (f, (r, g, b), f))
