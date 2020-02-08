function isConnected = CheckGraphConnected(dat)
    n_br=size(dat.branch,1);
    n_bus=size(dat.bus,1);
    connected = zeros(n_bus,n_bus); %conntect(A,B)=1 if bus A is connected bus B 
    for i=1:n_br
        start_bus=dat.branch(i,2);
        end_bus=dat.branch(i,3);
        connected(start_bus, end_bus) = 1;
        connected(end_bus, start_bus) = 1;
    end
   
    checked = zeros(n_bus,1); % checked(A)=1 if bus A is already checked
    n_checked = 1;
    checked(1) = 1;
    while 1
        done = 1;
        for i=1:n_bus
            if checked(i)==1
                for j=1:n_bus
                    %try
                    if checked(j) == 0
                        if connected(i,j) == 1
                            checked(j) = 1;
                            done = 0;
                            n_checked = n_checked + 1;
                            if n_checked == n_bus
                                isConnected = 1;
                                return;
                            end
                        end
                    end
                    %catch exception
                    %   disp(connected); 
                    %end
                end
            end
        end
        if done == 1
            break;
        end
    end
    isConnected = 0;
end