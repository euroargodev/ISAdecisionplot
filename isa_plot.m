function isa_plot(PRES,TEMP,ISICE,pres_int,n_t_med,t_ice)
% INPUTS
% PRES and TEMP are the pressure and the temperature matrices (format as in
% the CTD reference database for Argo Salinity DMQC)
% ISICE is a vector [1 x Nprofiles] with 0 for open water and 1 for ice

% PRES_INT: Pressure intervals: size = [nprofiles x 2]
% First column upper limit, second column lower limit.
% pres_int=[5 15;10 20;15 25; 20 30;10 30;20 40];

% T_ICE: [1 x n] Temperature thresholds to be evaluated
% t_ice=-2:0.1:0;

% N_T_MED: minimum number of temperature points for the calculation T_med
% n_t_med=3;

nt_ice=numel(t_ice);% number of threshold to evaluate
npres=size(pres_int,1); % number of pressure ranges to evaluate
N=size(PRES,2); % number of profiles

%% Calculate T_med
% Calculate median temperature (T_med) for each pressure range and profile
% preallocate output
T_med=nan(npres,N);
T_med_n=nan(npres,N);
for j=1:npres
    for i=1:N
        % select samples in pressure range
        q=PRES(:,i);
        f=find(q>=pres_int(j,1)&q<=pres_int(j,2));
        clear q
        % calculate T_med
        T_med(j,i)=median(TEMP(f,i),'omitnan');
        T_med_n(j,i)=sum(isfinite(TEMP(f,i)));
        clear f
    end
end

% Remove median values calculated with less than 3 values
T(T_med_n<n_t_med)=NaN;
% number of valid profiles in each pressure interval
TN=sum(isfinite(T),2);

%% for each T_med and pressure range evaluate ISA decision
% ISA decision (isa_des) for each pressure range and profile
isa_des=nan(npres,nt_ice,N);
for j=1:npres
    for i=1:nt_ice
        f=find(T_med(j,:)<t_ice(i));
        isa_des(j,i,f)=1;
        f=find(T_med(j,:)>=t_ice(i));
        isa_des(j,i,f)=0;
        clear f
    end
end

% select profiles
fopen=find(ISICE==0);% Open Water
fice=find(ISICE==1);% ice

for j=1:npres
    for i=1:nt_ice
        % find open water with valid outputs
        fopen_sel=intersect(fopen,find(isfinite(isa_des(j,i,:))));
        % find ice with valid outputs
        fice_sel=intersect(fice,find(isfinite(isa_des(j,i,:))));
        % eval results: 1 right -1 wrong
        des=squeeze(isa_des(j,i,:));
        
        f_correct_open{j,i}= intersect(fopen_sel,find(des==0)); %#ok<*AGROW>
        f_incorrect_open{j,i}= intersect(fopen_sel,find(des==1));
        
        f_correct_ice{j,i}= intersect(fice_sel,find(des==1));
        f_incorrect_ice{j,i}= intersect(fice_sel,find(des==0));
        
        
        isa_eval_open{j}(i,:)=[numel(f_correct_open{j,i}) numel(f_incorrect_open{j,i})];
        isa_eval_ice{j}(i,:)=[numel(f_correct_ice{j,i}) numel(f_incorrect_ice{j,i})];
        
        isa_eval_open_perc{j}(i,:)= 100*isa_eval_open{j}(i,:)./sum(isa_eval_open{j}(i,:));
        isa_eval_ice_perc{j}(i,:)=100*isa_eval_ice{j}(i,:)./sum(isa_eval_ice{j}(i,:));
    end
end
%% Plot
% pressure
lin={'-','--',':','-.'};
% results
tmp = lines(5);
cmap=tmp([1 2 5 3],:);

figure('color','w','units','normalized','position',[0.1 0.1 0.6 0.8]);
for j=1:npres % plot each pressure range
    tmp=[isa_eval_ice_perc{j} isa_eval_open_perc{j}];
    % for the legend
    presranges(j,1)=plot(t_ice,tmp(:,1),'LineWidth',2,'LineStyle',lin{j},'color','k');hold on
    
    if j==1
        results=plot(t_ice,tmp,'LineWidth',2,'LineStyle',lin{j});
        for i=1:4
            results(i,1).Color=cmap(i,:);
        end
    end
    
    % for the plot
    h=plot(t_ice,tmp,'LineWidth',2,'LineStyle',lin{j});
    % assign color
    for i=1:4
        h(i).Color=cmap(i,:);
    end
end
xlabel('ISA threshold [°C]')
ylabel('Probability [%]')
grid on
grid minor

leg=[presranges; results];

%%
for j=1:npres % plot each pressure range
    pres_leg{j,1}=[num2str(pres_int(j,1)) ' - ' num2str(pres_int(j,2))];
end
% res legend
res_leg{1,1}='Sea ice present - ISA detects ice - Correct Output';
res_leg{2,1}='Sea ice present - ISA does not detect ice - Incorrect Output (damage risk)';
res_leg{3,1}='Open water - ISA does not detect ice - Correct Output';
res_leg{4,1}='Open water - ISA detects ice - Incorrect Output (miss surfacing)';

legtext=[pres_leg;res_leg];
legend(leg,legtext,'Location','NorthOutside')
