#!/usr/bin/env python3
import sys
import csv
import numpy as np
#first argument is speg file
SPEG_file = sys.argv[1]
#argv are all the fil files
filfiles = sys.argv[2:]
success = True
with open(SPEG_file,'r') as speg:
    reader = csv.reader(speg,delimiter=',')
    for i,row in enumerate(reader):
        if i>0:
            #first line is a header
            #4 is group rank
            #16 is the peak_downfact
            #12 is the peak_DM
            #13 is peak_time
            #14 is peak_SNR
            group_rank = float(row[4])
            peak_time = str(int(float(row[13])*1000)/1000.0)
            if (group_rank<=2) & (group_rank>0):
                match = False
                for fil in filfiles:
                    if peak_time in fil:
                        #check if it has the 0
                        if "0.fil" in fil:
                            match = True
                            fil = fil.strip('0.fil')
                            #check if it has the 1
                            fil_1 = fil+'1.fil'
                            if fil_1 in filfiles:
                                #we're good, has both fil 0 and 1
                                pass
                            else:
                                success = False
                                # print(fil)
                                # sys.exit(1)
                        #repeat the excercise for the 1.fil files
                        if "1.fil" in fil:
                            match = True
                            fil = fil.strip('1.fil')
                            #check if it has the 1
                            fil_0 = fil+'0.fil'
                            if fil_0 in filfiles:
                                #we're good, has both fil 0 and 1
                                pass
                            else:
                                success = False
                                # print(fil)
                                # sys.exit(1)
                if not match:
                    success = False
                    # print(peak_time)
                    # print(group_rank)
if not success:
    sys.exit(1)