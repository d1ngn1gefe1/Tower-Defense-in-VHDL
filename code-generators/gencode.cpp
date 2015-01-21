// generate code to setup grid
#include <opencv2/opencv.hpp>
#include <iostream>
#include <stdint.h>

// clang++ gencode.cpp -L/usr/local/lib -lopencv_core -lopencv_contrib -lopencv_imgproc -lopencv_legacy -lopencv_highgui -lopencv_ocl -o gencode

using namespace std;
using namespace cv;

int main(int argc, const char *argv[]) {
	if (argc < 2) {
		printf("usage: %s <image>\n", argv[0]);
		return 0;
	}

	Mat im = imread(argv[1], 0);
	int gridI = 0;
	for (int i = 0; i < im.rows; i++) {
		uchar *ptr = im.ptr<uchar>(i);
		for (int j = 0; j < im.cols; j++) {
			printf("myGrid(%d) <= get_base_elem(%s);\n", gridI, ptr[j] ? "Empty" : "Path");
			gridI++;
		}
	}
	return 0;
}
