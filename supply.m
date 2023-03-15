function k = supply(r, rr, LT2020,LT2050,CF)
%This function is to model the Ir supply for a given year
%%%This function was designed in conjuction with the publication by
%%%Riedmayer, Paren, Schofield, Shao-Horn, and Mallapragada (2023)

%%%Input variables
%r=growth rate
%rr=replacement rate
%LT2020 is the lifetime (in hours) in 2020, and LT2050 is the lifetime (in
%hours) in 2050. If there is a difference, the program will change the
%lifetime linearly. 
%CF is the capacity factor (in percent), which is assumed to be 100%, but
%could be changed if the user would like

% setting the lifetimes (in years)
LT= zeros(31,1);
LT(1)=LT2020/24/365/(CF/100);
LT(31)=LT2050/24/365/(CF/100);

for i=2:30
    LT(i) = (LT(31)-LT(1))/30*(i-1)+LT(1);
end

%%total Ir produced annually, in metric tons;
m_Ir_prod = zeros(31,1);

%%annual new Ir produced for PEM application, in metric tons
m_Ir_PEM_new = zeros(31,1);

%fraction of produced Ir used for electrochemical applications
f_Ir_EChem= zeros(31,1);

%fraction of produced Ir for electrochemical application used for PEM
f_Ir_EChem_PEM= zeros(31,1);

%setting initial values
m_Ir_prod (1)=6.7;   %total Ir produced annually (metric tons) in 2020
m_Ir_prod (2)=7.2;   %total Ir produced annually (metric tons) in 2021
m_Ir_prod (3)=7.8;   %total Ir produced annually (metric tons) in 2022


%total Ir produced annually (metric tons) after 2022, using growth rate of
%r (set in intial variables)
for i=4:31
   m_Ir_prod (i)= (1+r)*m_Ir_prod(i-1);
end

f_Ir_EChem(1)=0.388; %f_Ir_EChem for 2020
f_Ir_EChem(2)=0.388; %f_Ir_EChem for 2021
f_Ir_EChem(3)=0.388; %f_Ir_EChem for 2022
f_Ir_EChem(11)=0.45; %f_Ir_EChem for 2030
f_Ir_EChem(31)=0.593; %f_Ir_EChem for 2050

%annual fraction of produced Ir used for electrochemical applications,
%increasing linearly between set values from 2022 to 2030, and 2030 to 2050

for i=4:10
    f_Ir_EChem(i)=(f_Ir_EChem(11)-f_Ir_EChem(3))/(11-3)+f_Ir_EChem(i-1);
end

for i=12:30
    f_Ir_EChem(i)=(f_Ir_EChem(31)-f_Ir_EChem(11))/(31-11)+f_Ir_EChem(i-1);
end

%fraction of produced Ir for electrochemical application used for PEM
%increasing linearly between set values from 2021 to 2035, and 2035 to 2050

f_Ir_EChem_PEM(1)=0.0041; %f_Ir_EChem_PEM for 2020
f_Ir_EChem_PEM(2)=0.0108; %f_Ir_EChem_PEM for 2021
f_Ir_EChem_PEM(16)=0.4; %f_Ir_EChem_PEM for 2035
f_Ir_EChem_PEM(31)=0.6; %f_Ir_EChem_PEM for 2050

for i=3:15
    f_Ir_EChem_PEM(i)=(f_Ir_EChem_PEM(16)-f_Ir_EChem_PEM(2))/(16-2)+f_Ir_EChem_PEM(i-1);
end

for i=17:30
    f_Ir_EChem_PEM(i)=(f_Ir_EChem_PEM(31)-f_Ir_EChem_PEM(16))/(31-16)+f_Ir_EChem_PEM(i-1);
end


for i=2:31
   m_Ir_PEM_new (i) = m_Ir_prod (i)*f_Ir_EChem(i)*f_Ir_EChem_PEM(i);
end


%% initiallizing annual Ir from replacement
m_Ir_PEM_repl= zeros (31,1);

% %% initializing total annual added m Ir for PEM, (main output of the
% script) and creating below, which is the total annual Ir demand

m_Ir_PEM_added= zeros (31,1);

for i=1:31
         m_Ir_PEM_added(i)=m_Ir_PEM_new(i)+m_Ir_PEM_repl(i);
        if 2<i
            if i+round(LT(i))<32  
              m_Ir_PEM_repl(i+round(LT(i)))=rr*(m_Ir_PEM_added(i)+m_Ir_PEM_repl(i+round(LT(i))));             
            end
        end   
end

%%%-------------------
%The following section linearizes the replacement rate to reflect more
%realistic conditions, because things may not actually be replaced in
%discrete time steps
%%%%---------------

%%%total Ir replacement
Ir_repl_total=0;
count=0;
% %%%replacing starts at 2029, if 65000 is the initial hours in 2020, so 22
% %%%total years, starting with 2029 (i=10)
for i=1:22
     count=i+count;   %%%%count is the number of PEM repl sections corresponding to each year, increasing linearly
end
 
Ir_repl_section_averaged = 0;

    for i=1:22
        Ir_repl_total = Ir_repl_total+m_Ir_PEM_repl(i+9);
     end
Ir_repl_section_averaged =Ir_repl_total/count;

% 
m_Ir_PEM_repl_average = zeros (31,1);
m_Ir_PEM_added_average = zeros (31,1);
% 
for i=1:31

        if i<10
         m_Ir_PEM_added_average(i)=m_Ir_PEM_added(i);
         end
 
         if i>9
          m_Ir_PEM_repl_average(i)=Ir_repl_section_averaged*(i-9);
          m_Ir_PEM_added_average(i)=m_Ir_PEM_new(i)+m_Ir_PEM_repl_average(i);
         end         
end

%%%m_m_Ir_PEM_added_average is the main output from the script, which is
%%%the total annual Ir demand, with the replacement/recycling linearized as
%%%discussed above

save('m_Ir_PEM_added_average.mat', 'm_Ir_PEM_added_average');

% %%%below are additional variables that can be saved as outputs
% save('f_Ir_EChem.mat', 'f_Ir_EChem');
% save('f_Ir_EChem_PEM.mat', 'f_Ir_EChem_PEM');
% save('LT.mat', 'LT');
% save('m_Ir_PEM_new.mat', 'm_Ir_PEM_new');
% save('m_Ir_prod.mat', 'm_Ir_prod');
% save('m_Ir_PEM_repl.mat', 'm_Ir_PEM_repl');
% save('m_Ir_PEM_added.mat', 'm_Ir_PEM_added');
% save('m_Ir_PEM_repl_average.mat', 'm_Ir_PEM_repl_average');
%%%

end