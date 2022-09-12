
function cms = cmd2cms(cmd)

    % convert cubic meters / second to cubic meters / day
    
    % inputs:
    %   cfs = array of flow values in cubic meters/second
    % 
    % outputs:
    %   cms = array of flow values in cubic meters/second

    cms = cmd./86400;
