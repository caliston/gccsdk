/* Generated by re2c */
char scan(const unsigned char *s)
{

{
	YYCTYPE yych;

	if (YYLIMIT <= YYCURSOR) YYFILL(1);
	yych = *YYCURSOR;
	if (yych <= 0x60) {
		if (yych == 0x07) goto yy6;
		goto yy8;
	} else {
		if (yych <= 0x61) goto yy4;
		if (yych != 0x7F) goto yy8;
	}
	++YYCURSOR;
	{
		return '"';
	}
yy4:
	++YYCURSOR;
	{
		return '\x2F';
	}
yy6:
	++YYCURSOR;
	{
		return '\x7F';
	}
yy8:
	++YYCURSOR;
	{
		return '\0';
	}
}

}
