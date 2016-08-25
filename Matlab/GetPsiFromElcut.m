function [ Psi ] = GetPsiFromElcut(CoerPower)
    % получить значения Psi для 1 фазы для всех углов с шагом 5
    
    
    InterfaceELCUT.Engine.SetTokToFaza(1, 0, true);
    InterfaceELCUT.Engine.SetTokToFaza(2, 0, true);
    InterfaceELCUT.Engine.SetTokToFaza(3, 0, true);
    InterfaceELCUT.Engine.EnableMagn(true, CoerPower);
    
    Psi = zeros(1, 78);
    for i = 1:78
        InterfaceELCUT.Engine.RotateMagn((i-4)*5*pi/180); %начальный угол 179 градусов
        InterfaceELCUT.Engine.Solve();
        Psi(i) = double(InterfaceELCUT.Engine.GetPsi(1));
    end;
    
    save('Psi.mat', 'Psi');
end