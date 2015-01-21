// print 16-bit number from rgb values
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// gcc colorconvert.c -o colorconvert

int main(int argc, const char *argv[]) {
	if (argc < 4) {
		printf("need r, g, b\n");
		return 0;
	}

	char r = atoi(argv[1]), g = atoi(argv[2]), b = atoi(argv[3]);
	uint16_t packed = ((uint16_t)(r & 0xfc) << 8) \
					  | ((uint16_t)(g & 0xf8) << 2) \
					  | ((uint16_t)(b & 0xf8) >> 3);
	printf("%d\n", packed);
	return 0;
}
