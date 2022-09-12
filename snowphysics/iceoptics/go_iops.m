%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [iops,geom] = go_iops(side_length,depth,reals,imags,wavel)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    omeg    = zeros(size(reals));
    asym    = zeros(size(reals));
    absx    = zeros(size(reals));
    mabs    = zeros(size(reals));
    
    del     = 0.3;
    geom    = go_geom(side_length,depth);
    
    A       = geom.A;   % area
    V       = geom.V;   % volume
    ar      = geom.ar;  % aspect ratio
    
    a0      = 0.457593;
    a1      = 20.9738;
    b0      = -0.822315;
    b1      = -1.20125;
    b2      = 0.996653;
    
    [~,~,~,nq1,nq2,c_ij,q_ij,~,p_a_eq_1,c_g,s,u] = go_defaults();
    
    for m = 1:numel(wavel)
    
        mr = reals(m);
        mi = imags(m);
        wl = wavel(m);
        
        % -------- selector for plates or columns
        if ar > 1.0
            cp = 2;     % columns
        else
            cp = 1;     % plates & compacts
        end
            
        %------------------------------------------------
        %------------ Size parameters -------------------
        %------------------------------------------------
        chi_abs = mi/wl*V/A;            % abs. size par. (Fig 4 box 1)
        chi_sca = 2.*pi*sqrt(A/pi)/wl;  % sca. size par. (Fig 7 box 1)
        
        %------------------------------------------------
        %------------ SINGLE SCATTERING ALBEDO ----------
        %------------------------------------------------
        if chi_abs > 0
            w = go_omeg(c_ij,chi_abs,a0,a1,cp,ar);
        else
            w = 1.0;
        end

        %------------------------------------------------
        %--------------- ASYMMETRY PARAMETER ------------
        %------------------------------------------------
        
        % diffraction g
        gD  = b0*exp(b1*log(chi_sca))+b2; %(Fig. 7, box 2)
        gD  = max(gD,0.5);
        
        % raytracing g at 862 nm
        g1 = 0;
        for j = 1:numel(p_a_eq_1)
            g1 = g1 + p_a_eq_1(j)*del.^j; %(Fig. 7, box 3)
        end
        p_del=zeros(nq1);
        for j = 1:numel(nq2)
            p_del = p_del + q_ij(:,j,cp)*log10(ar).^j; %(Fig. 7, box 4)
        end
        Dg = 0;
        for j = 1:numel(nq1)
            Dg = Dg + p_del(j)*del.^j;  %(Fig. 7, box 4)
        end 
        g_rt = 2.*(g1 + Dg)-1.0;  %(Fig. 7, box 5)
        
        %--------- refractive index correction of asymmetry parameter (Fig. 7, box 6)
        epsilon = c_g(1,cp)+c_g(2,cp)*log10(ar);
        mr1     = 1.3038;   %reference value @ 862 nm band
        % abs function added according to corrigendum to the original paper
        C_m     = abs((mr1-epsilon)/(mr1+epsilon)*(mr+epsilon)/(mr-epsilon));
        
        %---- correction for absorption (Fig. 7, box 7)
        if chi_abs > 0
            C_w0 = 0;
            for j = 1:numel(s)
                C_w0 = C_w0 + s(j)*(1.0-w).^j;
            end
            k = log10(ar)*u(cp);
            C_w1 = k*w-k+1.0;
            C_w = C_w0*C_w1;
        else
            C_w = 1.0;
        end
        
        % raytracing g at required wavelength
        g_rt_corr = g_rt*C_m*C_w; %(Fig. 7, box 9)
        
        %------ Calculate total asymmetry parameter and check g_tot <= 1 (Fig. 7, box 9)
        g_tot = 1/(2*w)*((2*w-1)*g_rt_corr+gD);
        g_tot = min(g_tot,1.0);
        
    
        absXS   = A*(1-((exp(-4*pi*mi*V))/(A*wl)));
        MAC     = absXS/V*914; % divide by volume*mass to give mass absorption coefficient
        
        omeg(m) = w;        % single scattering albedo
        asym(m) = g_tot;    % asymmetry parametr
        absx(m) = absXS;    % absorption cross section
        mabs(m) = MAC;      % mass absorption coefficient
        
    end
    iops.omeg   = omeg;
    iops.asym   = asym;
    iops.absx   = absx;
    iops.mabs   = mabs;
