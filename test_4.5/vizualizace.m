%% Příprava dat pro vizualizaci
% soubor s modely
% data = sim('simulink_rizeni_bez_a_s_zavazim.slx');
data = out; % tento prikaz, pokud Simulink soubor byl spusten uvnitr rucne


video = false;
name = "simulace4"; %!!! jmeno video souboru !!!

t = data.tout;
%%
% Bez zavazi
x_bez = data.Bez_zavazi.signals(1).values;
y_bez = data.Bez_zavazi.signals(2).values;
fi_bez = data.Bez_zavazi.signals(3).values; %[deg]
%alfa_t = data.ScopeData.signals(4).values; %[deg]
F1_bez = data.F1_F2.signals(1).values(:,1);
F2_bez = data.F1_F2.signals(1).values(:,2);

% Se zavazim
x_se = data.Se_zavazim.signals(1).values;
y_se = data.Se_zavazim.signals(2).values;
fi_se = data.Se_zavazim.signals(3).values; %[deg]
alfa_se = data.Se_zavazim.signals(4).values; %[deg]
F1_se = data.F1_F2.signals(2).values(:,1);
F2_se = data.F1_F2.signals(2).values(:,2);

% Referenci poloha
x_desired = data.x_y_fi_desired.signals(1).values(:,1);
y_desired = data.x_y_fi_desired.signals(1).values(:,2);
fi_desired = data.x_y_fi_desired.signals(1).values(:,3);
%% Grafy a Vizualizace
close all
screen=get(0,'ScreenSize');

% if true
%     h=figure;
%     %set(h,'Position',[5 10 0.99*s(3) 0.9*s(4)],'color',[1 1 1])
%     set(h,'Name', 'Grafy', 'Color',[1 1 1])
% 
% 
%     subplot(4, 1, 1); 
%     grid on 
%     xlabel('t [s]') 
%     ylabel('x [m]')
%     set(gca,'Ylim',[min(x_t) max(x_t)]) 
%     title('X poloha kvadrokoptery')
% 
%     subplot(4, 1, 2)
%     grid on
%     xlabel('t [s]') 
%     ylabel('y [m]')
%     set(gca,'Ylim',[min(y_t) max(y_t)]) 
%     title('Y poloha kvadrokoptery')
% 
%     subplot(4, 1, 3)
%     grid on
%     xlabel('t [s]') 
%     ylabel('fi [deg]')
%     set(gca,'Ylim',[min(fi_t) max(fi_t)]) 
%     title('Otoceni kvadrokoptery')
% 
%     subplot(4, 1, 4)
%     grid on
%     xlabel('t [s]') 
%     ylabel('alfa [deg]')
%     set(gca,'Ylim',[min(alfa_t) max(alfa_t)]) 
%     title('Vychyleni zavazi')
% end

viz=figure;
set(viz, 'Name', 'Vizualizace', 'Position',[5 10 0.99*screen(3) 0.9*screen(4)], 'Color',[1 1 1])


s1 = subplot(4, 2, 1);
hold on
grid on
ylabel('x(t)','FontSize', 18)
title('X pozice kvadrokoptér (zlutý = bez zavází | zelený = se zavázím)', 'FontSize', 16);
set(gca,'Ylim',[min(x_se) max(x_se)]*1.1)
set(gca,'Xlim', [min(t) max(t)])

s2 = subplot(4, 2, 3);
hold on
grid on
ylabel('y(t)','FontSize', 18)
title('Y pozice kvadrokoptér', 'FontSize', 16);
set(gca,'Ylim',[min(y_se) max(y_se)]*1.1)
set(gca,'Xlim', [min(t) max(t)])

s3 = subplot(4, 2, 5);
hold on
grid on
ylabel('fi(t)','FontSize', 18)
title('Orientace kvadrokoptér [deg]', 'FontSize', 16);
set(gca,'Ylim',[min(fi_se) max(fi_se)]*1.1)
set(gca,'Xlim', [min(t) max(t)])

s4 = subplot(4, 2, 7);
hold on
grid on
ylabel('alfa(t)','FontSize', 18)
title('Úhel vychýlení zátěže [deg]', 'FontSize', 16);
set(gca,'Ylim',[min(alfa_se) max(alfa_se)]*1.1)
set(gca,'Xlim', [min(t) max(t)])

% %h1=subplot('position',[0 0.06 1 0.30]);
% axis([-1 1 -10 10])
% hold on
% axis equal
% %axis('auto');
% grid on

s5 = subplot(1, 2, 2);
title('Vizualizace porovnání řízení', FontSize=16);
axis([-1 1 -10 10])
hold on
axis equal
%axis('auto');
grid on

xlabel('x [m]', FontSize=18)
ylabel('y [m]', FontSize=18)

% Kvadrokoptera se zavazim
Quadrocopter_se_obj=fill([-L*10 L*10],[0 0],[0.9 0.9 0.9],'linewidth',2);
txt_se = text(0, 0, 'Se', 'HorizontalAlignment', 'center', 'FontSize', 14);
F1_se_obj=quiver(L*10,0,0,F1_se(1),'color',[1 0 0],'linewidth',2); %sila zprava
F2_se_obj=quiver(-L*10,0,0,F2_se(1),'color',[0 0 1],'linewidth',2); %sila zleva
% Zavazi
lano=plot([0 0],[0 -d*10],'k','linewidth',2, Color=[139,69,19]./255);
cirp=plot(0,-d*10,'ko','MarkerSize',10,'linewidth',2,'MarkerFaceColor',[0 1 0]);

