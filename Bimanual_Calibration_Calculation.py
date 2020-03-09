import os
from numpy import array
import csv
from statistics import mean
import pandas as pd

# Input participant code:
participantNum = input("Enter the participant code: ")
participantFile = "PMS_R_" + participantNum

# Set up pathing
dir_path = os.path.dirname(os.path.realpath(__file__))
participantFilePath = os.path.join(dir_path, participantFile)
bimanualFilePath = os.path.join(participantFilePath, "Bimanual")
calibrationFilePath = os.path.join(bimanualFilePath, "Calibration")

# Check that the file path exists
if(not os.path.exists(calibrationFilePath)):
    print("Calibration file folder does not exist")

# Go through all input data files, declare some constants before entering
trialNumberVect = list(range(10,400))
bimanualFileExtension = "_6d"
csvFileExtension = ".csv"
pen1 = "Pen1"
pen2 = "Pen2"
xCol = 0
yCol = 0
zCol = 0
groupOf4Counter = 1
headerLine = 5
searchTerms = []

# For all trials we get the means of the coords of the trials
xPosMean = []
zPosMean = []

for trial in trialNumberVect:
    # Create trial file name
    trialFile = participantFile + "_" + str(trial) + bimanualFileExtension + csvFileExtension

    if os.path.exists(os.path.join(calibrationFilePath, trialFile)):
        # Try to open file, if does not exist, tries to open the next file

        with open(os.path.join(calibrationFilePath, trialFile), "r" ) as csvFile:
            csvReader = csv.reader(csvFile, delimiter=',')
            lineCnt = 1

            # Construct strings that fill be search terms in the csv file, assume pen 1, change to pen if necessary
            pen = pen1
            searchTerms = [pen + "_tip x", pen + "_tip y", pen + "_tip z"]

            # File exists, see if it is the fourth trial of a group
            if groupOf4Counter % 4 == 0:
                pen = pen2
                searchTerms = [pen + "_tip2 x", pen + "_tip2 y", pen + "_tip2 z"]
            
            # Increment file number
            groupOf4Counter += 1

            # Each trial has a list of x & z position
            xPosList = []
            zPosList = []
           
            # Find correct column for each search term
            for row in csvReader:
                if lineCnt == headerLine:
                    # Determine which columns have the pen x, y, and z coords
                    xCol = row.index(searchTerms[0])
                    zCol = row.index(searchTerms[2])
                elif lineCnt > headerLine:
                    # Below the headers will be the values for each x&z position
                    xPosList += [float(str(row[xCol]))]
                    zPosList += [float(str(row[zCol]))]
                
                lineCnt += 1

            # Find Mean of x and z columns
            xPosMean += [mean(xPosList)]
            zPosMean += [mean(zPosList)]
    else:
        pass

print("Done collecting x and z position data")

# Store means in new csv_File
meanFile = "CalPoints_BM_PMS_R_" + participantNum + csvFileExtension
headers = ['Point 1 x (end)','Point 1 z (end)','Origin x (start)','Origin z (start)','Point 3 x','Point 3 z','Origin x (Pen2_tip2)','Origin z (Pen2_tip2)']

with open(os.path.join(participantFilePath, meanFile), mode="w") as csvFile:
    meanFileWriter = csv.writer(csvFile, lineterminator = '\n')
    
    # Write headers
    meanFileWriter.writerow(headers)

    # Input data
    i = 0
    while i < len(xPosMean):
        inputRow = [xPosMean[i], zPosMean[i], xPosMean[i+1], zPosMean[i+1], xPosMean[i+2], zPosMean[i+2], xPosMean[i+3], zPosMean[i+3]]
        meanFileWriter.writerow(inputRow)
        i+=4