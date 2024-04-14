close all

g = 9.81;
L = 0.086; %[m] poloviční délka kvadrokoptéry
d = 0.1; %[m] délka lana

M = 0.5; %[kg]
m = 0.01; %[kg]
Ikv = 0.00025; %[kg*m^2]
Ip = m*d^2; % setrvačnost hmotného bodu vzdáleného od osy rotace

k = 0.1; % tlumení kvadrokoptéry
kp = 0.01; % tlumení kyvadla

syms s

sim('simulink_2D_Quadrotor_and_pendulum.slx')

s=get(0,'ScreenSize');
h=figure;
set(h,'Position',[5 10 0.99*s(3) 0.9*s(4)],'color',[1 1 1])
h2=subplot('position',[0.07 0.4 0.65 0.15]);
grid
xlabel('$t$','Interpreter','Latex','FontSize',18)
ylabel('$\varphi [rad]$','Interpreter','Latex','FontSize',18)
set(gca,'Ylim',[min(fi(:,2)) max(fi(:,2))])
hold on
title('Pendulum angle','FontSize',12)

h3=subplot('position',[0.07 0.6 0.65 0.15]);
grid
hold on
ylabel('$x [m]$','Interpreter','Latex','FontSize',18)
title('Cart position','FontSize',12)
set(gca,'Ylim',[min(x(:,2)) max(x(:,2))])

h5=subplot('position',[0.07 0.8 0.65 0.15]);
grid
hold on
ylabel('$F [N]$','Interpreter','Latex','FontSize',18)
title('Action force','FontSize',12)
set(gca,'Ylim',[min(u(:,2))-0.0001 max(u(:,2))+0.0001])
hold on



h6=subplot('position',[0.78 0.4 0.18 0.55]);
pzmap(sys);


w0=sqrt((m+M)*g/M/5);
T0=4*pi/w0;

R=7;
%vykresleni voziku
h1=subplot('position',[0 0.06 1 0.30]);
axis([-20 100 -8 10])
hold on
plot([-20 100],[-0.2 -0.2],'linewidth',2,'color',[0.8706 0.4902 0]);
Cart=fill([0 4 4 0 0],[0 0 2 2 0],[0.9 0.9 0.9],'linewidth',2);
Ff=quiver(1,1,u(1,1),0,0,'color',[1 0 0],'linewidth',2);
set(h1,'visible','off');
pend=plot([2 2],[2 9],'k','linewidth',2);
cirp=plot(2,9,'ko','MarkerSize',17,'linewidth',2,'MarkerFaceColor',[0 1 0]);


% vidObj = VideoWriter('pend_two_step_short','MPEG-4');
% vidObj.FrameRate=100;
% open(vidObj);


for k=2:length(x)
    Y=x(k,2);
    Fi=fi(k,2);
    set(Cart,'Xdata',[0 4 4 0 0]+Y);
    set(pend,'Xdata',[Y+2 Y+2-R*sin(Fi)],'Ydata',2+[0 R*cos(Fi)])
    set(cirp,'Xdata',Y+2-R*sin(Fi),'Ydata',2+R*cos(Fi))
    set(Ff,'Xdata',Y+2,'Udata',5*u(k,2))

     if k==2
        py=plot(h3,x(k-1:k,1),x(k-1:k,2),'b','linewidth',2);
        pu=plot(h2,fi(k-1:k,1),fi(k-1:k,2),'g','linewidth',2);
        pf=plot(h5,u(k-1:k,1),u(k-1:k,2),'r','linewidth',2);
     else
        set(py,'Xdata',x(floor(k/2000)*2000+1:k,1),'Ydata',x(floor(k/2000)*2000+1:k,2));
        set(pu,'Xdata',fi(floor(k/2000)*2000+1:k,1),'Ydata',fi(floor(k/2000)*2000+1:k,2));
        set(pf,'Xdata',u(floor(k/2000)*2000+1:k,1),'Ydata',u(floor(k/2000)*2000+1:k,2));
     if k==3
         pause
     end
     end
     set(h3,'Xlim',[0 20]+floor(x(k,1)/20)*20);
     set(h2,'Xlim',[0 20]+floor(x(k,1)/20)*20);
     set(h5,'Xlim',[0 20]+floor(x(k,1)/20)*20);
     %currFrame = getframe(h);
     %writeVideo(vidObj,currFrame);
     pause(0.05)
end
%close(vidObj);