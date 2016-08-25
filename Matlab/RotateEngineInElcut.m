function [sys,x0,str,ts,simStateCompliance] = RotateEngineInElcut(t,x,u,flag)

switch flag,
  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys=mdlUpdate(t,x,u);
    
  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case { 1, 4, 9 }
    sys=[];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Unexpected flags (error handling)%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance] = mdlInitializeSizes()

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 2;
sizes.NumOutputs     = 1;  % один выход - момент
sizes.NumInputs      = 4;  % 4 входа - токи на фазах A, B, C и phi - угол поворота ротора
sizes.DirFeedthrough = 0;   % has direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = 0;
ts  = [-1 0];   % inherited sample time

% specify that the simState for this s-function is same as the default
simStateCompliance = 'DefaultSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%

function sys = mdlOutputs(t,x,u)
sys = x(2);

% end mdlOutputs

function sys = mdlUpdate(t,x,u)

%if exist('InterfaceELCUT.Engine', 'class')==0
%        NET.addAssembly(InterfaceELCUT_Path);
%end

InterfaceELCUT.Engine.SetTokToFaza(1, u(1), true); %I_A
InterfaceELCUT.Engine.SetTokToFaza(2, u(2), true); %I_B
InterfaceELCUT.Engine.SetTokToFaza(3, u(3), true); %I_C
InterfaceELCUT.Engine.RotateMagn(u(4)); %phi
sys = [1 InterfaceELCUT.Engine.GetMoment]; %момент с минусом, поскольку элкат крутит в обратную сторону
