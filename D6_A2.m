% 12:30-1:45TR D6-10/2/2020 Nathan Dhanasekaran
% reads data from a .csv file containing information on COVID-19 cases over
% time, then processes that data by plotting it, calculating a polynomial
% line of best fit, and using the data to make decisions for the future.

clear;
clc;

% define a constant to specify which decision to use; number from 1-3
DECISION=2;

% extract the entire dataset into a variable 'data', then extract dates and
% Total Cases from the dataset
opts = detectImportOptions("D6_A2_COVID-19_Daily_Cases__Deaths__and_Hospitalizations");
% put the imported data in a variable after sorting rows and removing rows with missing data
data = sortrows(rmmissing(readtable("D6_A2_COVID-19_Daily_Cases__Deaths__and_Hospitalizations.csv",opts)));
% use table2array in order to convert the table to a format that can be
% read and used with MATLAB functions
dates = table2array(data(:,1));
totalcases = table2array(data(:,2));

% create an initial plot with dates on the x-axis, with total
% cases on the y-axis. In addition, set the name as displayed in the legend
% to the title of the column in the dataset.

% for reference, strrep (string replace) is to replace underscores in the
% column names, as they cause text formatting issues when put into the
% legend. this is done in a separate variable in order to keep the
% plot() call readable.
columnname = strrep(char(data.Properties.VariableNames(2)),'_','-');
plot(dates,totalcases,'o','DisplayName',columnname)
title("COVID-19 Total Cases Separated by Age")
xlabel("Date")
ylabel("Cases")
% this line makes sure the legend is created on the plot. this line also
% uses strrep to ensure proper text formatting.
legend(strrep(char(data.Properties.VariableNames(2)),'_','-'))

hold on
% add a line of best fit to the above plotted data
% condition the polynomial using the inbuilt features of polyfit i order to
% achieve a better fit
bestfitcoefftotal = polyfit(datenum(dates), totalcases, 3);
p = polyval(bestfitcoefftotal, datenum(dates));
plot(dates, p, 'DisplayName', "Best Fit: Total Cases")

% plot data for those ages 18-29
cases1829 = table2array(data(:,6));
columnname = strrep(char(data.Properties.VariableNames(6)),'_','-');
plot(dates,cases1829,'d','DisplayName',columnname)

% add a line of best fit to the above plotted data
bestfitcoeff1829 = polyfit(datenum(dates), cases1829, 3);
p = polyval(bestfitcoeff1829, datenum(dates));
plot(dates, p, 'Displayname', "Best Fit: Ages 18-29")

hold off
% then, depending on decision, decide what to do with that data
% decision 1: decide whether or not to give a preliminary warning in mid
% march-april
if DECISION == 1
    % index 1 of the totalcases array is march 1st, 2020, while index 61 is
    % april 30th, 2020; this corresponds to the number of days in the time
    % period. It is also the time period at the beginning of the
    % dataset used.
    % here, we use trapz (trapezoidal integration) to find the total number
    % of cases over a certain time period (from March to April)
    marchaprilcases = trapz(totalcases(1:61));
    disp("The number of total cases in the past from March to April were: " + marchaprilcases)
    % here, we predict the number of cases over the same time period, from
    % March to April, but in 2021, using the equation of best fit plotted
    % earlier
    p = polyval(bestfitcoefftotal, (datenum('01-Mar-2021'):datenum('30-Apr-2021')));
    marchaprilpredicted = trapz(p(1:61));
    disp("The number of total cases predicted in the future from March 2021 to April 2021 are: " + marchaprilpredicted)
    % check whether the number of cases has decreased or increased compared
    % to the same time period last year; then advise the user with a
    % decision based on the data
    if marchaprilpredicted >= marchaprilcases
        disp("The total number of COVID-19 cases is predicted to increase. It is advisable to issue a warning and request the public to uphold social distancing and mask guidelines.")
    elseif marchaprilpredicted < marchaprilcases
        disp("The total number of COVID-19 cases is predicted to decrease. It is advisable to remain cautious, but the spread of COVID-19 may decrease if current guidelines are upheld until then.")
    else
        disp("Data was not properly input")
    end
end

if DECISION == 2
    userage = input("Please enter your age: ");
    % if the age is between 18 and 29 (inclusive), then calculate the
    % prediction for a future date with that dataset. otherwise, use the
    % totalcases dataset.
    
    % get user input for a date in format yyyy-MM-dd then convert it
    % from a string to MATLAB's special datetime format
    userdate = datetime(input("Enter a date (yyyy-MM-dd) to predict the total number of COVID-19 cases on that date: ", 's'), 'InputFormat', 'yyyy-MM-dd');
      
    % generate a date to plug into the current data so we can compare
    % predicted cases for a date to the current data we have for that
    % date, though in 2020
    datestring=datestr(userdate);
    datecurrent = replaceBetween(datestr(userdate), 8, 11, '2020');
    dateindex = find(dates==datecurrent);
    
    if (userage >= 18) && (userage <= 29)
        % use the best fit polynomial found earlier to predict cases for
        % the given date
        p = polyval(bestfitcoeff1829, datenum(userdate));
        disp("The predicted number of cases for this date is: " + p(1))
        
        % display the past cases in 2020 for the date specified, if
        % possible; otherwise, compare to the max number of cases in 2020
        if isempty(dateindex)
            disp("There is no data for this date in 2020; so the predicted value will be compared to the maximum number of cases in a day in 2020.")
            disp("The maximum amount of cases in a day in 2020 is: " + max(totalcases))
            if p(1) >= max(totalcases)
                disp("The predicted COVID cases for " + datestring + " are greater than or equal to the maximum number of cases in a day in 2020.")
            elseif p(1) < max(totalcases)
                disp("The predicted COVID cases for " + datestring + " are lower than the maximum number of cases in a day in 2020.")
            end
        else
            if p(1) >= totalcases(dateindex)
                disp("The predicted COVID cases for " + datestring + " are greater than or equal to the number of cases on the same date in 2020.")
            elseif p(1) < totalcases(dateindex)
                disp("The predicted COVID cases for " + datestring + " are lower than the number of cases on the same date in 2020.")
            end
        end
        
    else
        % use best fit for total cases to predict cases for the given date
        p = polyval(bestfitcoefftotal, datenum(userdate));
        disp("The predicted number of cases for this date is: " + p(1))
        
        % display the past cases in 2020 for the date specified, if
        % possible; otherwise, compare to the max number of cases in 2020
        if isempty(dateindex)
            disp("There is no data for this date in 2020; so the predicted value will be compared to the maximum number of cases in a day in 2020.")
            disp("The maximum amount of cases in a day in 2020 is: " + max(totalcases))
            if p(1) >= max(totalcases)
                disp("The predicted COVID cases for " + datestring + " are greater than or equal to the maximum number of cases in a day in 2020.")
            elseif p(1) < max(totalcases)
                disp("The predicted COVID cases for " + datestring + " are lower than the maximum number of cases in a day in 2020.")
            end
        else
            if p(1) >= totalcases(dateindex)
                disp("The predicted COVID cases for " + datestring + " are greater than or equal to the number of cases on the same date in 2020.")
            elseif p(1) < totalcases(dateindex)
                disp("The predicted COVID cases for " + datestring + " are lower than the number of cases on the same date in 2020.")
            end
        end
    end
end

if DECISION == 3
end