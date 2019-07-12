load_all_processed;

fsr = table('Size', [0 8], 'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ... 
    'VariableNames', {'timestamp_ms', 'A0', 'A1', 'A2', 'A3', 'A4', 'abs', 'pnum'});

for i = 1:size(all_data,1)
    pfile = all_data{i,1};
    
    if ~isempty(pfile)
        fprintf('Processing fsr data from participant %d...\n', i);
        fsr_rows = size(pfile.processed_data.fsr, 1);
        
        pfile.processed_data.fsr.abs = max( ...
            [pfile.processed_data.fsr.A0, ...
                pfile.processed_data.fsr.A1, ...
                pfile.processed_data.fsr.A2, ...
                pfile.processed_data.fsr.A3, ...
                pfile.processed_data.fsr.A4], [], 2);
        pfile.processed_data.fsr.pnum = ones(fsr_rows, 1) * i;
        
        
        
%         if i == 2
%            plot(pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A0, ...
%                pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A1, ...
%                pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A2, ...
%                pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A3, ...
%                pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A4),
%                % pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.abs),
%             legend('A0','A1','A2','A3','A4')
%             ax0 = subplot(6,1,1);
%             ax1 = subplot(6,1,2);
%             ax2 = subplot(6,1,3);
%             ax3 = subplot(6,1,4);
%             ax4 = subplot(6,1,5);
%             axa = subplot(6,1,6);
%             plot(ax0, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A0)
%             plot(ax1, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A1)
%             plot(ax2, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A2)
%             plot(ax3, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A3)
%             plot(ax4, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.A4)
%             plot(axa, pfile.processed_data.fsr.timestamp_ms, pfile.processed_data.fsr.abs)
%         end
        
        fsr = vertcat(fsr, pfile.processed_data.fsr);
    end 
end

% writetable(fsr, './tableau/fsr.csv')

clearvars fsr_rows i pfile fsr