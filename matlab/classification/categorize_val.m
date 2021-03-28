function [b] = categorize_val(z)
    if abs(z) < 0.25
        b = 0;
    elseif z >= 0.25
        b = 1;
    else
        b = -1;
    end
    return
end