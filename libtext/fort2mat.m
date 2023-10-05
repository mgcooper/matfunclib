function fort2mat(fort_in,fmat_out)

   % convert loop syntax
   %
   % DO THIS FIRST!!

   % first, change % to . to get structure indexing
   % then type statemetns
   % then loop control: 'for', 'do', ' = 1,', etc.
   % then 'end' statements
   % then logicals

   findvals = {'%',                                          ...
      'USE','use','implicit','public','private',             ...
      'module','contains','RETURN',                          ...
      'character(','type(','real(','integer(',               ...
      'logical(','._r8','._rkind',                           ...
      'subroutine','call','do','then',' = 1,','if(',         ...
      'endfor','endif','enddo','end for','end if',           ...
      'end do','end select','end associate','end function',  ...
      'end module','end subroutine','!','&',                 ...
      '.lt.','.gt.','.ne.','.not.','\ = ','.or.','.and.',    ...
      '.true.','.false.',      ...
      'maxval(','minval(','count(','print*, ','write(*,',',*)'};

   replvals = {'.',                                          ...
      '% USE','% use','% implicit','% public','% private',   ...
      '% module','% contains','return',                      ...
      '% character(','% type(','% real(','% integer(',       ...
      '% logical(','.0','.0',                                ...
      'function out = ','out = ','for','',' = 1:','if (',    ...
      'end %for','end %if','end %do','end %for','end %if',   ...
      'end %do','end %select','end %associate','end %function', ...
      'end %module','end %subroutine','%','...',             ...
      '<','>',' ~= ',' ~= ',' ~= ','||','&&',                ...
      'true;','false;',                                      ...
      'max(','min(','sum(','disp([','disp([',''};

   fid = fopen(fort_in);
   fmat_tmp = fscanf(fid,'%c'); fclose(fid);

   for n = 1:numel(findvals)
      fmat_tmp = strrep(fmat_tmp,findvals{n},replvals{n});
   end

   fid = fopen(fmat_out, 'wt');

   fprintf(fid,'%c',fmat_tmp);
   fclose(fid);
end
