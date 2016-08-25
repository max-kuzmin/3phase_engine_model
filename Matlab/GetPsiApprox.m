function resPsi = GetPsiApprox(angle,PrevT,CoerPower,fazCount) %угол в градусах
    %использу€ полином, получаем значение psi в любой точке
    
    if (exist('Psi.mat','file') == false)
        GetPsiFromElcut(CoerPower);
    end;
    
    load('Psi.mat');%матрица Psi дл€ значений 0..360 град с шагом 5
  
    resPsi = zeros(3,1);% нова€ матрица-результат
    
    global curCoefs;
    
    global psiN; % номер столбца в psi
    global ang; % угол
    
    global fazaAngle;
    
    global phiDots; % значени€ фи дл€ углов с разницей 5
    global angleDots;% соответствующие им углы
    
    global Coeffs;%  коэффициенты аппроксимаций

    
 for fazaNum=1:fazCount
     
    fazaAngle(fazaNum) = angle+(fazaNum-1)*(360/fazCount); %угол между фазами
    
    while fazaAngle(fazaNum)>360
        fazaAngle(fazaNum) = fazaAngle(fazaNum)-360; %сокращаем лишние pi
    end;
    while fazaAngle(fazaNum)<0
        fazaAngle(fazaNum) = fazaAngle(fazaNum)+360; %сокращаем лишние pi
    end;
    
 end;
    
 
    % ------------ создание матрицы коэффициентов аппроксимаций
    %               (расчитываетс€ только при первом пуске) ----------------
    if PrevT==0
    Coeffs = zeros(72,5);
       for j=1:72
           psiN = j+3;
           ang = (j-1)*5;
           angleDots = [ang-15, ang-10, ang-5, ang, ang+5, ang+10, ang+15];
           phiDots = [Psi(psiN-3), Psi(psiN-2), Psi(psiN-1), Psi(psiN), Psi(psiN+1), Psi(psiN+2), Psi(psiN+3)]; 

           %подбираем многочлен начина€ с 2-го пор€дка
           curCoefs=polyfit(angleDots, phiDots, 4); %методом наименьших квадратов
           Coeffs(j,1) = curCoefs(1);
           Coeffs(j,2) = curCoefs(2);
           Coeffs(j,3) = curCoefs(3);
           Coeffs(j,4) = curCoefs(4);
           Coeffs(j,5) = curCoefs(5);
       end;
    end;
    
    
    %------------------- расчет значени€ psi по углу ----------------
     for fazaNum=1:fazCount
        ang = 355;
        psiN = 72;
        while ang>fazaAngle(fazaNum)
            ang = ang - 5;
            psiN = psiN - 1;
        end;
        
        curCoefs(1) = Coeffs(psiN,1);
        curCoefs(2) = Coeffs(psiN,2);
        curCoefs(3) = Coeffs(psiN,3);
        curCoefs(4) = Coeffs(psiN,4);
        curCoefs(5) = Coeffs(psiN,5);
        
        %неточна€ аппроксимаци€
        resPsi(fazaNum) = polyval(curCoefs, fazaAngle(fazaNum));   %----- выбор значени€  Psi(X)
        %resPsi(fazaNum) = (polyval(curCoefs, fazaAngle(fazaNum)+0.05)-polyval(curCoefs, fazaAngle(fazaNum)-0.05)); 
    
     end;
end