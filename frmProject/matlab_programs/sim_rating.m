function [cmps, timeE, timeC, tnoE, tnoC] = sim_rating(ME, MC, N, n, phase)
    
    % ME = yearly transition matrix given E
    % MC = yearly transition matrix given C
    % N = no of time steps to simulate
    % n = (uniform) no of companies in each rating class (excluding D and
    % including NR).
    
    
    %%% simulate rating changes %%%
    cmps = zeros(N, 9);
    cmps(1, :) = ones(1, 9)*n;
    cmps(1,8) = 0;
    tnoE = zeros(9,9); % record number of transitions given E
    tnoC = zeros(9,9); % record number of transitions given C
    timeE = cmps(1,:); % record amount of time spent by each rating given E
    timeC = zeros(1,9); % record amount of time spent by each rating given C
    
    QE = logm(ME);
    QC = logm(MC);
    MEq = expm(0.25*QE);
    MCq = expm(0.25*QC);
    
    for j=2:N
        cmps(j,:) = cmps(j-1,:);
        for i=[1:7 9]
            if phase(j-1) == 1
                newratings = randsample(1:9, cmps(j-1,i), true, MEq(i,:));
            else
                newratings = randsample(1:9, cmps(j-1,i), true, MCq(i,:));
            end
            cmps(j,i) = cmps(j,i) - sum(newratings ~= i);
            for k=newratings
                if(k ~= i)
                    cmps(j,k) = cmps(j,k)+1;
                end
                if phase(j-1) == 1
                    tnoE(i,k) = tnoE(i,k) + 1;
                else
                    tnoC(i,k) = tnoC(i,k) + 1;
                end
            end
            if phase(j-1) == 1
                timeE = timeE + cmps(j,:);
            else
                timeC = timeC + cmps(j,:);
            end
        end
        
    end

end

