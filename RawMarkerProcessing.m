%% Clean House

clc
clearvars
close all

%% Read in static data
    % uiget (give the user control)
[filename,pathname] = uigetfile('C:\Users\Kip\Documents\MATLAB\KNS 541\FinalProject\*Static*',...
    'Open static file','Multiselect','off');

%check if user presses cancel when selecting a static trial
if isequal(filename,0)
    uiwait(warndlg('Static file not selected! Click OK to continue.','Warning!'));
    return
else
    MarkerPosition = dlmread([pathname,filename],',',5,0);
end
%% Index one time point 
% Indexing from second 1 to second 2 to and then taking the average of each
% column to get an average XYZ coordinate for every marker

% creates a time frame from 1/200 to the length of the data
Time = [1/200:1/200:(length(MarkerPosition)*1/200)]'; 

% Finds when the second reaches 1 and starts at the next frame
t1 = find(Time==1)+1;

% Finds when time exceeds 2 seconds and subtracts a frame
t2 = find(Time>2,1,'first')-1;

% Use time frames as a reference for the MarkerPositionsbetween 1 and 2
% seconds
StaticAverage = mean(MarkerPosition(t1:t2,:));

clear t1 t2

%% Create segment anatomical coordinate systems (ACS)
    % gTa   global To anatomical
    
[PelvisACS_S,ThighACS_S,ShankACS_S,FootACS_S] = Handwerker_ACS(StaticAverage);

%% Create segment technical coordinate systems (TCS)
    % gTm   global To marker
    
[PelvisTCS_S,ThighTCS_S,ShankTCS_S,FootTCS_S] = Handwerker_TCS(StaticAverage);

%% Calculate transformation matric from TCS to ACS
    % mTa   marker to anatomical
    
    % mTa = (gTm)^-1 * gTa;
    % mTa = gTm' * gTa;
    % mTa = inv(gTm) * gTa;
    % mTa = gTm\gTa; 
    
% Pelvis
Pelvis_mTa = PelvisTCS_S \ PelvisACS_S;
% Thigh
Thigh_mTa = ThighTCS_S \ ThighACS_S;
% Shank
Shank_mTa = ShankTCS_S \ ShankACS_S;
% Foot
Foot_mTa = FootTCS_S \ FootACS_S;
    
% Finished with static 

%% Read in dynamic data file    
% uiget (give the user control)
[filenameD,pathnameD] = uigetfile('C:\Users\Kip\Documents\MATLAB\KNS 541\FinalProject\S*',...
    'Open dynamic file','Multiselect','on');

%check if user presses cancel on the dialog
if isequal(filenameD,0)
    uiwait(warndlg('Dynamic file not selected! Click OK to continue.','Warning!'));
    return
else
    DMP = dlmread([pathnameD,filenameD],',',5,0);
end

%% Filter marker coorinate data
% Gives the user the option to run a residual analysis
YesNo = {'Yes','No'};
[Res,TF] = listdlg('PromptString','Do you want to run a residual analysis?',...
                   'Name','Residual Analysis',...
                   'SelectionMode','single',...
                   'ListSize',[240 80],...
                   'OkString','Find residual',...
                   'CancelString','Cancel',...
                   'ListString',YesNo);
% If the user presses no or cancels then the program will display a message                
if isequal(TF,0) || isequal(Res,2)
    uiwait(msgbox('You opted out of running a residual analysis. Click OK to continue.'));
% Otherwise the program will run a residual analysis and display the value
% to the user
else 
    for i = 3:size(DMP,2)
        [RA(i)] = residual(DMP(:,i),200,0);
    end
    RA = round(mean(RA));
%     uiwait(msgbox(sprintf('The residual analysis is %.0f',RA)));
    maxRA = max(RA(1,:));
    minRA = min(RA(1,:));
    uRA = round(mean(RA));
    lRA = floor(mean(RA));
    
    if maxRA == minRA
%   If max RA is the same as the min RA then the value of the RA is the
%   same and therefore only one value is needed and will be displayed.
        uiwait(msgbox(sprintf('The residual analysis is %.0f',RA)));
    else
