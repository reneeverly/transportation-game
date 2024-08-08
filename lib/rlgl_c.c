#include "rlgl.h"

void shim_rlPushMatrix(int i32) {
	return rlPushMatrix();
}

void shim_rlPopMatrix(int i32) {
	return rlPopMatrix();
}