end

function w = go_omeg(c_ij,chi_a,a0,a1,col_pla,ar)
    	
    w_1 = 1-a0*(1-exp(-chi_a*a1));                  % for AR=1, Fig 4 box 2)
    j   = [1 2 3 4];
    l   = sum(c_ij(:,:,col_pla).*log10(ar).^j,2);   % Fig. 4, box 3
    D_w = l(1)/(sqrt(2*pi)*l(2)*chi_a)*exp(-(log(chi_a)-l(3))^2/(2*l(2)^2));
    w   = w_1 + D_w;                                %(Fig. 4, box 4)
        
%         l   = zeros(nc1,1);
%         for j = 1:nc2
%             l = l + c_ij(:,j,col_pla)*log10(ar).^j;  
%         end
end

function geom = go_geom(side_length,depth)
    
    V       = 1.5*sqrt(3)*side_length.^2*depth;             %volume
    Atot    = 3*side_length*(sqrt(3)*side_length+depth*2);  %total surface area 
    A       = Atot/4;                                 % projected area
    
    % distance from centre point to midpoint of a side for hexagon
    apothem = (2*A) / (depth*6);
    diam    = 2*apothem; % midpoint of one side to midpoint of opposite side
                
    ar      = depth/side_length;
    
    % package up geometry
    geom.length     = side_length;
    geom.depth      = depth;
    geom.Atot       = Atot;
    geom.A          = A;
    geom.V          = V;
    geom.apothem    = apothem;
    geom.diam       = diam;
    geom.ar         = ar;
end


function [a,nc1,nc2,nq1,nq2,c_ij,q_ij,b_gdiffr,p_a_eq_1,c_g,s,u] = go_defaults()
           %------------------------------------------------
        %---------- input tables (see Figs. 4 and 7) ----
        %------------------------------------------------
        % SSA parameterization
        a = [  0.457593 ,  20.9738 ]; %for ar=1
        
        % SSA correction for AR != 1 (Table 2)
        nc1 = 3;
        nc2 = 4;
        c_ij = zeros(nc1,nc2,2);
        %   ---------- Plates ----------  
        c_ij(:,1,1) = [  0.000527060 ,  0.309748   , -2.58028  ];
        c_ij(:,2,1) = [  0.00867596  , -0.650188   , -1.34949  ];
        c_ij(:,3,1) = [  0.0382627   , -0.198214   , -0.674495 ];
        c_ij(:,4,1) = [  0.0108558   , -0.0356019  , -0.141318 ];
        %   --------- Columns ----------
        c_ij(:,1,2) = [  0.000125752 ,  0.387729   , -2.38400  ];
        c_ij(:,2,2) = [  0.00797282  ,  0.456133   ,  1.29446  ];
        c_ij(:,3,2) = [  0.00122800  , -0.137621   , -1.05868  ];
        c_ij(:,4,2) = [  0.000212673 ,  0.0364655  ,  0.339646 ];
        
        % diffraction g parameterization
        b_gdiffr = [-0.822315,-1.20125,0.996653];
        
        % raytracing g parameterization ar=1
        p_a_eq_1 = [0.780550,0.00510997,-0.0878268,0.111549,-0.282453];
        
        %---- g correction for AR != 1 (Also applied to AR=1 as plate) (Table 3)
        nq1 = 3;
        nq2 = 7 ;
        q_ij = zeros(nq1,nq2,2);
        %   ---------- Plates ----------  
        q_ij(:,1,1) = [ -0.00133106  , -0.000782076 ,  0.00205422 ];
        q_ij(:,2,1) = [  0.0408343   , -0.00162734  ,  0.0240927  ];
        q_ij(:,3,1) = [  0.525289    ,  0.418336    , -0.818352   ];
        q_ij(:,4,1) = [  0.443151    ,  1.53726     , -2.40399    ];
        q_ij(:,5,1) = [  0.00852515  ,  1.88625     , -2.64651    ];
        q_ij(:,6,1) = [ -0.123100    ,  0.983854    , -1.29188    ];
        q_ij(:,7,1) = [ -0.0376917   ,  0.187708    , -0.235359   ];
        %   ---------- Columns ----------
        q_ij(:,1,2) = [ -0.00189096  ,  0.000637430 ,  0.00157383 ];
        q_ij(:,2,2) = [  0.00981029  ,  0.0409220   ,  0.00908004 ];
        q_ij(:,3,2) = [  0.732647    ,  0.0539796   , -0.665773   ];
        q_ij(:,4,2) = [ -1.59927     , -0.500870    ,  1.86375    ];
        q_ij(:,5,2) = [  1.54047     ,  0.692547    , -2.05390    ];
        q_ij(:,6,2) = [ -0.707187    , -0.374173    ,  1.01287    ];
        q_ij(:,7,2) = [  0.125276    ,  0.0721572   , -0.186466   ];
        
        %--------- refractive index correction of asymmetry parameter
        c_g = zeros(2,2);
        c_g(:,1) = [  0.96025050 ,  0.42918060 ];
        c_g(:,2) = [  0.94179149 , -0.21600979 ];
        %---- correction for absorption 
        s = [  1.00014  ,  0.666094 , -0.535922 , -11.7454 ,  72.3600 , -109.940 ];
        u = [ -0.213038 ,  0.204016 ];
