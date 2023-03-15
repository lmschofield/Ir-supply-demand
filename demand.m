function k = demand(year,LT2020,LT2050,CF)
%This function is to model the Ir demand for a given year
%%%This function was designed in conjuction with the publication by
%%%Riedmayer, Paren, Schofield, Shao-Horn, and Mallapragada (2023)

%%%Input variables
%year is the year you want the data for
%LT2020 is the lifetime (in hours) in 2020, and LT2050 is the lifetime (in
%hours) in 2050. If there is a difference, the program will change the
%lifetime linearly. 
%CF is the capacity factor (in percent), which is assumed to be 100%, but
%could be changed if the user would like

yearindex=year-2019;

N= 31536000; % number of seconds in a year
M_H2=2.02; %molecular weight of H2, in g/mol
F=96485; %Faraday's constant, in A/mol
mtotal_H2_Elecd(1)= 3E10;    % units are g, total demand H2 demand from electrolysis in 2020
mtotal_H2_Elecd(2)=4.05E10;  % units are g, total demand H2 demand from electrolysis in 2021
mtotal_H2_Elecd(3)=5.1E10;  % units are g, total demand H2 demand from electrolysis in 2022

%IEA H2 inputs-can be used instead of IRENA inputs
%mtotal_H2_Elecd(11)=8.25E13;   % units are g, total demand H2 demand from electrolysis in 2030
%mtotal_H2_Elecd(31)=30E13; % units are g, total demand H2 demand from electrolysis in 2050

%IRENA H2 inputs
mtotal_H2_Elecd(11)=2.5E13;   % units are g, total demand H2 demand from electrolysis in 2030
mtotal_H2_Elecd(31)=16E13; % units are g, total demand H2 demand from electrolysis in 2050

mtotal_H2_PEMd (1)=0; %initalzing, total demand H2 demand from PEM
f_H2_PEMd (1)=0; %initializing, fraction of electrolysis that is PEM

% setting the lifetimes (in years), assuming a capacity factor of 100
LT= zeros(31,1);
LT(1)=LT2020/24/365/(CF/100);
LT(31)=LT2050/24/365/(CF/100);

for i=2:30
    LT(i) = (LT(31)-LT(1))/30*(i-1)+LT(1);
end

% below is setting total electrolysis H2 demand based on values from known years

for i=4:10
    mtotal_H2_Elecd(i)=(mtotal_H2_Elecd(11)-mtotal_H2_Elecd(3))/(11-3)+mtotal_H2_Elecd(i-1);
end

for i=12:30
    mtotal_H2_Elecd(i)=(mtotal_H2_Elecd(31)-mtotal_H2_Elecd(11))/(31-11)+mtotal_H2_Elecd(i-1);
end


% below is computing the total H2 demand from PEM electrolysis
for i=1:31
if i < 7
    f_H2_PEMd (i)=.05*i;     % fraction of 
    mtotal_H2_PEMd (i) = f_H2_PEMd (i)* mtotal_H2_Elecd(i);
    else if i < 12
    f_H2_PEMd (i)=0.3+.02*(i-6);
    mtotal_H2_PEMd (i) = f_H2_PEMd (i)* mtotal_H2_Elecd(i);
    else 
    f_H2_PEMd (i)=0.4;
    mtotal_H2_PEMd (i) = f_H2_PEMd (i)* mtotal_H2_Elecd(i);
    end
end
end 
%below is computing the annual mass H2 added from new PEM electrolysis

for i=1:31
    if i == 1
        m_annual_H2_PEMd=mtotal_H2_PEMd(1);
    else 
    m_annual_H2_PEMd(i)=mtotal_H2_PEMd(i)-mtotal_H2_PEMd(i-1);
    end
end

% calculating annual area added for different current densities, where i is
% the index of year and p is the index of current density

j(1)=1.5;
j(2)=2;
j(3)=3;
j(4)=4;
j(5)=5;
j(6)=6;

%creating catalyst loading, in g/cm2
for i=1:17
    L_ir(i)=0.1+i*0.1;
end

% initialzing annual area added , i is the index, where the year is i+2020, 
%                           % j is the current density
 
A_annual_PEM_new= zeros (length(m_annual_H2_PEMd), length(j));

%% assigning A_annual_PEM_new for given current densities and years
for i=1:31
    for p=1:6
        A_annual_PEM_new(i,p)= m_annual_H2_PEMd(i)*2*F/(M_H2*N*j(p));
    end
end

%% initiallizing annual area from replacement
A_annual_PEM_repl= zeros (length(m_annual_H2_PEMd)+2, length(j));


