function result = FindBestPsi()

%находит подходящий угол при котором моент максимальный
%результат вычисления функции скопировать в Excel и построить график
%по графику определить лучший угол

set_param('ThreeFazAlgorythmNew','StopTime','0.0001')

result=zeros(1, 72);

 for i=1:72
    set_param('ThreeFazAlgorythmNew/CurrentToMoment', 'Phi0', strcat(num2str((i-1)*5),'*pi/180'));
    sim('ThreeFazAlgorythmNew');
    result(i)=logsout.get('M').Values.Data(2);
 end;

set_param('ThreeFazAlgorythmNew','StopTime','2')

end