end

% function net_cdf_updater(RIsource,savepath, Assy_list, SSA_list, MAC_list, depth, side_length, density)
% 
%     filepathIN = savepath
%     MAC_IN = np.squeeze(MAC_list)
%     SSA_IN = np.squeeze(SSA_list)
%     Assy_IN = np.squeeze(Assy_list)
% 
%     if RIsource == 0
%         stb1 = 'ice_Wrn84/'
%         stb2 = 'ice_Wrn84_'
% 
%     elseif RIsource == 1
%         stb1 = 'ice_Wrn08/'
%         stb2 = 'ice_Wrn08_'
% 
%     elseif RIsource == 2
%         stb1 = 'ice_Pic16/'
%         stb2 = 'ice_Pic16_'
%     end
% 
%     icefile.asm_prm     = Assy_IN;
%     icefile.ss_alb      = SSA_IN;
%     icefile.ext_cff_mss = MAC_IN;
%     %icefile             = icefile.to_xarray()
%     icefile.attrs.medium_type = 'air';
%     icefile.attrs.description = ['Optical properties for ice grain: '   ...
%                                     'hexagonal column of side length '  ...
%                                     num2str(side_length) 'um and length ' ...
%                                     num2str(depth) 'um'];
%     icefile.attrs.psd           = 'monodisperse';
%     icefile.attrs.side_length_um = depth;
%     icefile.attrs.density_kg_m3 = density;
%     icefile.attrs.origin        = ['Optical properties derived from '   ...
%                                     'geometrical optics calculations'];
% %     icefile.to_netcdf(str(filepathIN + stb1 + stb2 + '{}_{}.nc'.format(str(side_length), str(depth))))
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  FUNCTON CALLS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [reals,imags,wavelengths] = preprocess_RI(RIsource,datapath);
% 
% for side_length in np.arange(2000,11000,1000)
%     for depth in np.arange(2000,31000,1000):
%         
%         Assy_list, SSA_list, MAC_list, depth, side_length, diameter =\
%             calc_optical_params(side_length,depth, reals,imags,wavelengths,plots=False,
%             report_dims = True)
%         
%         net_cdf_updater(RIsource, savepath,Assy_list,SSA_list,MAC_list, depth, side_length, 917)


%         if plotflag == true
%             figure(1)    
%             plot(wavel,ssa);
%             ylabel('SSA')
%             xlabel('Wavelength (um)')
%             figure(2)
%             plot(wavel,asym);
%             ylabel('Assymetry Parameter')
%             xlabel('Wavelength (um)')
%             figure(3)
%             plot(wavel,MAC)
%             ylabel('Mass Absorption Cross Section')
%             xlabel('Wavelength (um)')
%         end
% 
%         if report_dims == true
%             disp(['Width of hexagonal plane = ' num2str(diameter/10000) ' (cm)'])
%             disp(['depth of hexagonal column = ' num2str(depth/10000) ' (cm)'])
%             disp(['aspect ratio = ' num2str(ar)])
%             disp(['ice crystal volume = ' num2str(V*1e-12,2) ' (cm^3)'])
% 
%         end
