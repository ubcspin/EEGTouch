feeltrace_time = processed_data.feeltrace{:, 1};
feeltrace_scale = (processed_data.feeltrace{:, 2}-125)./12.5;
plot(feeltrace_time, feeltrace_scale);

hold on;
interview_time = processed_data.interview{:,1};
interview_scale = processed_data.interview{:,2};

color = strings(length(interview_scale),0);
invisible = interview_scale == 11;
color(invisible) = 'white';
color(~invisible) = 'red';
scatter(interview_time, interview_scale, 25, color);
scatter(20000, 0, [],'white')