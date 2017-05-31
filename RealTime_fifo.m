%v 31.05.17
function Real
close all;
a=serial('COM8');
a.BaudRate=57600;
fopen(a);
finishup = onCleanup(@() fclose(a));
global piece_fifo;%остаток пакета в фифо
piece_fifo=[];
figure(1);
line = animatedline;
x=0;
sample=0;
while true
    [sample errCount]=read_sample_fifo(a);
    %---plot--
    xlast=x(end);
    %x=x+1;
    x=xlast+1:xlast+length(sample);
    %for i=1:length(sample)
    xlim([x(end)-500 x(end)])
    ylim([0 1200])
    addpoints(line,x,sample)
    drawnow;
    %end
    %---end plot--
end
end