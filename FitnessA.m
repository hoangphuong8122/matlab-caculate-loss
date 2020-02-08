function [cost, sol] = FitnessA(xhat, data)

%% ham fitness
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
dat=data;
%xhat=rand(1,data.nbr+data.nb);    % elements=number of bus + number of branch
% chuyen ve ham
xhat_nbr=xhat(1:data.nbr)';

%xhat_nb= xhat(data.nbr+1:data.nbr+data.nb)';
%xhat_nb= xhat;
[b1,I1]=sort(xhat_nbr,'descend');
var_br=I1(1:data.DelBranch)';
%[b2,I2]=sort(xhat_nb,'descend');[
%var_gen1=I2(1:data.numGen)';
%var_gen2=xhat_nb(var_gen1)';
%var_gen3=var_gen2*(data.Genlimit(2)-data.Genlimit(1))+data.Genlimit(1);
var=var_br;
%var=[var_br var_gen1 var_gen3];
%var=[22 34 35 36 37 7 9 11 1 1 1];
%%
dat.branch(var_br',:)=[];
%vi_pham=0;
dat.bus(:,5)=0;        % so ket noi trong cua nut
for i=1:size(dat.branch,1)
    start_bus=dat.branch(i,2);
    end_bus=dat.branch(i,3);
    dat.bus(start_bus,5)=dat.bus(start_bus,5)+1;
    dat.bus(end_bus,5)=dat.bus(end_bus,5)+1;
end

% kiem tra vi pham
if CheckGraphConnected(dat) == 1
    vi_pham = 0;
else
    vi_pham = 1;
end

% them cong suat tac dung vao cac nut gan MFD.
%dat.bus(var_gen1',3)=dat.bus(var_gen1',3)+var_gen3';
dat.bus(:,6)=2;                % nut thong thuong 
dat.bus(dat.bus(:,5)==1,6)=3; % nut cuoi luoi
dat.bus(dat.bus(:,2)==2,6)=1; % nut nguon
dat.branch(:,7)=0;
dat.branch(:,8)=0;
step=0;
while sum(dat.bus(:,5))>0 && vi_pham==0
    for i=1:size(dat.branch,1)
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        % neu 2 nut deu la nut cuoi luoi thi bao vi pham trang thai co lap.
        if dat.bus(dat.branch(i,2),6)==3 && dat.bus(dat.branch(i,3),6)==3
            vi_pham=1;
        end
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       	% neu nut dau la nut cuoi luoi
        if dat.bus(dat.branch(i,2),6)==3 && dat.bus(dat.branch(i,3),6)~=0 && vi_pham==0
            % tinh ton that cong suat tren nhanh
      	dat.branch(i,7)=(dat.bus(dat.branch(i,2),3)^2+dat.bus(dat.branch(i,2),4)^2)/dat.Udm^2*dat.branch(i,4);%deltaP
       	dat.branch(i,8)=(dat.bus(dat.branch(i,2),3)^2+dat.bus(dat.branch(i,2),4)^2)/dat.Udm^2*dat.branch(i,5);%deltaQ
            % cong don cong suat len nut con lai P3=P3+P2+deltaP; Q3=Q3+Q2+deltaQ;
        dat.bus(dat.branch(i,3),3)=dat.bus(dat.branch(i,3),3)+dat.bus(dat.branch(i,2),3)+dat.branch(i,7);     % P
        dat.bus(dat.branch(i,3),4)=dat.bus(dat.branch(i,3),4)+dat.bus(dat.branch(i,2),4)+dat.branch(i,8);     % Q
            % loai nut nay ra khoi he thong dien.
      	dat.bus(dat.branch(i,2),6)=0;
        dat.bus(dat.branch(i,2),5)=0;
            % phan loai lai nut den
        dat.bus(dat.branch(i,3),5)=dat.bus(dat.branch(i,3),5)-1;    
            if dat.bus(dat.branch(i,3),5)==1 && dat.bus(dat.branch(i,3),6)~=1
                dat.bus(dat.branch(i,3),6)=3;     % nut den thanh nut cuoi luoi.
            end
        end
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        % neu nut den la nut cuoi luoi.
        if dat.bus(dat.branch(i,3),6)==3 && dat.bus(dat.branch(i,2),6)~=0 && vi_pham==0
            % tinh ton that cong suat tren nhanh
      	dat.branch(i,7)=(dat.bus(dat.branch(i,3),3)^2+dat.bus(dat.branch(i,3),4)^2)/dat.Udm^2*dat.branch(i,4);%deltaP
       	dat.branch(i,8)=(dat.bus(dat.branch(i,3),3)^2+dat.bus(dat.branch(i,3),4)^2)/dat.Udm^2*dat.branch(i,5);%deltaQ
            % cong don cong suat len nut con lai P2=P2+P3+deltaP; Q2=Q2+Q3+deltaQ;
        dat.bus(dat.branch(i,2),3)=dat.bus(dat.branch(i,2),3)+dat.bus(dat.branch(i,3),3)+dat.branch(i,7);     % P
        dat.bus(dat.branch(i,2),4)=dat.bus(dat.branch(i,2),4)+dat.bus(dat.branch(i,3),4)+dat.branch(i,8);     % Q
            % loai nut nay ra khoi he thong dien.
      	dat.bus(dat.branch(i,3),6)=0;
        dat.bus(dat.branch(i,3),5)=0;
            % phan loai lai nut di
        dat.bus(dat.branch(i,2),5)=dat.bus(dat.branch(i,2),5)-1;    
            if dat.bus(dat.branch(i,2),5)==1 && dat.bus(dat.branch(i,2),6)~=1
                dat.bus(dat.branch(i,2),6)=3;     % nut di thanh nut cuoi luoi.
            end
%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        end        
    end
    step=step+1;
    if step > dat.nb+1
        vi_pham=1;
    end
end
cost=sum(dat.branch(:,7))+1e6*vi_pham;


sol.data=dat;
sol.init_data=data;
sol.position=xhat;
sol.var=var;
sol.vi_pham=vi_pham;
sol.cost=cost;


