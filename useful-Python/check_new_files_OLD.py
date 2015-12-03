import os
import gzip
path = "<file path>"
to = "<copy to path>"
txtpath = "<path to check file>"

with open(txtpath+'\check.txt') as f:
	content = f.readlines()

for root, dir, files in os.walk(path, topdown=False):
    for file in files:
    	if file.endswith('gz'):
        	if file+'\n' not in content:
        		inF = gzip.open(root+'\\'+file, 'rb')
        		with open(to+'\\'+file[0:len(file)-3], 'wb') as outF:
					outF.write(inF.read())
					print file
					inF.close()
        		with open(txtpath+'\check.txt', 'a') as f:
        			f.writelines(file+'\n')