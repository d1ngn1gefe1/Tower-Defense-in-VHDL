moves = open('pos.txt').read()
pos = [(0, 6)]
mv = []
for m in moves:
	x, y = pos[-1]
	if m == 'a':
		pos.append((x - 1, y))
		mv.append('LeftDir')
	if m == 'o':
		pos.append((x, y + 1))
		mv.append('DownDir')
	if m == 'e':
		pos.append((x + 1, y))
		mv.append('RightDir')
	if m == ',':
		pos.append((x, y - 1))
		mv.append('UpDir')

mv.append('RightDir')

pxpos = [(x * 30, y * 30) for x, y in pos]
print pxpos, mv

for i in xrange(len(pos)):
	s = 'dests(%d)' % i
	print s + '.pos.x <= tov(%d, 10);' % pxpos[i][0]
	print s + '.pos.y <= tov(%d, 9);' % pxpos[i][1]
	print s + '.dir <= %s;' % mv[i]
