function [h,p,stats] = myfitdist(data,dists,opts)
   
% TODO: add option to pass in anonymous function to fitdist, see myplawfit   
   
    nd  = numel(dists);
    
    r   = 1;
    c   = 3;
    if nd > 12
        r = 5;
    elseif nd > 9
        r = 4;
    elseif nd > 6
        r = 3;
    elseif nd > 3
        r = 2;
    end
    
%     [F,X]       =   ecdf(data);
%     [BinH,BinC] =   ecdfhist(F,X);
%     hLine       =   bar(BinC,BinH,'hist');
%     % Create grid where function will be computed
%     XLim        =   get(gca,'XLim');
%     XLim        =   XLim + [-1 1] * 0.01 * diff(XLim);
%     XGrid       =   linspace(XLim(1),XLim(2),100);

    xv  = min(data):0.01:max(data);
    fc  = [.9 .9 .9];
    figure;
    for n = 1:nd
        h.pd{n} = fitdist(data,dists{n});
        h.s(n)  = subplot(r,c,n);
        h.h(n)  = histogram(data,'Norm','pdf','FaceColor',fc); hold on;
        h.p(n)  = plot(xv,pdf(h.pd{n},xv));
        title(dists{n});
        
        % this is I did it in stoch hydro
        %h.h(n)  = bar(BinC,BinH,'hist'); hold on;
        %h.p(n)  = plot(xv,pdf(pd{n},xv)); hold off
        [h.chi(n),p.chi(n),stats.chi(n)] = chi2gof(data,'CDF',h.pd{n});
        [h.kst(n),p.kst(n),stats.kst(n)] = kstest(data,'CDF',h.pd{n});
        %[h.adt(n),p.adt(n),stats.adt(n)] = adtest(data,'CDF',h.pd{n});
        %[h.lft(n),p.lft(n),stats.lft(n)] = lillietest(data,'CDF',h.pd{n}); 
    end
end