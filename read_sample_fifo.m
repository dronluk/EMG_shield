function [ sample errCount ] = read_sample( a )

numChannels = 6 ;
numPacket = 1 ;
m=1;
sample=[];
global piece_fifo;
while ( a.BytesAvailable < 102 )
    pause(.1);
end
errCount=0;
myData=[];
fifo=fread(a,102);
myData =[piece_fifo fifo];

while (m<=length(myData))
data = zeros(1,numChannels) ;
sync1 = uint8(myData(m));

while (sync1~=hex2dec('A5'))
    m=m+1;
    errCount=errCount+1;
    mess=['Не A5. Количество до обнаружения:',num2str(errCount)];
    disp(mess)
    sync1=uint8(myData(m));
end

    if (m>length(myData)-17+1) %если начало пакета нашлось в конце и он будет оборван
        piece_fifo=[];
        piece_fifo=fifo(m:end);
        break;
    end
    
if sync1==hex2dec('A5')
    m = m+1;
    sync2 = uint8(myData(m));
    if sync2==hex2dec('5A')
        m = m+1;
        pktVersion =uint8(myData(m)) ;
        if pktVersion == 2
            m=m+1;
            pktCount = uint8(myData(m));
            m=m+1;
            for nChannel = 1:numChannels
                value = myData(m) * 2^8 + myData(m+1);
                m=m+2;
                if value<1024
                    val10 = value ;
                end
                data(numPacket, nChannel) = val10 ;
            end
            data = mean(data.').';
            sample=[sample data];
            channelState =uint8(myData(m));
            m=m+1;
        else
          disp('Потерялась синхронизация после 5A')  
        end
    else
        disp('Потерялась синхронизация после A5')
    end
end
end
end

