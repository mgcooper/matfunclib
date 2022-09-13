
figure('Color','w')
h1          =   patch('XData',[xdata3' fliplr(xdata3')], ...
                            'YData',[ydata3a' fliplr(ydata3b')], ...
                            'FaceColor',rgb('magenta'),'FaceAlpha',0.5,...
                            'EdgeColor','none'); hold on;
h2          =   plot(xdata3,(ydata3a+ydata3b)./2,'Color',rgb('magenta'));
% h3          =   plot(xdata3,ydata3a,'Color',rgb('magenta'));
% h4          =   plot(xdata3,ydata3b,'Color',rgb('magenta'));
                        
% export_fig('baseline.png','-r300','-transparent');
export_fig('baseline.png','-r300');
%%
h1.FaceLighting = 'gouraud';
export_fig('face_lighting_gouraud.png','-r300');                       

%%
material shiny
export_fig('material_shiny.png','-r300');                  

%%
h1.SpecularStrength = 0.2;
export_fig('specular_strength.png','-r300');

%%
camlight
export_fig('camlight.png','-r300');

%%
material dull
export_fig('material_dull.png','-r300');

%%
lightangle(-45,30)
h1.FaceLighting = 'gouraud';
h1.AmbientStrength = 0.3;
h1.DiffuseStrength = 0.8;
h1.SpecularStrength = 0.9;
h1.SpecularExponent = 25;
h1.BackFaceLighting = 'unlit';