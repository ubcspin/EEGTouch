f = waitbar(0.95,'Saving file','Name','Data Processing');
%save('processed_data.mat',['aligned_data' 'scalars']);
close(f);
waitfor(helpdlg('Data processing completed.'));
