#include <stdio.h>
bool scan(const char * start, const char * const limit)
{
#	define YYCTYPE unsigned char
#	define YYCURSOR start
Cf:
	/*!re2c
		re2c:yyfill:enable = 0;
				Cf = [\xad-\xad\u0600-\u0603\u06dd-\u06dd\u070f-\u070f\u17b4-\u17b5\u200b-\u200f\u202a-\u202e\u2060-\u2064\u206a-\u206f\ufeff-\ufeff\ufff9-\ufffb\U000110bd-\U000110bd\U0001d173-\U0001d17a\U000e0001-\U000e0001\U000e0020-\U000e007f];
		Cf { goto Cf; }
		[^] { return YYCURSOR == limit; }
	*/
}
static const char buffer_Cf [] = "\xC2\xAD\xD8\x80\xD8\x81\xD8\x82\xD8\x83\xDB\x9D\xDC\x8F\xE1\x9E\xB4\xE1\x9E\xB5\xE2\x80\x8B\xE2\x80\x8C\xE2\x80\x8D\xE2\x80\x8E\xE2\x80\x8F\xE2\x80\xAA\xE2\x80\xAB\xE2\x80\xAC\xE2\x80\xAD\xE2\x80\xAE\xE2\x81\xA0\xE2\x81\xA1\xE2\x81\xA2\xE2\x81\xA3\xE2\x81\xA4\xE2\x81\xAA\xE2\x81\xAB\xE2\x81\xAC\xE2\x81\xAD\xE2\x81\xAE\xE2\x81\xAF\xEF\xBB\xBF\xEF\xBF\xB9\xEF\xBF\xBA\xEF\xBF\xBB\xF0\x91\x82\xBD\xF0\x9D\x85\xB3\xF0\x9D\x85\xB4\xF0\x9D\x85\xB5\xF0\x9D\x85\xB6\xF0\x9D\x85\xB7\xF0\x9D\x85\xB8\xF0\x9D\x85\xB9\xF0\x9D\x85\xBA\xF3\xA0\x80\x81\xF3\xA0\x80\xA0\xF3\xA0\x80\xA1\xF3\xA0\x80\xA2\xF3\xA0\x80\xA3\xF3\xA0\x80\xA4\xF3\xA0\x80\xA5\xF3\xA0\x80\xA6\xF3\xA0\x80\xA7\xF3\xA0\x80\xA8\xF3\xA0\x80\xA9\xF3\xA0\x80\xAA\xF3\xA0\x80\xAB\xF3\xA0\x80\xAC\xF3\xA0\x80\xAD\xF3\xA0\x80\xAE\xF3\xA0\x80\xAF\xF3\xA0\x80\xB0\xF3\xA0\x80\xB1\xF3\xA0\x80\xB2\xF3\xA0\x80\xB3\xF3\xA0\x80\xB4\xF3\xA0\x80\xB5\xF3\xA0\x80\xB6\xF3\xA0\x80\xB7\xF3\xA0\x80\xB8\xF3\xA0\x80\xB9\xF3\xA0\x80\xBA\xF3\xA0\x80\xBB\xF3\xA0\x80\xBC\xF3\xA0\x80\xBD\xF3\xA0\x80\xBE\xF3\xA0\x80\xBF\xF3\xA0\x81\x80\xF3\xA0\x81\x81\xF3\xA0\x81\x82\xF3\xA0\x81\x83\xF3\xA0\x81\x84\xF3\xA0\x81\x85\xF3\xA0\x81\x86\xF3\xA0\x81\x87\xF3\xA0\x81\x88\xF3\xA0\x81\x89\xF3\xA0\x81\x8A\xF3\xA0\x81\x8B\xF3\xA0\x81\x8C\xF3\xA0\x81\x8D\xF3\xA0\x81\x8E\xF3\xA0\x81\x8F\xF3\xA0\x81\x90\xF3\xA0\x81\x91\xF3\xA0\x81\x92\xF3\xA0\x81\x93\xF3\xA0\x81\x94\xF3\xA0\x81\x95\xF3\xA0\x81\x96\xF3\xA0\x81\x97\xF3\xA0\x81\x98\xF3\xA0\x81\x99\xF3\xA0\x81\x9A\xF3\xA0\x81\x9B\xF3\xA0\x81\x9C\xF3\xA0\x81\x9D\xF3\xA0\x81\x9E\xF3\xA0\x81\x9F\xF3\xA0\x81\xA0\xF3\xA0\x81\xA1\xF3\xA0\x81\xA2\xF3\xA0\x81\xA3\xF3\xA0\x81\xA4\xF3\xA0\x81\xA5\xF3\xA0\x81\xA6\xF3\xA0\x81\xA7\xF3\xA0\x81\xA8\xF3\xA0\x81\xA9\xF3\xA0\x81\xAA\xF3\xA0\x81\xAB\xF3\xA0\x81\xAC\xF3\xA0\x81\xAD\xF3\xA0\x81\xAE\xF3\xA0\x81\xAF\xF3\xA0\x81\xB0\xF3\xA0\x81\xB1\xF3\xA0\x81\xB2\xF3\xA0\x81\xB3\xF3\xA0\x81\xB4\xF3\xA0\x81\xB5\xF3\xA0\x81\xB6\xF3\xA0\x81\xB7\xF3\xA0\x81\xB8\xF3\xA0\x81\xB9\xF3\xA0\x81\xBA\xF3\xA0\x81\xBB\xF3\xA0\x81\xBC\xF3\xA0\x81\xBD\xF3\xA0\x81\xBE\xF3\xA0\x81\xBF\x00";
int main ()
{
	if (!scan (buffer_Cf, buffer_Cf + sizeof (buffer_Cf) - 1))
		printf("test 'Cf' failed\n");
}
