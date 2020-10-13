% 12:30-1:45TR D6-10/2/2020 Nathan Dhanasekaran
% [purpose]

clear;
clc;

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
[bestfitcoeff, ~, mu] = polyfit(datenum(dates), totalcases, 3);
p = polyval(bestfitcoeff, datenum(dates), [], mu);
plot(dates, p, 'DisplayName', "Best Fit: Total Cases")

% plot data for those ages 18-29
cases1829 = table2array(data(:,6));
columnname = strrep(char(data.Properties.VariableNames(6)),'_','-');
plot(dates,cases1829,'d','DisplayName',columnname)

% add a line of best fit to the above plotted data
[bestfitcoeff, ~, mu] = polyfit(datenum(dates), cases1829, 3);
p = polyval(bestfitcoeff, datenum(dates), [], mu);
plot(dates, p, 'Displayname', "Best Fit: Ages 18-29")