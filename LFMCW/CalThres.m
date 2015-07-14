function Threshold = CalThres(spec,Idx_CA)

% Calculate Adaptive Threshold
% Using the CA-CFAR/OS-CFAR

%%%%%%%%%% Hinweis  %%%%%%%%%%
% Phase1: Right HalfWin
% Phase2: left HalfWin start
% Phase3: CUT moves
% Phase4: Rigth HalfWin fades

%finding FP Peaks, then change the Win to 19. 


% Stand 16.01.2014
% Han Zhuowei




%%%%%%%%  Input Parameters  %%%%%%%
% Spec:   Signal vectors are in column vector
% Idx_CA=1, using CA-CFAR
% Idx_CA=0, using OS-CFAR


%%%%%%%%  Output %%%%%%%%%
% Threshold : Same Dimension as spec


%% %%% Initialization  %%%%%%
Idx_Pfa=1;
Pfa=[1e-4 1e-6 1e-8];

NCells=length(spec);
skip=2;         %  Length of Guard Cells
Win=20;            %  size of the half signal probe Window. Odd Number
zmin_global=Inf;
Threshold=zeros(NCells,1);
i_start_left=2;       %start index of left half-window
cs= sqrt( 4./pi*Win*2*( Pfa(Idx_Pfa)^(-1/Win/2) -1 ) * (1- (1-pi/4) *exp(-Win*2+1) ) );

OS=[15 18 24 32];      % Order of Data. 
cs_os_matrix=[3.16 3.06 2.93 2.65;...
             4.24 4.04 3.79 3.39;...
             5.38 5.03 4.64 4.09];
% From book of Ludloff, using the linear Detector.
% that means the input/output could be linearly scaled.
% cs =1.3;            %  Factor for threshold scaling of CA
% rampDuration: Factor to decide the start of left Win.


%% %%%%% CA-CFAR--%%%%%%
if Idx_CA==1
    
    for i=1:NCells
        if i<=i_start_left
            %       only right half Window
            index_range_r=i+skip:i+skip+Win-1;
            A=mean(spec(index_range_r));
            zmin=min(spec(index_range_r));
            
        elseif i>i_start_left && i<=i_start_left+Win
            %       start of left half window
            %       right window
            index_range_r=i+skip:i+skip+Win-1;
            A_right=mean(spec(index_range_r));
            zmin_r=min(spec(index_range_r));
            length_r=length(index_range_r);
            %       left window
            index_range_l=i_start_left+1:i-skip;
            A_left=mean(spec(index_range_l));
            zmin_l=min(spec(index_range_l));
            length_l=length(index_range_l);
            %       combine and compare
            A=(A_left*length_l+A_right*length_r)/(length_l+length_r);
            zmin=min(zmin_r,zmin_l);
            
            % index_range_l = max(i_start_left+1,i-skip-Win+1):i-skip:min(...,...)
        elseif i>i_start_left+Win && i<=NCells-skip-Win
            %       CUT moves with full window
            index_range_r=i+skip:i+skip+Win-1;
            A_right=mean(spec(index_range_r));
            zmin_r=min(spec(index_range_r));
            
            index_range_l=i-skip-Win+1:i-skip;
            A_left=mean(spec(index_range_l));
            zmin_l=min(spec(index_range_l));
            %       combine and compare
            A=(A_left+A_right)/2;
            zmin=min(zmin_r,zmin_l);
            
        elseif i>NCells-skip-Win;
            %       fading of right window
            index_range_r=i+skip:NCells;
            A_right=mean(spec(index_range_r));
            zmin_r=min(spec(index_range_r));
            length_r=length(index_range_r);
            
            index_range_l=i-skip-Win+1:i-skip;
            A_left=mean(spec(index_range_l));
            zmin_l=min(spec(index_range_l));
            length_l=length(index_range_l);
            
            %       combine and compare
            A=(A_left*length_l+A_right*length_r)/(length_l+length_r);
            zmin=min(zmin_r,zmin_l);
        else
            disp('Out of Signal dimension');
        end
        %end For
        
        if zmin<zmin_global
            zmin_global=zmin;
        end
        
        %         Threshold(i)=cs*(A-zmin_global)+zmin_global;
        Threshold(i)=cs*A;
    end
    %%%%%% End-CA--%%%%%%%%%%%%
else
    %%  %%%%----OS CFAR---%%%%%%%%
    for i=1:NCells
        if i<=i_start_left
            %       only right half Window
            index_range_r=i+skip:i+skip+Win-1;
            A_tem=sort(spec(index_range_r),'ascend');
            A=A_tem(OS(1));
            cs_os=cs_os_matrix(Idx_Pfa,1);
        elseif i>i_start_left && i<=i_start_left+Win
            %       start of left half window
            %       right window
            index_range_r=i+skip:i+skip+Win-1;
            A_tem_r=sort(spec(index_range_r),'ascend');
            %       left window
            index_range_l=i_start_left+1:i-skip;
            A_tem_l=sort(spec(index_range_l),'ascend');
            %       combine and compare
            A_com=[A_tem_r;A_tem_l]; %need ; , because Column Arrays.
            A_tem=sort(A_com,'ascend');
            Win_length=length(A_tem);
            if Win_length<24
                A=A_tem(OS(1));
                cs_os=cs_os_matrix(Idx_Pfa,1);
            elseif Win_length>=24 && Win_length<32
                A=A_tem(OS(2));
                cs_os=cs_os_matrix(Idx_Pfa,2);
            elseif Win_length>=32 && Win_length<40
                A=A_tem(OS(3));
                cs_os=cs_os_matrix(Idx_Pfa,3);
            end
            
        elseif i>i_start_left+Win && i<=NCells-skip-Win
            %       CUT moves with full window
            index_range_r=i+skip:i+skip+Win-1;
            A_tem_r=sort(spec(index_range_r),'ascend');
            
            index_range_l=i-skip-Win+1:i-skip;
            A_tem_l=sort(spec(index_range_l),'ascend');
            %       combine and compare
            A_com=[A_tem_r;A_tem_l];
            A_tem=sort(A_com,'ascend');
            A=A_tem(OS(4));
            cs_os=cs_os_matrix(Idx_Pfa,4);
            
        elseif i>NCells-skip-Win;
            %       fading of right window
            index_range_r=i+skip:NCells;
            A_tem_r=sort(spec(index_range_r),'ascend');
            
            index_range_l=i-skip-Win+1:i-skip;
            A_tem_l=sort(spec(index_range_l),'ascend');
            
            %       combine and compare
            A_com=[A_tem_r;A_tem_l];
            A_tem=sort(A_com,'ascend');
            Win_length=length(A_tem);
            if Win_length<24
                A=A_tem(OS(1));
                cs_os=cs_os_matrix(Idx_Pfa,1);
            elseif Win_length>=24 && Win_length<32
                A=A_tem(OS(2));
                cs_os=cs_os_matrix(Idx_Pfa,2);
            elseif Win_length>=32 && Win_length<40
                A=A_tem(OS(3));
                cs_os=cs_os_matrix(Idx_Pfa,3);
            end
        else
            disp('Out of Signal dimension');
        end
        Threshold(i)=cs_os*A;
    end
    
end %end if CA
%%%%% END Calculation %%%%%%%%%%%%
end





