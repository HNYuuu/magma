#include <cstdio>

#ifdef __WASM__
#define INPUT_LEN 8
extern "C" int LLVMFuzzerTestOneInput(const char* data, size_t size);
int main(void) {
	char s[INPUT_LEN];
	for (int i=0; i < INPUT_LEN; i++)
		scanf("%c", &s[i]);
	return LLVMFuzzerTestOneInput(s, INPUT_LEN);
}
#endif
