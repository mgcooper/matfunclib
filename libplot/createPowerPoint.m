function varargout = createPowerPoint(kwargs)
   % generate a ppt report

   % Note: The "if generateReport" stuff is only needed if this is used to
   % create the figures and maybe not actually generate the report. But if
   % this is used as its been refactored here, to use a set of saved figures,
   % then I don't think generateReport is useful.

   arguments (Input)
      % Function options
      kwargs.pathname (1, :) char {mustBeFolder} = pwd()
      kwargs.filename (1, :) char = ''
      kwargs.figurelist (:, 1) = []
      kwargs.templatename (1, :) char = 'Default'

      % Presentation global configuration
      kwargs.Title (1, :) char = ''
      kwargs.Author (1, :) char = 'Matt Cooper'
      kwargs.Subtitle (1, :) char = ''
      kwargs.Date (1, :) char = datetime("today")
      kwargs.Description (1, :) char = ''

      % Logical name-value pairs
      kwargs.useReportGenerator (1, 1) logical = true
      kwargs.useExportToPptx (1, 1) logical = false
      kwargs.generateReport (1, 1) logical = false
      kwargs.clobber (1, 1) logical = false
      kwargs.append (1, 1) logical = false
      kwargs.makebackup (1, 1) logical = true
   end
   import mlreportgen.ppt.*;

   % The matlab reportgen default ppt:
   % fullfile(matlabroot(), 'toolbox', 'shared', 'mlreportgen', 'ppt', ...
   %    'resources', 'templates', 'pptx', 'default.pptx');

   % Determine which api should be used
   USE_EXPORTTOPPTX = chooseReportGenerator(kwargs);

   % Pull out arguments
   filename = kwargs.filename;
   figurelist = kwargs.figurelist;
   templatename = kwargs.templatename;

   % Prepare filenames
   if ~contains(filename, [".ppt", ".pptx"])
      filename = char(strcat(filename, ".pptx"));
   end
   if ~contains(templatename, [".ppt", ".pptx"])
      templatename = char(strcat(templatename, ".pptx"));
   end

   %% Create or open the slides

   % Note - I think the logic can all be combined.
   % If the file exists
   %     if clobber, then template = the file
   %     else, template = the default or specified template
   % else, the template = the default or specified template

   % if not file, create a new one
   % if is file and clobber, back up the old one and make a new one
   % if is file and append, append to the old one

   slidesFile = char(fullfile(kwargs.pathname, filename));

   % Get the backup out of the way
   if isfile(slidesFile) && kwargs.makebackup

   end

   if USE_EXPORTTOPPTX

      if not(isfile(slidesFile)) || (isfile(slidesFile) && kwargs.clobber)

         % Create a new pptx file from the template
         templatefile = fullfile( ...
            fileparts(which('exportToPPTX.m')), templatename);
         assert(isfile(templatefile))

         slides = exportToPPTX(templatefile);

         % Create a title slide.
         slides.title = kwargs.Title;
         slides.author = kwargs.Author;
         slides.subject = kwargs.Subtitle;
         slides.description = kwargs.Description;

         slides.addSlide('Master', 1, 'Layout', 'Title Slide');

         % slides.addSlide('Master', 1);
         % slides.addTextbox(Title, 'Position', 'Title');
         % slides.addTextbox(char(datetime("today")), 'Position', 'Date');
         %
         % slides.addTextbox(Subtitle, 'Position', 'Subtitle');

         % This fails with default ppt b/c there is no "Title Slide" Layout
         % slide1 = slides.addSlide('Master', 1, 'Layout', 'Title Slide');

      elseif isfile(slidesFile) && ~kwargs.clobber

         % Update the existing pptx file.
         slides = exportToPPTX(slidesFile);
      end

   else

      % This is where I am reconciling the two, moving logic from here into
      % subfunctions, and then the if-else can be removed and USE_EXPORTTOPPTX
      % passed into each function to handle each case.

      if not(isfile(slidesFile)) || (isfile(slidesFile) && kwargs.clobber)

         slides = createNewSlides(slidesFile, USE_EXPORTTOPPTX);

      elseif isfile(slidesFile) % this should be implied: && ~kwargs.clobber

         % THis is getting confusing. But if block is clear, if it is not a file
         % or it is but clobber is true, make a new one. Otherwise it is a
         % file and clobber is false, so then the question is whether to
         % back up the existing one and overwrite the thing from scratch or
         % append.  The thing I cannot figure out is parsing clobber vs append.
         % i want to avoid creating a backup every time I append

         if kwargs.append
         else
            slides = updateSlides(slidesFile, USE_EXPORTTOPPTX);
         end


         % Replace slidesFile with the updated file for the close/open step.
         % Jul 2024 - replaced updatedSlidesFile on rhs with slides.
         % updatedSlidesFile is undefined but is the argument name in the
         % updateSlides function so likely a copy paste error.
         slidesFile = slides;
         %slidesFile = updatedSlidesFile;
      end

      % Add a title slide. If updating, this inserts a separator slide.
      slides = insertTitleSlide(slides, kwargs.Title, kwargs.Subtitle);
   end

   %% Add content to slides

   % Loop over the file list and add each figure to the slide deck
   for n = 1:height(figurelist)

      % This was for the case where I cycled over a set of parameters and
      % created the same figures for each parameter set, to insert a
      % transition between each parameter set, where NewTitle/NewSubtitle
      % were obtained directly from the parameter set values.
      %
      % TRANSITION SLIDE
      % if kwargs.generateReport == 1 && n > 1
      %    % Would need a way to get NewTitle, NewSubtitle, e.g. a casename
      %    slides = insertTitleSlide(slides, NewTitle, NewSubtitle);
      % end


      %    pptx.addTextbox(sprintf('Slide Number %d',slideId));
      %    pptx.addNote(sprintf('Notes data: slide number %d',slideId));


      %  ADD A NEW BLANK SLIDE (CANVAS)
      % --------------------------------
      if kwargs.generateReport
         pictureSlide = addBlankSlide(slides);
      end

      %  ADD THE PICTURE
      % -----------------
      if kwargs.generateReport
         figname = figurelist(n);
         addPictureToSlide(slides, pictureSlide, figname);
      end


      %  ADD A NEW BLANK SLIDE (CANVAS)
      % --------------------------------

      % This would be used if adding multiple slides per iteration e.g. for
      % the case described above where this loop was over parameter sets.
      % This would add a new blank slide (a canvas) on which the new set of
      % figures would be added.

      % if generateReport
      %    pictureSlide = add(slides, 'Blank');
      % end

      ... add additional slides for this iteration

   end
   closeSlides(slides, slidesFile);

   switch nargout
      case 1
         varargout{1} = slides;
      otherwise
   end

   %% Nested functions to wrap reportgen and exportToPPTX

   function pictureSlide = addBlankSlide(slides)
      if USE_EXPORTTOPPTX
         pictureSlide = slides.addSlide();
      else
         pictureSlide = add(slides, 'Blank');
      end
   end

   function addPictureToSlide(slides, pictureSlide, figname)

      if USE_EXPORTTOPPTX
         slides.addPicture(figname);

         % Example of controlling position
         % slides.addPicture(figname, 'Position', [6 3.5 4 2]);

      else

         if isgraphics(figname)
            try
               figfile = [tempfile('fullpath'), '.png'];
               exportgraphics(figname, figfile)
            catch e
               throwAsCaller(e)
            end
         elseif isfile(figname)
            figfile = figname;
         else
            error('Supply a figure handle or full path to figure file')
         end

         plane = Picture(figfile);
         % plane.X = '0.25in';
         % plane.Y = '0.25in';
         % plane.Width = '4in';
         % plane.Height = '3in';
         add(pictureSlide, plane);

         % Create a figure, save it, then add it to the slide
         % f = figure('Units','inches','Position', figure_position);
         % create the plot
         % save the plot
         % figname = fullfile(pathname, figurefilename);

      end
   end

   function closeSlides(slides, slidesFile)

      if USE_EXPORTTOPPTX
         slides.save(char(slidesFile));
      else
         close(slides);
         open(slidesFile);
         % can also use: rptview(slides);
      end
   end
