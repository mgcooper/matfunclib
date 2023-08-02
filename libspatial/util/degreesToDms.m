function [ dms ] = degreesToDms( D )
%DEGREESTODMS convert decimal degrees to degrees minutes seconds
% 
% Author: Jefferson Osowsky.
%
% Given a one-dimensional vector D with length L, where each element D( i )
% represents a decimal degree.
% This function returns in a ( L x 3 ) matrix dms Degree, Minute and Second
% representation for each row of D.
%
% Remark: I decided to build this function for fixing a bug that I found in
% Matlab's degrees2dms function.
%
dms = [];
if ( isempty( D ) )
    return;
end
D = D( : );
L = length( D );
dms = zeros( L, 3 );
for i = 1 : L
    % Get degrees.
    if ( D( i ) >= 0 )
        dms( i, 1 ) = floor( D( i ) );
    else
        dms( i, 1 ) = -floor( -D( i ) );
    end
    
    % Get minutes.
    dms( i, 2 ) = abs( D( i ) - dms( i, 1 ) );
    dms( i, 2 ) = floor( dms( i, 2 ) * 60 );
    
    % Get seconds.
    if ( D( i ) >= 0 )
        dms( i, 3 ) = D( i ) - ( ( dms( i, 1 ) ) + ( dms( i, 2 ) / 60 ) );
    else
        dms( i, 3 ) = abs( D( i ) - ( ( dms( i, 1 ) ) - ( dms( i, 2 ) / 60 ) ) );
    end
    dms( i, 3 ) = ( dms( i, 3 ) * 3600 );
    
    % Fix bug of the floor function.
    if ( eps( single( 60 ) ) > abs( 60 - dms( i, 3 ) ) )
        dms( i, 2 ) = dms( i, 2 ) + 1;
        dms( i, 3 ) = 0;
    end
    if ( eps( single( 60 ) ) > abs( 60 - dms( i, 2 ) ) )
        if ( dms( i, 1 ) >= 0 )
            dms( i, 1 ) = dms( i, 1 ) + 1;
        else
            dms( i, 1 ) = dms( i, 1 ) - 1;
        end
        dms( i, 2 ) = 0;
    end
end
end