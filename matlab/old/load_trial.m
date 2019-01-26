if ~exist('trial_number', 'var') && exist('processed_data','var') && exist('processed_data.scalars','var') && exist ('processed_data.scalars.trial_number','var')
    trial_number = processed_data.scalars.trial_number;
else
    prompt = {'Enter trial number:'};
    title = 'Trial number';
    dims = [1 50];
    % put thing anticipating here
    definput = {'0'};
    trial_response_cell = inputdlg(prompt,title,dims,definput);
    trial_number = trial_response_cell{1};
end
processed_data.scalars.trial_number = trial_number;