%% initializing total annual area added, and creating below
A_annual_PEM_added= zeros (length(m_annual_H2_PEMd), length(j));
for i=1:31
    for p=1:6
        A_annual_PEM_added(i,p)=A_annual_PEM_new(i,p)+A_annual_PEM_repl(i,p);
        if 2<i
            if i+round(LT(i))<34  
     %this does not do any average
             A_annual_PEM_repl(i+round(LT(i)),p)=(A_annual_PEM_added(i,p)+A_annual_PEM_repl(i+round(LT(i)),p));
            end

%       if p==1
%            A_annual_PEM_repl (i,p);
%       end
       end
    end
  
end


%%%this is to initiallize the total iridium demand for a given area,
%%%current density, and cathode loading (calculated below), units are in
%%%metric tons per year
m_Ir_PEMd=zeros(length(m_annual_H2_PEMd), length(j), length(L_ir));

for i=1:31
    for p=1:6
        for q=1:17
           m_Ir_PEMd(i,p,q)=A_annual_PEM_added(i,p)*L_ir(q) / 10^9;   %m in metric tons per year
        end
    end
end


 %yearmatrix is the output of the script, which is a table consisting of
 %the correct m_Ir_PEMd for a given year, dependent on current density and cathode loading  
yearmatrix=zeros(length(j), length(L_ir));


for p=1:6
        for q=1:17
            yearmatrix(p,q)=m_Ir_PEMd(yearindex,p,q);
        end
end

%%%-------------------
%The following section linearizes the replacement rate to reflect more
%realistic conditions, because things may not actually be replaced in
%discrete time steps
%%%%---------------

%%%total PEM replacement
PEM_repl_total=zeros(length(j));
count=0;
%%%replacing starts at 2029, if 65000 is the initial hours in 2020, so 22
%%%total years, starting with 2029 (i=10)
for i=1:22
    count=i+count;   %%%%count is the number of PEM repl sections corresponding to each year, increasing linearly
end

PEM_repl_section_averaged=zeros(length(j));

for p=1:6
    for i=1:22
        PEM_repl_total(p)=PEM_repl_total(p)+A_annual_PEM_repl(i+9,p);
    end
    PEM_repl_section_averaged(p)=PEM_repl_total(p)/count;
end

A_annual_PEM_added_average= zeros (length(m_annual_H2_PEMd), length(j));
A_annual_PEM_repl_average= zeros (length(m_annual_H2_PEMd), length(j));

for i=1:31
    
    for p=1:6
        if i<10
        A_annual_PEM_added_average(i,p)=A_annual_PEM_added(i,p);
        end

        if i>9
         A_annual_PEM_repl_average(i,p)=PEM_repl_section_averaged(p)*(i-9);
         A_annual_PEM_added_average(i,p)=A_annual_PEM_new(i,p)+A_annual_PEM_repl_average(i,p);
        end
        
    end
end


m_Ir_PEMd_repllinear=zeros(length(m_annual_H2_PEMd), length(j), length(L_ir));

for i=1:31
    for p=1:6
        for q=1:17
           m_Ir_PEMd_repllinear(i,p,q)=A_annual_PEM_added_average(i,p)*L_ir(q) / 10^9;   %m in metric tons per year
          
        end
    end
end

%below is the year matrix with linearized replacement area
yearmatrix_repllinear=zeros(length(j), length(L_ir));

for p=1:6
        for q=1:17
            yearmatrix_repllinear(p,q)=m_Ir_PEMd_repllinear(yearindex,p,q);
        end
end

 %yearmatrix is the output of the script, which is a table consisting of
 %the correct m_Ir_PEMd for a given year, dependent on current density and
 %cathode loading in this case we are using the year matrix that includes
 %the linearized replacement rate
save ('yearmatrix_repllinear.mat','yearmatrix_repllinear');

%%%below are additional variables that can be saved as outputs
% save ('m_annual_H2_PEMd.mat','m_annual_H2_PEMd')
% save ('mtotal_H2_Elecd.mat','mtotal_H2_Elecd');
% save ('f_H2_PEMd.mat','f_H2_PEMd');
% save ('mtotal_H2_PEMd.mat','mtotal_H2_PEMd');
% save ('yearmatrix.mat','yearmatrix');
% save('A_annual_PEM_repl.mat', 'A_annual_PEM_repl');
% save('A_annual_PEM_new.mat', 'A_annual_PEM_new');
% save('A_annual_PEM_added.mat', 'A_annual_PEM_added');
% save('A_annual_PEM_repl_average.mat', 'A_annual_PEM_repl_average');
% save('A_annual_PEM_added_average.mat', 'A_annual_PEM_added_average');
%%%

end