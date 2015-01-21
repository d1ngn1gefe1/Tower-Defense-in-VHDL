#include <opencv2/opencv.hpp>
#include <iostream>
#include <stdint.h>

// clang++ strip.cpp -L/usr/local/lib -lopencv_core -lopencv_contrib -lopencv_imgproc -lopencv_legacy -lopencv_highgui -lopencv_ocl -o strip

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

	Mat im = imread(argv[1]);
	Mat outIm(im.rows, im.cols, CV_8UC3);
	for (int i = 0; i < im.rows; i += 2) {
		for (int j = 0; j < im.cols; j += 2) {
			int cnt = 0;
			for (int iOff = 0; iOff < 2; iOff++) {
				for (int jOff = 0; jOff < 2; jOff++) {
//					cout << im.at<Vec3b>(i + iOff, j + jOff) << endl;
					cnt += im.at<Vec3b>(i + iOff, j + jOff) == Vec3b(254, 255, 255);
				}
			}

			if (cnt) {
				Vec3b newPx = Vec3b(254, 255, 255);
				for (int iOff = 0; iOff < 2; iOff++) {
					for (int jOff = 0; jOff < 2; jOff++) {
						outIm.at<Vec3b>(i + iOff, j + jOff) = newPx;
					}
				}
			} else {
				for (int iOff = 0; iOff < 2; iOff++) {
					for (int jOff = 0; jOff < 2; jOff++) {
						outIm.at<Vec3b>(i + iOff, j + jOff) = im.at<Vec3b>(i + iOff, j + jOff);
					}
				}
			}
		}
	}
	imwrite(argv[2], outIm);
	return 0;
}
