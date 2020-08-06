c = 1500;
l = input('largo tanque = ');
b = input('ancho tanque = ');
h = input('alto tanque = ');
d = 0:.1:5;
T1 = (l-d)/c;
T2 = (2*d)/c;
T3 = (sqrt(b^2+d.^2)-d)/c;
T4 = (sqrt(h^2+d.^2)-d)/c;
xlabel('Distancia entre hidrófonos [m]')
ylabel('Echo free time [ms]')
figure
plot (d,T1,'r',d,T2,'b',d,T3,'k',d,T4,'Linewidth',2); 
grid on
xlabel('Distancia entre hidrófonos [m]')
ylabel('Echo free time [ms]')