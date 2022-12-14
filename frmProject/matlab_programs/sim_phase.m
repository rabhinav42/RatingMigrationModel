function phase = sim_phase(theta, phi, N)
    
    % theta = prob(next phase = E | current phase = E)
    % phi = prob(next phase = C |  current phase = C)
    
    %%% simulate economic phase, assuming we start with C, to make sure there is at least one occurence of C %%%
    
    phase = [0]; % E = 1, C = 0
    for j=2:N
        u = rand();
        if phase(j-1) == 1
            if u < theta
                phase(j) = 1;
            else
                phase(j) = 0;
            end
        else
            if u < phi
                phase(j) = 0;
            else
                phase(j) = 1;
            end
        end
    end
    
end

