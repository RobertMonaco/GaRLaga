import csv
import matplotlib.pyplot as plt
import glob
from glob import glob
import numpy as np

def chunkItAvg(seq, num):
    avg = len(seq) / float(num)
    out = []
    last = 0.0

    while last < len(seq):
        out.append(sum(seq[int(last):int(last + avg)])/len(seq[int(last):int(last + avg)]))
        last += avg

    return out
def chunkIt(seq, num):
    avg = len(seq) / float(num)
    out = []
    last = 0.0

    while last < len(seq):
        out.append(seq[int(last):int(last + avg)])
        last += avg

    return out

files = glob("outputs/*.csv")
print(files)
for f in files:
    X = []
    y = []
    with open(f, 'r') as csvf:
        reader = csv.reader(csvf,delimiter=',')
        for row in reader:
            X.append(int(row[0]))
            y.append(int(row[2]))
    x_avg = chunkIt(X,1000)
    y_avg = chunkItAvg(y,1000)
    plt.plot(X,y)
plt.xlabel('Number of Actions')
plt.ylabel('Average Score')
plt.title('Figure 1')
plt.legend(['Run 0', 'Run 1', 'Run 2', 'Run 3', 'Run 4','Run 5'],loc="best")
plt.show()
    
    