import numpy as np
from matplotlib import pyplot

xs = np.array([0, 10, 255])
ys = np.array([2, 82, 32767])
p1 = 3
p2 = 2
a = np.array([np.array([x ** p1, x ** p2, 1]) for x in xs])
sol = np.linalg.solve(a, ys)

i = np.array(range(0, 256))
hps = sol[0] * (i ** p1) + sol[1] * (i ** p2) + sol[2]

pyplot.plot(i, hps)
pyplot.plot(i, i ** 1.8 + 2)
pyplot.plot(i, i * 8 + 2)
pyplot.show()

for i in xrange(0, 256):
	print 'when tov(%d, 8) =>' % i
	print 'return tov(%d, 15);' % hps[i]

##text = '''WASD: move
##Space: place tower
##1: +Damage
##2: +Range
##3: +Speed
##4: +Slow
##5: +Poison'''
##text = '''Damage:
##Range:
##Speed:'''
##text = '''Game over :('''
##startX = 280
##startY = 224
##
##y = startY
##for line in text.splitlines():
##	print 'elsif (chk_font_y(DrawY, %d)) then' % y
##	x = startX
##	first = True
##	for c in line:
##		if c != ' ':
##			if first:
##				print 'if (chk_font_x(DrawX, %d)) then' % x
##			else:
##				print 'elsif (chk_font_x(DrawX, %d)) then' % x
##			print 'myFontAddr <= tov(%d, 7) & DrawY(3 downto 0);	-- %s' % (ord(c), c)
##			first = False
##		x += 8
##	print 'end if;'
##	y += 16
##print 'end if;'
