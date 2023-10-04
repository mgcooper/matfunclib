function test_private_scope

   persistent isbuilt
   if isempty(isbuilt)
      isbuilt = true;
      if ~isfolder("./+foo/private")
         mkdir("./+foo/private");
      end
      if ~isfile("./+foo/bar.m")
         f = fopen("./+foo/bar.m","wt");
         fdisp(f, "function x = bar()");
         fdisp (f, "    x = baz();");
         fdisp (f, "end");
         fclose(f);
      end
      
      if ~isfile("./+foo/private/baz.m")
         f = fopen("./+foo/private/baz.m","wt");
         fdisp (f, "function x = baz()");
         fdisp (f, "    x = pi();");
         fdisp (f, "endfunction");
         fclose(f);
      end
   end
   
   % In matlab, this will print pi to the screen. In Octave, it will error.
   foo.bar
   
   