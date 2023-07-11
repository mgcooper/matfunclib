function writematlabbib

% if nargin == 0
%    bib_file_name = 'matlab.bib';
% end

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
bib_file_name=sprintf('matlab_cite_key_%s.bib',rel);
lines=cell(6,1);
lines{1}=sprintf('@manual{MATLAB:%s,',rel);
lines{2}='  address = {Natick, Massachusetts},';
lines{3}='  organization = {The Mathworks, Inc.},';
lines{4}=sprintf('  title = {{MATLAB version %s}},',v);
lines{5}=sprintf('  year = {%s},',year);
lines{6}='}';
fid=fopen(bib_file_name,'wt');fprintf(fid,'%s\n',lines{:});fclose(fid);