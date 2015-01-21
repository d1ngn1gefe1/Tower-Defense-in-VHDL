#include <opencv2/opencv.hpp>
#include <iostream>
#include <stdint.h>

// clang++ img2binary.cpp -L/usr/local/lib -lopencv_core -lopencv_contrib -lopencv_imgproc -lopencv_legacy -lopencv_highgui -lopencv_ocl -o img2binary

using namespace std;
using namespace cv;

int main(int argc, const char *argv[]) {
	if (argc < 3) {
		printf("usage: %s <image> <outfile>\n", argv[0]);
		return 0;
	}

	if (fopen(argv[2], "r") != NULL) {
		printf("file exists, please remove\n");
		return 1;
	}

	FILE *outFile = fopen(argv[2], "wb");
	if (outFile == NULL) {
		printf("error creating file\n");
		return 1;
	}

	Mat im = imread(argv[1]);
	for (int i = 0; i < im.rows; i++) {
		uchar *ptr = im.ptr<uchar>(i);
		for (int j = 0; j < im.cols; j++) {
			// red gets 6 bits, green/blue get 5 bits
			uint16_t packed = ((uint16_t)(ptr[2] & 0xfc) << 8) \
							  | ((uint16_t)(ptr[1] & 0xf8) << 2) \
							  | ((uint16_t)(ptr[0] & 0xf8) >> 3);
			fwrite(&packed, 2, 1, outFile);
			ptr += 3;
		}
	}
	fclose(outFile);
	return 0;
}