%   If the values happen to be different then the value of the max and min
%   RA will be displayed as well as an average of the two with high and low
%   rounded values of the mean as well.
        uiwait(msgbox(sprintf('Here are the outputs for the Residual Analysis\nMax RA = %2.3g\nMin RA = %2.3g\nMean RA = %2.3g/%2.3g',maxRA,minRA,uRA,lRA)))
    end
end

% Picking a cutoff frequency 
CoF = {'2','4','6','8','10'};
          [sel,v] = listdlg('PromptString','Pick a cut-off frequency',...
                            'Name','Cut Off Frequency',...
                            'SelectionMode','single',...
                            'ListSize',[240 80],...
                            'OkString','Continue',...
                            'ListString',CoF);
if isequal(v,0)                        
    uiwait(msgbox('You did not pick a cut-off frequency. The program will not run at the end!,Warning')) 
end
% The values of [sel*] are different than the what is going to be put into
% the function so these if statements change the values to the actual value
% selected. I am sure there is a way easier way to do this.
if sel == 1
    sel = 2;
elseif sel == 2
    sel = 4;
elseif sel == 3
    sel = 6;
elseif sel == 4
    sel = 8;
elseif sel == 5
    sel = 10;
end

FT = {'low','high (Not Recommended)','stop (Not Recommended)'};
          [sel1,vv] = listdlg('PromptString','Pick your filter type',...
                            'Name','Filter Type',...
                            'SelectionMode','single',...
                            'ListSize',[240 80],...
                            'OkString','Continue',...
                            'ListString',FT);
if isequal(vv,0)
    uiwait(msgbox('You did not pick an order. The program will not run at the end!,Warning'))
end                        
% The input for sel1 needs to be in a string for the function so this 
% converts it to a string                        
sel1 = char(FT{sel1}); 

% Picking the order for the filter
Order = {'2','4'};
          [sel2,vvv] = listdlg('PromptString','Pick your filter order',...
                            'Name','Filter Order',...
                            'SelectionMode','single',...
                            'ListSize',[240 80],...
                            'OkString','Run',...
                            'ListString',Order);
if isequal(vvv,0)                        
    uiwait(msgbox('You did not pick a filter order. The program will not run at the end!,Warning')) 
end
% The values of [sel*] are different than the what is going to be put into
% the function so these if statements change the values to the actual value
% selected. I am sure there is a way easier way to do this.
if sel2 == 1                       
    sel2 = 2;
elseif sel2 == 3
    sel2 = 4;
end


% if the user presses cancel on any of the following it will not run the
% program
if isequal(v,0)
    uiwait(warndlg('Cut off frequency not selected! Click OK and start over.','Warning!'));
    return
elseif isequal(vv,0)
    uiwait(warndlg('Filter type not selected! Click OK and start over.','Warning!'));
    return
elseif isequal(vvv,0)
    uiwait(warndlg('Filter order not selected! Click OK and start over.','Warning!'));
    return
else
    Filter_DMP = bw_filter(DMP,200,sel,sel1,sel2);
end  

clear v vv vvv sel sel1 sel2 CoF FT Order Res TF YesNo m i lRA maxRA minRA RA uRA



%% For frame 1:length(motion data)
    % Create TCS
        % gTm

for i = 1:length(Filter_DMP)
    [PelvisTCS_D,ThighTCS_D,ShankTCS_D,FootTCS_D] = Handwerker_TCS(Filter_DMP(i,:));

    % Calculate ACS
        % (gTa = gTm * mTa)
        %       dynamic * static
    Pelvis_GTA(:,:,i) = PelvisTCS_D * Pelvis_mTa;
    Thigh_GTA(:,:,i) = ThighTCS_D * Thigh_mTa;
    Shank_GTA(:,:,i) = ShankTCS_D * Shank_mTa;
    Foot_GTA(:,:,i) = FootTCS_D * Foot_mTa;

    % Calculate JCS    
        % a(proximal) T a(distal) = (gTa of proximal)^-1 * (gTa of distal)
    Hip_JCS(:,:,i) = (Pelvis_GTA(:,:,i)) \ Thigh_GTA(:,:,i);
    Knee_JCS(:,:,i) = (Thigh_GTA(:,:,i)) \ Shank_GTA(:,:,i);
    Ankle_JCS(:,:,i) = (Shank_GTA(:,:,i)) \ Foot_GTA(:,:,i);

    % XYZ Euler angle decomposition
    HipXYZ = rad2deg(rotm2eul(Hip_JCS(:,:,i),'XYZ'));  
    KneeXYZ = rad2deg(rotm2eul(Knee_JCS(:,:,i),'XYZ'));  
    AnkleXYZ = rad2deg(rotm2eul(Ankle_JCS(:,:,i),'XYZ'));

