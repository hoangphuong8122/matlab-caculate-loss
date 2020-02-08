clc
clear

data.DelBranch=5;   % so nhanh can xoa
%data.numGen=3;      % so DG tren luoi.
data.Genlimit=[0 1];  % [min max] P (MW) of DG. 
filename='ieee 33 bus_new'; % file thong so he thong dien.
data.bus=xlsread(filename,1);
data.branch=xlsread(filename,2);
data.Udm=22;    % kV
data.nbr=size(data.branch,1);
data.nb=size(data.bus,1);
data_a=data;    data_b=data;    data_c=data;    data_n=data;
data_a.bus(:,[5 6 7 8])=[];     % xoa cong suat pha bc
data_b.bus(:,[3 4 7 8])=[];     % xoa cong suat pha ac
data_c.bus(:,[3 4 5 6])=[];     % xoa cong suat pha ab
data_n.bus=data_a.bus;        	% cap nhat sau, quen cong thuc
data_n.bus(:,3)=data_a.bus(:,3)-0.5*data_b.bus(:,3)-0.5*data_c.bus(:,3)-sqrt(3)/2*data_b.bus(:,4)+sqrt(3)/2*data_c.bus(:,4);
data_n.bus(:,4)=data_a.bus(:,4)-0.5*data_b.bus(:,4)-0.5*data_c.bus(:,4)+sqrt(3)/2*data_b.bus(:,3)-sqrt(3)/2*data_c.bus(:,3);

CostFunction_a=@(xhat) FitnessA(xhat,data_a);        % Cost Function pha a
CostFunction_b=@(xhat) FitnessA(xhat,data_b);        % Cost Function pha a
CostFunction_c=@(xhat) FitnessA(xhat,data_c);        % Cost Function pha a
CostFunction_n=@(xhat) FitnessA(xhat,data_n);        % Cost Function pha a
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

nVar=data_a.nbr;
VarSize=[1 nVar];   % Decision Variables Matrix Size

VarMin=0;         % Lower Bound of Variables
VarMax=1;         % Upper Bound of Variables
MaxIt=100;      % Maximum Number of Iterations

nPop=20;       % Population Size (Swarm Size)

%w=0.2;              % Inertia Weight
w=0.3;              % Inertia Weight
wdamp=1;            % Inertia Weight Damping Ratio
c1=0.7;             % Personal Learning Coefficient
c2=1;               % Global Learning Coefficient

% Velocity Limits
VelMax=(VarMax-VarMin);
VelMin=-VelMax;

mu = 0.2;      % Mutation Rate

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Sol=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
empty_particle.Best.Sol=[];

particle=repmat(empty_particle,nPop,1);
BestSol.Cost=inf;
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

for i=1:nPop
    % Initialize Position
    particle(i).Position=unifrnd(VarMin,VarMax,VarSize);
    
    % Initialize Velocity
    particle(i).Velocity=zeros(VarSize);
    
    % Evaluation
    [Cost_a, Sol_a]=CostFunction_a(particle(i).Position);
    [Cost_b, Sol_b]=CostFunction_b(particle(i).Position);
    [Cost_c, Sol_c]=CostFunction_c(particle(i).Position);
    [Cost_n, Sol_n]=CostFunction_n(particle(i).Position);
    particle(i).Cost=Cost_a+Cost_b+Cost_c+Cost_n;
    particle(i).Sol.a=Sol_a;    particle(i).Sol.b=Sol_b;
    particle(i).Sol.c=Sol_c;    particle(i).Sol.n=Sol_n;
    %[particle(i).Cost, particle(i).Sol]=CostFunction(particle(i).Position);
    
    % Update Personal Best
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    particle(i).Best.Sol=particle(i).Sol;
    % Update Global Best
    if particle(i).Best.Cost<BestSol.Cost
        BestSol=particle(i).Best;
    end
end

BestCost=zeros(MaxIt,1);
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% PSO Main Loop
for it=1:MaxIt
    
    for i=1:nPop
        
        % Update Velocity
        particle(i).Velocity = w*particle(i).Velocity ...
        +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
        +c2*rand(VarSize).*(BestSol.Position-particle(i).Position);
        
        % Apply Velocity Limits
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);
        
        % Update Position
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % Velocity Mirror Effect
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);
        
        % Apply Position Limits
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);
        
        % Evaluation
    [Cost_a, Sol_a]=CostFunction_a(particle(i).Position);
    [Cost_b, Sol_b]=CostFunction_b(particle(i).Position);
    [Cost_c, Sol_c]=CostFunction_c(particle(i).Position);
    [Cost_n, Sol_n]=CostFunction_n(particle(i).Position);
    particle(i).Cost=Cost_a+Cost_b+Cost_c+Cost_n;
    particle(i).Sol.a=Sol_a;    particle(i).Sol.b=Sol_b;
    particle(i).Sol.c=Sol_c;    particle(i).Sol.n=Sol_n;
    %[particle(i).Cost, particle(i).Sol]=CostFunction(particle(i).Position);
        
        % Mutation
        for k=1:2
            NewParticle=particle(i);
            NewParticle.Position=Mutate(particle(i).Position, mu);
%xxxxxxxx
    [Cost_a, Sol_a]=CostFunction_a(NewParticle.Position);
    [Cost_b, Sol_b]=CostFunction_b(NewParticle.Position);
    [Cost_c, Sol_c]=CostFunction_c(NewParticle.Position);
    [Cost_n, Sol_n]=CostFunction_n(NewParticle.Position);
    NewParticle.Cost=Cost_a+Cost_b+Cost_c+Cost_n;
    NewParticle.Sol.a=Sol_a;    NewParticle.Sol.b=Sol_b;
    NewParticle.Sol.c=Sol_c;    NewParticle.Sol.n=Sol_n;
%[NewParticle.Cost, NewParticle.Sol]=CostFunction(NewParticle.Position);
%xxxxxxxx
             if NewParticle.Cost<=particle(i).Cost || rand < 0.1
                particle(i)=NewParticle;
            end
        end
        
        % Update Personal Best
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            particle(i).Best.Sol=particle(i).Sol;
            % Update Global Best
            if particle(i).Best.Cost<BestSol.Cost
                BestSol=particle(i).Best;
            end
        end
    end
    
    % Local Search based on Mutation
    for k=1:5
        NewParticle=BestSol;
        NewParticle.Position=Mutate(BestSol.Position, mu);
%xxxxxxxx
    [Cost_a, Sol_a]=CostFunction_a(NewParticle.Position);
    [Cost_b, Sol_b]=CostFunction_b(NewParticle.Position);
    [Cost_c, Sol_c]=CostFunction_c(NewParticle.Position);
    [Cost_n, Sol_n]=CostFunction_n(NewParticle.Position);
    NewParticle.Cost=Cost_a+Cost_b+Cost_c+Cost_n;
    NewParticle.Sol.a=Sol_a;    NewParticle.Sol.b=Sol_b;
    NewParticle.Sol.c=Sol_c;    NewParticle.Sol.n=Sol_n;
%[NewParticle.Cost, NewParticle.Sol]=CostFunction(NewParticle.Position);
%xxxxxxxx

        if NewParticle.Cost<=BestSol.Cost
            BestSol=NewParticle;
        end
    end
    BestCost(it)=BestSol.Cost;
    
    %disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    w=w*wdamp;
    % Plot Best Solution
%    figure(1);
%    PlotSolution(BestSol.Sol,model);
%    pause(0.01);
    
end
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

figure;
plot(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');
%axis([0 200 1e4 3e4])
