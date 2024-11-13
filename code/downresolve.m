function [result]=downresolve(field, axisX, axisY)
    result = zeros(length(axisX),length(axisY));
    step = axisX(2)-axisX(1);
    for i = 1:length(axisX)-1
        for j = 1:length(axisY)-1
            result(i,j) = sum(sum(field(axisX(i):axisX(i)+step,axisY(j):axisY(j)+step)));
        end
    end
    return
end