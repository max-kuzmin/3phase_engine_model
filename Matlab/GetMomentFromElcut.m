function [ M ] = GetMomentFromElcut()

%функция для проверки плавности синусойды момента
%результат вычисления функции скопировать в Excel и построить график
%если получается график с зубцами, то нужно переделать модель в Elcut
%если синусойда плавная, то все хорошо

cd('..');
InterfaceELCUT_Path = strcat(cd(), '\InterfaceELCUT\InterfaceELCUT.dll');
Problem_Path = strcat(cd(), '\Model\PROBLEM.pbm');
cd('Matlab');

    % находим угол с максимальным моментом
    if exist('InterfaceELCUT.Engine', 'class')==0
        NET.addAssembly(InterfaceELCUT_Path);
    end

    InterfaceELCUT.Engine.Load(Problem_Path);

    %подаем любой ток
    InterfaceELCUT.Engine.SetTokToFaza(1, 1000, true);
    InterfaceELCUT.Engine.SetTokToFaza(2, 0, true);
    InterfaceELCUT.Engine.SetTokToFaza(3, -1000, true);
    
    M = zeros(1, 72);
    for i = 1:72
        InterfaceELCUT.Engine.RotateMagn((i-1)*5*pi/180);
        InterfaceELCUT.Engine.Solve();
        M(i) = double(InterfaceELCUT.Engine.GetMoment());
    end;
    
    save('M.mat', 'M');
end