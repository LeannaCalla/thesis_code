function [B] = compute_Bmat(c0, t_char, t_start, t_end)
% compute_Bmat: given a constant coupong coefficient (c0),
% charateristic times (for sunrise/sunset) and a desired period
% of time B matrix is generated

% B matrix displays the delayed heating processes based on a particular
% coupling with the environment

t_char = t_char(t_char>t_start); %exclude sunsrise before pig placement
t_char = [t_start, t_char]; % add start time
t_char = t_char(t_char<t_end); % exlude unwanted times

num_sec = length(t_char) - 1;

B = zeros(length(t_start:t_end), num_sec);


for col = 1:num_sec
    row = 0;
    for t = t_start:t_end
        row = row+1;
        % diag elements
        if t< t_char(col+1) && t>= t_char(col)
            B(row, col) = 1-exp(-c0*(t-t_char(col)));
        elseif t>t_char(col+1)
            % below diag
            B(row, col) = exp(-c0*(t-t_char(col+1))) - exp(-c0*(t - t_char(col)));
        end
    end
end

end


