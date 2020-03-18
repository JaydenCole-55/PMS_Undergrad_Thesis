%PMS Reader script
clear
participantNum = input("Enter the participant code: ");

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
pen2 = "Pen2";
xCol = 0;
zCol = 0;
groupOf4Counter = 1;
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
    
    % See what pen to use
    pen = pen1;
    searchTerms = [pen + "_tip x", pen + "_tip z"];
 
    if mod(groupOf4Counter , 4) == 0
        pen = pen2;
        searchTerms = [pen + "_tip2 x", pen + "_tip2 z"];
    end

    % Increment counter to see if we use pen1 or pen2
    groupOf4Counter = groupOf4Counter + 1;
   
    % Find mean of the position data
    xPosMean(loopCounter) = mean(dataFile{:, searchTerms(1)});
    zPosMean(loopCounter) = mean(dataFile{:, searchTerms(2)});   
    
    % Increment loop counter
    loopCounter = loopCounter + 1;
end

sprintf("All done collecting x and z data")

% Create output file name and headers
meanFile = "CalPoints_BM_PMS_R_" + participantNum + csvFileExtension;
headers = ["Point 1 x (end),Point 1 z (end),Origin x (start),Origin z (start),Point 3 x,Point 3 z,Origin x (Pen2_tip2),Origin z (Pen2_tip2)"];

% Open file and write headers to it
outputFile = fopen(meanFile, 'w');
fprintf(outputFile, '%s\n', headers);

% Input data into the file
i = 1;
while i-1 < length(xPosMean)
    inputRow = [xPosMean(i), zPosMean(i), xPosMean(i+1), zPosMean(i+1),...
        xPosMean(i+2), zPosMean(i+2), xPosMean(i+3), zPosMean(i+3)];
    inputRow = strjoin(string(inputRow), ","); 
    fprintf(outputFile, "%s\n", inputRow);
    i = i + 4;
end

% Close File
fclose(outputFile)