vec(i,:) = [HipXYZ KneeXYZ AnkleXYZ];


clear HipXYZ KneeXYZ AnkleXYZ
clear PelvisTCS_D ThighTCS_D ShankTCS_D FootTCS_D
end   
%% Create a 3x3 publication quality figure  

f1 = figure;
f1.NumberTitle = 'off';
f1.Name = 'Joint Angles';
f1.Units = 'inches';
f1.Color = [1 1 1];
f1.Position = [1 1 8 6];

subplot(3,3,1)
plot(vec(:,1),'r',...
     'LineWidth',1)
title('Sagittal (X)','FontSize',10,'FontWeight','bold')
ylabel('Hip Angle','FontSize',12,'FontWeight','bold')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,2)
plot(vec(:,2),'r',...
     'LineWidth',1)
title('Frontal (Y)','FontSize',10,'FontWeight','bold')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,3)
plot(vec(:,3),'r',...
     'LineWidth',1)
title('Transverse (Z)','FontSize',10,'FontWeight','bold')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,4)
plot(vec(:,4),'g',...
     'LineWidth',1)
ylabel('Knee Angle','FontSize',12,'FontWeight','bold')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,5)
plot(vec(:,5),'g',...
     'LineWidth',1)
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,6)
plot(vec(:,6),'g',...
     'LineWidth',1)
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,7)
plot(vec(:,7),'b',...
     'LineWidth',1)
xlabel('Frames (#)')
ylabel('Ankle Angle','FontSize',12,'FontWeight','bold')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,8)
plot(vec(:,8),'b',...
     'LineWidth',1)
xlabel('Frames (#)')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off

subplot(3,3,9)
plot(vec(:,9),'b',...
     'LineWidth',1)
xlabel('Frames (#)')
set(gca,'XTickLabel',{'0','200','400','600'},...
        'XTick',[0:200:600])
xlim([0 600])
box off
%% Sort

% the 'a' infront is simply to keep the outputs at the top of the list in
% the workspace to make it easier to find

aACS_Static_St = struct('PelvisACS_S',(PelvisACS_S),'ThighACS_S',(ThighACS_S),...
                     'ShankACS_S',(ShankACS_S),'FootACS_S',(FootACS_S));
clear PelvisACS_S ThighACS_S ShankACS_S FootACS_S

aTCS_Static_St = struct('PelvisTCS_S',(PelvisTCS_S),'ThighTCS_S',(ThighTCS_S),...
                       'ShankTCS_S',(ShankTCS_S),'FootTCS_S',(FootTCS_S));
clear PelvisTCS_S ThighTCS_S ShankTCS_S FootTCS_S

amTa_St = struct('Pelvis_mTa',(Pelvis_mTa), 'Thigh_mTa',(Thigh_mTa),...
                'Shank_mTa',(Shank_mTa),'Foot_mTa',(Foot_mTa)); 
clear Pelvis_mTa Thigh_mTa Shank_mTa Foot_mTa i      
        
aGTA_St = struct('Pelvis_GTA',(Pelvis_GTA),'Thigh_GTA',(Thigh_GTA),...
                 'Shank_GTA',(Shank_GTA),'Foot_GTA',(Foot_GTA));
clear Pelvis_GTA Thigh_GTA Shank_GTA Foot_GTA

aJCS_St = struct('Hip_JCS',(Hip_JCS),'Knee_JCS',(Knee_JCS),'Ankle_JCS',(Ankle_JCS));
clear Hip_JCS Knee_JCS Ankle_JCS






