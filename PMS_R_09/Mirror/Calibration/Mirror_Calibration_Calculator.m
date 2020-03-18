%PMS Reader script
clear
%participantNum = input("Enter the participant code: ");
participantNum = 8;

% Add 0 as MATLAB chops to single digits
if participantNum < 10
    participantNum = "0" + participantNum;
end
participantFile = "PMS_R_" + participantNum;

% Go through all input data files, declare some constants before entering
trialNumberVect = 100:400;
bimanualFileExtension = "_6d";
csvFileExtension = ".csv";
pen1 = "Pen1";
xCol = 0;
zCol = 0;
loopCounter = 1;
headerLine = 5;
searchTerms = [];

% For all trials we get the means of the coords of the trials
xPosMean = [];
zPosMean = [];

for trial = trialNumberVect    
    % Create trial file name
    trialFile = participantFile + "_" + trial + bimanualFileExtension +...
        csvFileExtension;
    
    % Check if this file actually exists
    if ~isfile(trialFile)
        continue
    end
    
    % Read in data file
    dataFile = readtable(trialFile, 'HeaderLines', 4, 'PreserveVariableNames', 1);
    
    % Choose pen 1 to 
    pen = pen1;
    searchTerms = [pen + "_tip x", pen + "_tip z"];
   
    % Find mean of the position data
    xPosMean(loopCounter) = mean(dataFile{:, searchTerms(1)});
    zPosMean(loopCounter) = mean(dataFile{:, searchTerms(2)});
    
    % Increment loop counter
    loopCounter = loopCounter + 1;
end
sprintf("All done collecting x and z data")

% Create output file name and headers
meanFile = "CalPoints_Mirror_PMS_R_" + participantNum + csvFileExtension;
headers = ["Point 1 x (end),Point 1 z (end),Origin x (start),Origin z (start),Point 3 x,Point 3 z"];

% Open file and write headers to it
outputFile = fopen(meanFile, 'w');
fprintf(outputFile, '%s\n', headers);

% Input data into the file
i = 1;
while i-1 < length(xPosMean)
    inputRow = [xPosMean(i), zPosMean(i), xPosMean(i+1), zPosMean(i+1),...
        xPosMean(i+2), zPosMean(i+2)];
    inputRow = strjoin(string(inputRow), ","); 
    fprintf(outputFile, "%s\n", inputRow);
    i = i + 3;
end

% Close File
fclose(outputFile)