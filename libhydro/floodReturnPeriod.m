function [flow, period] = floodReturnPeriod(T, Q, kwargs)

   % TODO: Currently, this is designed to return the flow rate for a specific
   % return period, but to do so it computes the full distribution and creates a
   % table of all return periods based on the b17 function. That's a lot of
   % computation for just returning a single return period, so flexibility
   % should be added to return the full table, making this a convenient wrapper
   % around b17.

   arguments(Input)
      T (:, 1) datetime
      Q (:, 1) double
      kwargs.returnPeriod (:, 1) double {...
         mustBeInRange(kwargs.returnPeriod, 1.0001, 10000)} = []
      kwargs.generalizedWeightedSkew (1, 1) double = 0.3
      kwargs.gaugeName (1, :) char = ""
      kwargs.plotReferenceLines (1, 1) logical = true
      kwargs.makeplot (1, 1) logical = false
      kwargs.plottype (1, 1) double = 1;
   end
   arguments(Output)
      flow
      period
   end
   assert(activate('b17', 'silent', true))

   % Create a timetable.
   Data = array2timetable(Q, 'RowTimes', T);

   % Compute annual maximum flows.
   [Peaks_AMF, ~, Dates_AMF] = aggannualdata(Data, 'max');

   % Estimate the return period distribution.
   [dataout, skews, pp, XS, SS, hp] = b17( ...
      [year(Dates_AMF), cms2cfs(Peaks_AMF)], ...
      gg=kwargs.generalizedWeightedSkew, gaugeName=kwargs.gaugeName, ...
      plotref=kwargs.plotReferenceLines, plottype=kwargs.plottype); %#ok<ASGLU>

   % Convert to a table.
   dataout = array2table(dataout, "VariableNames", ...
      ["ReturnPeriodYears", "Probability", "FlowRate17B", "FlowRateUpperCI", ...
      "FlowRateLowerCI", "FlowRateExpectedValue"]);

   % convert from cfs to cms.
   dataout.FlowRate17B = cfs2cms(dataout.FlowRate17B);

   % compute the requested return period flow rate in cms.
   x = dataout.ReturnPeriodYears;
   y = dataout.FlowRate17B;
   xq = kwargs.returnPeriod;
   yq = interp1(x, y, xq, "linear");

   flow = yq;
   period = xq;
end
