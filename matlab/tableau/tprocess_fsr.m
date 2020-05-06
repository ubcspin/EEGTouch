load_all_processed;

fsr = table('Size', [0 8], 'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ... 
    'VariableNames', {'timestamp_ms', 'A0', 'A1', 'A2', 'A3', 'A4', 'abs', 'pnum'});

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Processing fsr data from participant %d...\n', i);
        fsr_rows = size(pfile.fsr, 1);
        
        pfile.fsr.abs = max( ...x
            [pfile.fsr.A0, ...
                pfile.fsr.A1, ...
                pfile.fsr.A2, ...
                pfile.fsr.A3, ...
                pfile.fsr.A4], [], 2);
        pfile.fsr.pnum = ones(fsr_rows, 1) * i;
        
        
        
%         if i == 2
%            plot(pfile.fsr.timestamp_ms, pfile.fsr.A0, ...
%                pfile.fsr.timestamp_ms, pfile.fsr.A1, ...
%                pfile.fsr.timestamp_ms, pfile.fsr.A2, ...
%                pfile.fsr.timestamp_ms, pfile.fsr.A3, ...
%                pfile.fsr.timestamp_ms, pfile.fsr.A4),
%                % pfile.fsr.timestamp_ms, pfile.fsr.abs),
%             legend('A0','A1','A2','A3','A4')
%             ax0 = subplot(6,1,1);
%             ax1 = subplot(6,1,2);
%             ax2 = subplot(6,1,3);
%             ax3 = subplot(6,1,4);
%             ax4 = subplot(6,1,5);
%             axa = subplot(6,1,6);
%             plot(ax0, pfile.fsr.timestamp_ms, pfile.fsr.A0)
%             plot(ax1, pfile.fsr.timestamp_ms, pfile.fsr.A1)
%             plot(ax2, pfile.fsr.timestamp_ms, pfile.fsr.A2)
%             plot(ax3, pfile.fsr.timestamp_ms, pfile.fsr.A3)
%             plot(ax4, pfile.fsr.timestamp_ms, pfile.fsr.A4)
%             plot(axa, pfile.fsr.timestamp_ms, pfile.fsr.abs)
%         end
        
        fsr = vertcat(fsr, pfile.fsr);
    end 
end

% writetable(fsr, './tableau/fsr.csv')

clearvars fsr_rows i pfile