% Kvadrokoptera bez zavazi
Quadrocopter_bez_obj=fill([-L*10 L*10],[0 0],[0.9 0.9 0.9],'linewidth',2);
F1_bez_obj=quiver(L*10,0,0,F1_bez(1),'color',[1 0 0],'linewidth',2); %sila zprava
F2_bez_obj=quiver(-L*10,0,0,F2_bez(1),'color',[0 0 1],'linewidth',2); %sila zleva
txt_bez = text(0, 0, 'Bez', 'HorizontalAlignment', 'center', 'FontSize', 14);

hold off

%% Vypocet FPS video
interval=60; %FPS vizualizace (nebereme vsechne body z Simulink)

cas_video = 40; % [s]
%length(t)/interval/FrameRate=cas_video

if video
vidObj = VideoWriter(name, 'MPEG-4');
vidObj.FrameRate = round(length(t)/interval/cas_video);
open(vidObj);
end


for j=1:interval:length(t)

    disp("Cas: "+num2str(t(j))+" s")

    %==========================Se zavazim==================================
    x_se_j=x_se(j);
    y_se_j=y_se(j);
    fi_se_j=fi_se(j); 
    alfa_se_j=alfa_se(j);

    %[new_x; new_y]=R*[inicial_x; inicial_y] + [x(t); y(t)]
    left_side_se=[cosd(fi_se_j) -sind(fi_se_j); sind(fi_se_j) cosd(fi_se_j)]*[-L*10; 0] + [x_se_j; y_se_j]; 
    right_side_se=[cosd(fi_se_j) -sind(fi_se_j); sind(fi_se_j) cosd(fi_se_j)]*[L*10; 0] + [x_se_j; y_se_j];

    set(Quadrocopter_se_obj,'Xdata',[left_side_se(1) right_side_se(1)],'Ydata',[left_side_se(2) right_side_se(2)]);
    txt_se.Position = [x_se_j, y_se_j+0.3];
    %kontrola ze vzdalenost mezi krajnimi body kvadrokoptery se rovna 2*L
    %disp( sqrt( (left_side(1)-right_side(1))^2 + (left_side(2)-right_side(2)^2) ) )

    set(F1_se_obj, 'Xdata', right_side_se(1), 'Ydata', right_side_se(2), 'Vdata', F1_se(j))
    set(F2_se_obj, 'Xdata', left_side_se(1), 'Ydata', left_side_se(2), 'Vdata', F2_se(j))

    x_pendulum = x_se_j + d*10*sind(alfa_se_j);
    y_pendulum = y_se_j - d*10*cosd(alfa_se_j);
    set(lano, 'Xdata', [x_se_j, x_pendulum], 'Ydata', [y_se_j, y_pendulum])
    set(cirp, 'XData', x_pendulum, 'YData', y_pendulum)

    %==========================Bez zavazi==================================
    x_bez_j=x_bez(j);
    y_bez_j=y_bez(j);
    fi_bez_j=fi_bez(j); 
    
    left_side_bez=[cosd(fi_bez_j) -sind(fi_bez_j); sind(fi_bez_j) cosd(fi_bez_j)]*[-L*10; 0] + [x_bez_j; y_bez_j]; 
    right_side_bez=[cosd(fi_bez_j) -sind(fi_bez_j); sind(fi_bez_j) cosd(fi_bez_j)]*[L*10; 0] + [x_bez_j; y_bez_j];

    set(Quadrocopter_bez_obj,'Xdata',[left_side_bez(1) right_side_bez(1)],'Ydata',[left_side_bez(2) right_side_bez(2)]);
    txt_bez.Position = [x_bez_j, y_bez_j+0.3];
    %kontrola ze vzdalenost mezi krajnimi body kvadrokoptery se rovna 2*L
    %disp( sqrt( (left_side(1)-right_side(1))^2 + (left_side(2)-right_side(2)^2) ) )
    
    set(F1_bez_obj, 'Xdata', right_side_bez(1), 'Ydata', right_side_bez(2), 'Vdata', F1_bez(j))
    set(F2_bez_obj, 'Xdata', left_side_bez(1), 'Ydata', left_side_bez(2), 'Vdata', F2_bez(j))
    
    %==========================Dalsi grafy=================================
    plot(s1, t(j), x_bez_j, '.', 'linewidth', 1, Color=[0.9290 0.6940 0.1250])
    plot(s1, t(j), x_se_j, '.','linewidth', 1, Color=[0.4660 0.6740 0.1880]);
    plot(s1, t(j), x_desired(j), '.r', 'linewidth', 0.5)
    
    plot(s2, t(j), y_bez_j, '.', 'linewidth', 1, Color=[0.9290 0.6940 0.1250])
    plot(s2, t(j), y_se_j, '.','linewidth', 1, Color=[0.4660 0.6740 0.1880]);
    plot(s2, t(j), y_desired(j), '.r', 'linewidth', 0.5)
    
    plot(s3, t(j), fi_bez_j, '.', 'linewidth', 1, Color=[0.9290 0.6940 0.1250])
    plot(s3, t(j), fi_se_j, '.','linewidth', 1, Color=[0.4660 0.6740 0.1880]);
    plot(s3, t(j), fi_desired(j), '.r', 'linewidth', 0.5)

    plot(s4, t(j), alfa_se_j, '.','linewidth', 1, Color=[0.4660 0.6740 0.1880]);

    if video
    currFrame = getframe(viz);
    writeVideo(vidObj,currFrame);
    end
    %pause(0.01)
    drawnow
end
if video
close(vidObj);
end

%% Cast pro kresleni grafu pro druhou prezentaci projektu
