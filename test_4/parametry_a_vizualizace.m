%% Parametry
g = 9.81;
L = 0.086; %[m] poloviční délka kvadrokoptéry
d = 0.1; %[m] délka lana

M = 0.5; %[kg]
m = 0.01; %[kg]
Ikv = 0.00025; %[kg*m^2]
Ip = m*d^2; % setrvačnost hmotného bodu vzdáleného od osy rotace

k = 0.1; % tlumení kvadrokoptéry
kp = 0.01; % tlumení kyvadla

%syms s
%%
data = sim('simulink_2D_Quadrotor_and_pendulum.slx');
t = data.tout;
x_t = data.ScopeData.signals(1).values;
y_t = data.ScopeData.signals(2).values;
fi_t = data.ScopeData.signals(3).values; %[deg]
alfa_t = data.ScopeData.signals(4).values; %[deg]
F1_t = data.F1_t;
F2_t = data.F2_t;
%% Grafy a Vizualizace
close all
%s=get(0,'ScreenSize');

if false
    h=figure;
    %set(h,'Position',[5 10 0.99*s(3) 0.9*s(4)],'color',[1 1 1])
    set(h,'Name', 'Grafy', 'Color',[1 1 1])


    subplot(4, 1, 1); 
    grid on 
    xlabel('t [s]') 
    ylabel('x [m]')
    set(gca,'Ylim',[min(x_t) max(x_t)]) 
    title('X poloha kvadrokoptery')
    
    subplot(4, 1, 2)
    grid on
    xlabel('t [s]') 
    ylabel('y [m]')
    set(gca,'Ylim',[min(y_t) max(y_t)]) 
    title('Y poloha kvadrokoptery')
    
    subplot(4, 1, 3)
    grid on
    xlabel('t [s]') 
    ylabel('fi [deg]')
    set(gca,'Ylim',[min(fi_t) max(fi_t)]) 
    title('Otoceni kvadrokoptery')
    
    subplot(4, 1, 4)
    grid on
    xlabel('t [s]') 
    ylabel('alfa [deg]')
    set(gca,'Ylim',[min(alfa_t) max(alfa_t)]) 
    title('Vychyleni zavazi')
end


viz=figure;
set(viz, 'Name', 'Vizualizace', 'Color',[1 1 1])
%h1=subplot('position',[0 0.06 1 0.30]);
axis([-1 1 -5 5])
hold on
axis equal
grid on

% Kvadrokoptera
Quadrocopter=fill([-L*10 L*10],[0 0],[0.9 0.9 0.9],'linewidth',2);
F1=quiver(L*10,0,0,F1_t(2),'color',[1 0 0],'linewidth',2); %sila zprava
F2=quiver(-L*10,0,0,F2_t(2),'color',[0 0 1],'linewidth',2); %sila zleva
% Zavazi
lano=plot([0 0],[0 -d*10],'k','linewidth',2, Color=[139,69,19]./255);
cirp=plot(0,-d*10,'ko','MarkerSize',10,'linewidth',2,'MarkerFaceColor',[0 1 0]);


video = false;

if video
vidObj = VideoWriter('quadrotor_and_pendulum_test1','MPEG-4');
vidObj.FrameRate=60;
open(vidObj);
end

%% Pohyb
interval=10;
for k=1:interval:length(t)
    x=x_t(k);
    y=y_t(k);
    fi=fi_t(k); 
    alfa=alfa_t(k);
    disp(t(k))
    
    %[new_x; new_y]=R*[inicial_x; inicial_y] + [x(t); y(t)]
    left_side=[cosd(fi) -sind(fi); sind(fi) cosd(fi)]*[-L*10; 0] + [x; y]; 
    right_side=[cosd(fi) -sind(fi); sind(fi) cosd(fi)]*[L*10; 0] + [x; y];

    set(Quadrocopter,'Xdata',[left_side(1) right_side(1)],'Ydata',[left_side(2) right_side(2)]);

    %kontrola ze vzdalenost mezi krajnimi body kvadrokoptery se rovna 2*L
    %disp( sqrt( (left_side(1)-right_side(1))^2 + (left_side(2)-right_side(2)^2) ) )
    
    set(F1, 'Xdata', right_side(1), 'Ydata', right_side(2), 'Vdata', F1_t(k))
    set(F2, 'Xdata', left_side(1), 'Ydata', left_side(2), 'Vdata', F2_t(k))
    
    x_pendulum = x + d*10*sind(alfa);
    y_pendulum = y - d*10*cosd(alfa);
    set(lano, 'Xdata', [x, x_pendulum], 'Ydata', [y, y_pendulum])
    set(cirp, 'XData', x_pendulum, 'YData', y_pendulum)

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