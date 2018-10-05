f = waitbar(0.95,'Saving file','Name','Data Processing');
save(fullfile('processed_data_10', 'processed_data.mat'),'aligned_data', 'scalars');
close(f);
waitfor(helpdlg('Data processing completed.'));