end

function slides = createNewSlides(slidesFile, USE_EXPORTTOPPTX)

   if USE_EXPORTTOPPTX
      % For now I kept the USE_EXPORTTOPPTX logic in the main section, but
      % note that when creating new slides, including clobber, the slides
      % can be created here with slides = exportToPPTX() or
      % exportToPPTX(templatefile), but also exportToPPTX(slidesFile), and in
      % the latter case, when it is saved at the end it will overwrite the
      % existing one if clobber=true. Need to walk carefully through the logic
      % on exportToPPTX but I think this will help with combining the logic.
   else
      slides = mlreportgen.ppt.Presentation(slidesFile);
   end
end

function slides = updateSlides(slidesFile, USE_EXPORTTOPPTX)

   updatedSlidesFile = backupfile(slidesFile, false); % updated filename

   if USE_EXPORTTOPPTX
      % This uses the original file as the template. Not sure if it works to
      % then replace the filename and thus on close it will resave as a new file
      % slides = exportToPPTX(slidesFile);
   else
      slides = mlreportgen.ppt.Presentation(updatedSlidesFile, slidesFile);
   end
end


function slides = insertTitleSlide(slides, Title, Subtitle)
   % Jul 2024 - added slide1 input argument to address codeissues. Not sure if
   % slide1 was supposed to be "slides" ... actually I think it is so I
   % removed slide1 input and commented them out and replaced with "slides".
   add(slides, 'Title Slide');
   replace(slides, 'Title', Title);
   replace(slides, 'Subtitle', Subtitle);
   % replace(slide1, 'Title', Title);
   % replace(slide1, 'Subtitle', Subtitle);
end

function USE_EXPORTTOPPTX = chooseReportGenerator(kwargs)

   USE_EXPORTTOPPTX = kwargs.useExportToPptx;

   if USE_EXPORTTOPPTX
      [~, onpath] = ismfile('exportToPPTX.m');
      if not(onpath)
         try
            activate("exportToPPTX", "silent", true)
         catch e
            warning('exportToPPTX not found, trying Report Generator instead')
            USE_EXPORTTOPPTX = false;
         end
      end
   end
   if ~USE_EXPORTTOPPTX && ~tbx.internal.getfeature("MATLAB Report Generator")
      error('Report generator not available')
   end
end

%{
   [pathname, filename, template, ...
      Title, Author, Subtitle, Description] = convertStringsToChars( ...
      pathname, filename, template, Title, Author, Subtitle, Description);
   
%}
