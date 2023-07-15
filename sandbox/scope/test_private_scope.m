mkdir("./+foo/private");
f = fopen("./+foo/bar.m","wt");
fdisp(f, "function x = bar()");
fdisp (f, "    x = baz();");
fdisp (f, "end");
fclose(f);
f = fopen("./+foo/private/baz.m","wt");
fdisp (f, "function x = baz()");
fdisp (f, "    x = pi();");
fdisp (f, "endfunction");
fclose(f);
foo.bar