%% Příprava dat pro vizualizaci
% soubor s modely
% data = sim('simulink_rizeni_bez_a_s_zavazim.slx');
data = out; % tento prikaz, pokud Simulink soubor byl spusten uvnitr rucne
video = false;

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

%% Grafy a Vizualizace
close all
%s=get(0,'ScreenSize');

% if false
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
set(viz, 'Name', 'Vizualizace', 'Color',[1 1 1])
%h1=subplot('position',[0 0.06 1 0.30]);
axis([-1 1 -10 10])
hold on
axis equal
%axis('auto');
grid on

% Kvadrokoptera se zavazim
Quadrocopter_se_obj=fill([-L*10 L*10],[0 0],[0.9 0.9 0.9],'linewidth',2);
txt_se = text(0, 0, 'Se', 'HorizontalAlignment', 'center');
F1_se_obj=quiver(L*10,0,0,F1_se(1),'color',[1 0 0],'linewidth',2); %sila zprava
F2_se_obj=quiver(-L*10,0,0,F2_se(1),'color',[0 0 1],'linewidth',2); %sila zleva
% Zavazi
lano=plot([0 0],[0 -d*10],'k','linewidth',2, Color=[139,69,19]./255);
cirp=plot(0,-d*10,'ko','MarkerSize',10,'linewidth',2,'MarkerFaceColor',[0 1 0]);

% Kvadrokoptera bez zavazi
Quadrocopter_bez_obj=fill([-L*10 L*10],[0 0],[0.9 0.9 0.9],'linewidth',2);
F1_bez_obj=quiver(L*10,0,0,F1_bez(1),'color',[1 0 0],'linewidth',2); %sila zprava
F2_bez_obj=quiver(-L*10,0,0,F2_bez(1),'color',[0 0 1],'linewidth',2); %sila zleva
txt_bez = text(0, 0, 'Bez', 'HorizontalAlignment', 'center');




if video
vidObj = VideoWriter('video','MPEG-4');
vidObj.FrameRate=60;
open(vidObj);
end

%% Pohyb
interval=30; %FPS
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

    % 
    %  if k==2
    %     py=plot(h3,x(k-1:k,1),x(k-1:k,2),'b','linewidth',2);
    %     pu=plot(h2,fi(k-1:k,1),fi(k-1:k,2),'g','linewidth',2);
    %     pf=plot(h5,u(k-1:k,1),u(k-1:k,2),'r','linewidth',2);
    %  else
    %     set(py,'Xdata',x(floor(k/2000)*2000+1:k,1),'Ydata',x(floor(k/2000)*2000+1:k,2));
    %     set(pu,'Xdata',fi(floor(k/2000)*2000+1:k,1),'Ydata',fi(floor(k/2000)*2000+1:k,2));
    %     set(pf,'Xdata',u(floor(k/2000)*2000+1:k,1),'Ydata',u(floor(k/2000)*2000+1:k,2));
    %  if k==3
    %      pause
    %  end
    %  end
    %  set(h3,'Xlim',[0 20]+floor(x(k,1)/20)*20);
    %  set(h2,'Xlim',[0 20]+floor(x(k,1)/20)*20);
    %  set(h5,'Xlim',[0 20]+floor(x(k,1)/20)*20);
     
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