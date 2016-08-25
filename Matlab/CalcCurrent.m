function [sys,x0,str,ts,simStateCompliance] = CalcCurrent(t,x,u,flag, CoerPower, VitkiNum, I_n,fazCount)

switch flag,
  case 0
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes(CoerPower, VitkiNum, I_n);
  case 2
    sys=mdlUpdate(t,x,u);
  case 3
    sys=mdlOutputs(t,x,u,VitkiNum, CoerPower,fazCount);
  case { 1, 4, 9 }
    sys=[];
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
end;

end

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance] = mdlInitializeSizes(CoerPower, VitkiNum, I_n)

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 6;  % 3 тока, 3 psi
sizes.NumInputs      = 2*3+3;  % 3 тока, 3 напряжения, 1 сопротивление, 1 угол phi и 1 скорость ротора w
sizes.DirFeedthrough = 1;   
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = 0;
ts  = [-1 0]; 

%относительные пути до модели и библиотеки
cd('..');
InterfaceELCUT_Path = strcat(cd(), '\InterfaceELCUT\InterfaceELCUT.dll');
Problem_Path = strcat(cd(), '\Model\PROBLEM.pbm');
cd('Matlab');

global Psi;
global Lmatrix;
global PrevT;
global PrevOut;
global PrePhi;

PrevT = 0;
PrevOut = [0; 0; 0; 0; 0; 0;];
PrePhi=0;
Psi = 0;

if PrevT==0
    
    if exist('InterfaceELCUT.Engine', 'class')==0
        NET.addAssembly(InterfaceELCUT_Path);
    end
    InterfaceELCUT.Engine.Load(Problem_Path);
    
    %получаем индуктивность на первом шаге
    InterfaceELCUT.Engine.EnableMagn(false, 0);
    L = double(InterfaceELCUT.Engine.GetLMatrix(I_n)); %подаем номинальные токи
    InterfaceELCUT.Engine.EnableMagn(true, CoerPower);
    
    Lmatrix = L * VitkiNum^2;  %http://elcut.ru/glossary/multiwinding_inductance.htm
end;

simStateCompliance = 'DefaultSimState';

end

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%

function sys = mdlOutputs(t,x,u, VitkiNum, CoerPower,fazCount)

I = [u(1); u(2); u(3)];
U = [u(4); u(5); u(6)];
Rs = u(7);
phi = u(8);
w = u(9);

global PrevT;
global PrevOut;
global Lmatrix;
global PrevPhi;
global newI;
    
if PrevT==t
    sys=PrevOut;
else
    %Psi уже проинтегрировано, поскольку берем из ELCUT в зависимости от угла
    Psi = GetPsiApprox(phi*180/pi,PrevT, CoerPower,fazCount)*VitkiNum^2; %из радиан в градусы
   
    if PrevT==0
        newI = Lmatrix\U;
        sys=[newI;Psi];
    else 
        newI = Lmatrix\(U - Rs*I - w*Psi); % если Ax=B то x=A\B - решение системы уравнений
        sys = [newI;Psi];
    end;
    
    PrevPhi = phi;
    PrevT = t;
    PrevOut = sys;
   
end;

end

% end mdlOutputs

function sys = mdlUpdate(t,x,u)

sys = u(8); %phi
end
