import Image
from glob import glob

inFs = glob('*.png')

for i, inF in enumerate(inFs):
	s = ''

	print '%d => (' % i
	im = Image.open(inF)
	for j, px in enumerate(im.getdata()):
		if j and j % 30 == 0:
			print '\t%d => "%s",' % (j / 30 - 1, s[::-1])
			s = ''
		s += '0' if px == (4, 8, 224) else '1'
	print '\t%d => "%s"' % (29, s)
	s = ''
	print '),'
