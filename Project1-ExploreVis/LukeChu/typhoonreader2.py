import re
from sys import argv

# assuming txt
filename = argv[1]
filename = filename.rstrip(".txt")

f = open(filename + ".txt", 'r')
f2 = open(filename + ".csv", 'w')
f3 = open(filename + "_header.csv", 'w')
data = f.readlines()

f2.write("IID,Time,Ind,Grade,Latitude,Longitude,Pressure,MaxWindSpd,DirLong50R,Short50R,DirLong30R,Short30R,Landfall\n")
f3.write("Ind,IID,NRow,TCID,IID2,Flag,TimeDiff,Name,Revise\n")
# strip end of line, it's there
for line in data:
    data_two = line.strip(" \r\n")
    # regular expression to remove extra whitespace
    data_two = re.sub(' +', ' ', data_two)
    data_three = data_two.split(' ')


    # 66666 is indicator of typhoon information line
    if data_three[0] == "66666":
        IID = data_three[1]
        # check if typhoon has a TCID, then a name
        # input data is formatted properly, otherwise these magic numbers(rip) won't work out
        # alternative is to use R or Pandas so we can specify via column names
        if len(data_three) < 9 :
            TCID = 'NA'
            data_three.insert(3, TCID)
            # remember we added one value
            if len(data_three) < 9:
                typhoon_name = "UNNAMED"
                data_three.insert(-1, typhoon_name)

        data_four = ','.join(data_three)
        f3.write(data_four + "\n")

    else:
        # explicitly write out years
        if int(data_three[0][0:2]) >50:
            data_three[0] = "19" + data_three[0]
        else:
            data_three[0] = "20" + data_three[0]

        data_three.insert(0, IID)
        data_four = ','.join(data_three)
        f2.write(data_four + "\n")


