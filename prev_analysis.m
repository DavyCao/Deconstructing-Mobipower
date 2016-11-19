powerfile_name=strcat('power/',folder_name,'.csv');
powerfile=dlmread(powerfile_name,',',1);
if size(powerfile,2)==4
    powerfile(:,1)=powerfile(:,1)/1000;
    powerfile(:,3)=powerfile(:,3)/1000;
    powerfile=powerfile(:,[1 3]);
end
remove=[];

file_size=1;
websites_no=size(energyfile_names,1);

powerfile_web=cell(websites_no);

D_energy=cell(websites_no);
D_time_s=cell(websites_no);
D_time_e=cell(websites_no);
D_components=cell(websites_no);
D_energy_threshold=cell(websites_no);
energysize=zeros(websites_no);
energysize_threshold=zeros(websites_no);

PLT=zeros(websites_no,1);
Joules=zeros(websites_no,1);

%====Load Wprof data====
for webno=1:websites_no
    energyfile_name=strcat(energyfile_names{webno},'_.csv');
%     energyfile_name=strcat('130.245.145.212_',energyfile_names{webno},'_',energyfile_names{webno},'_.csv');
    energyfile_path=strcat('energy/',folder_name,'/excel/',energyfile_name);
    [D_time_s{webno},D_time_e{webno},D_components{webno}]=textread(energyfile_path,'%f,%f,%[^\n]','headerlines',1,'bufsize',10000000);
    D_energy_threshold{webno}=D_time_e{webno} - D_time_s{webno};
    energysize(webno)=size(D_time_s{webno},1);
    energysize_threshold(webno)=size(D_energy_threshold{webno}(D_energy_threshold{webno}>threshold),1);
    PLT(webno)=D_time_e{webno}(end)/1000;
end
disp('Power and wprof files loaded.')

total_lines=0;
threshold_lines=0;
for webno=1:websites_no
    total_lines=total_lines+energysize(webno);
    threshold_lines=threshold_lines+energysize_threshold(webno);
end

%====Truncate power data
for webno=1:websites_no
    endtimes_array=D_time_e{webno};
    starttimes_array=D_time_s{webno};
    temp_powerfile=powerfile((powerfile(:,1)>=diff+start(webno)-start(1)) & (powerfile(:,1)<=0.003+diff(1)+start(webno)-start(1)+(endtimes_array(end)-starttimes_array(1))/1000),:);
    temp_powerfile(:,1)=temp_powerfile(:,1)-temp_powerfile(1,1);
    powerfile_web{webno}=temp_powerfile;
end
disp('Powerfile segmentation complete.')


%New timeslot
timeslot=[0 PLT(test_webno)];

power=[];
Joules_part=0;
for webno=1:websites_no
    train_power=powerfile_web{webno};
    starttime=D_time_s{webno};
    endtime=D_time_e{webno};
    j=1;
    seg_starttime=0;
    for k=1:energysize(webno)
        seg_endtime=seg_starttime+abs(D_time_s{webno}(k)-D_time_e{webno}(k))/1000;
        if abs(D_time_s{webno}(k)-D_time_e{webno}(k))>threshold
            power(end+1)=0;
            length=0;
            while(j <= size(train_power,1) && train_power(j,1)*1000<starttime(k))
                j=j+1;
            end
            %Power array
            while(j+1 <= size(train_power,1) && train_power(j+1,1)*1000<=endtime(k))
                Joules(webno)=Joules(webno)+train_power(j,2)*(train_power(j+1,1)-train_power(j,1));
                if (seg_starttime>=timeslot(1)) && (seg_endtime<=timeslot(2)) && (webno==test_webno)
                    Joules_part=Joules_part+train_power(j,2)*(train_power(j+1,1)-train_power(j,1));
                end
                power(end)=power(end)+train_power(j,2)*(train_power(j+1,1)-train_power(j,1));
                length = length + train_power(j+1,1)-train_power(j,1);
                j=j+1;
            end
            power(end)=power(end)/length;
        end
        seg_starttime=seg_endtime;
    end
end