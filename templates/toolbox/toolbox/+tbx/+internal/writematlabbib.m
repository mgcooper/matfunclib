function writematlabbib(varargin)
   %WRITEMATLABBIB Write matlab bibtex entry to file
   %
   %  writematlabbib() writes the bibfile to the current working directory with
   %  default name based on matlab version.
   %
   %  writematlabbib(filename) writes the bibfile to filename
   %
   % See also:

   narginchk(0, 1)

   v=version;
   rel=ver;rel=rel(1).Release;
   rel=strrep(strrep(rel,'(',''),')','');
   if numel(rel)==6
      year=rel(2:5);
   else
      year=ver('MATLAB');year=year.Date(8:end);
   end
   idx=strfind(v,'Update');
   if ~isempty(idx)
      idx=idx(end)+numel('Update ');
      rel=sprintf('%s_u%s',rel,v(idx:end));
   end

   if nargin < 1
      bibfilename=sprintf('matlab_cite_key_%s.bib',rel);
   else
      bibfilename=varargin{1};
   end

   lines=cell(6,1);
   lines{1}=sprintf('@manual{MATLAB:%s,',rel);
   lines{2}='  address = {Natick, Massachusetts},';
   lines{3}='  organization = {The Mathworks, Inc.},';
   lines{4}=sprintf('  title = {{MATLAB version %s}},',v);
   lines{5}=sprintf('  year = {%s},',year);
   lines{6}='}';
   fid=fopen(bibfilename,'wt');fprintf(fid,'%s\n',lines{:});fclose(fid);
end
