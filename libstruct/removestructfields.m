function struct_out = removestructfields(struct_in,rm_fields)
    
    struct_out  = struct_in;
    
    for n = 1:numel(rm_fields)
        struct_out.(rm_fields{n}) = [];
    end
        
end

