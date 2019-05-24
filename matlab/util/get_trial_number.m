function trial_number = get_trial_number(can_fail)
        trial_response_cell= {};
        trial_number = [];
        while isempty(trial_response_cell) || isempty(trial_number)
            prompt = {'Enter trial number:'};
            title = 'Trial number';
            dims = [1 50];
            definput = {''};
            trial_response_cell = inputdlg(prompt,title,dims,definput);
            if ~isempty(trial_response_cell)
                trial_number = trial_response_cell{1};
            end
            if (isempty(trial_response_cell) || isempty(trial_number)) && ~strcmp(questdlg('No trial number entered. Do you want to try entering a trial number again?','No Trial Number','Yes','No','Yes'),'Yes') 
                if ~can_fail
                    waitfor(errordlg('Failure: no trial number entered.','No Trial Number'));
                    throw(MException('Custom:Custom' ,'Failure: no trial number.'));
                else
                    trial_number = '';
                    break;
                end
            end
        end
end