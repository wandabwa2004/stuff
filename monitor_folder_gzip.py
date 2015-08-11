
import sys
import time
import datetime
import logging
import os
from watchdog.observers import Observer
from watchdog.events import LoggingEventHandler
from watchdog.events import FileSystemEventHandler
import shutil
import gzip

os.chdir("<working directory path>")

class MyHandler(FileSystemEventHandler):
    patterns=['*.gz']

    def on_created(self, event):
        print "path: " + event.src_path
        print "is gzip file: {}".format(event.src_path.endswith('gz'))
        print "is IF True: {}".format(event.is_directory == False and event.src_path.endswith('gz') == True)
        if event.is_directory == False and event.src_path.endswith('gz') == True:
            inF = gzip.open(event.src_path, 'rb')
            outF = open(event.src_path[0:len(event.src_path)-3], 'wb')
            outF.write(inF.read())
            inF.close()
            outF.close()
            shutil.copyfile(event.src_path[0:len(event.src_path)-3], 
                "<path to new folder>\{name}" \
                .format(name=os.path.split(event.src_path[0:len(event.src_path)-3])[1])) 
            #print "COPIED FILE: {}".format(name=os.path.split(event.src_path[0:len(event.src_path)-3])[1]) 
            os.remove(event.src_path[0:len(event.src_path)-3])
            #    .format(name=os.path.split(event.src_path[0:len(event.src_path)-3])[1]))

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s - %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S')
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    #event_handler = LoggingEventHandler()
    event_handler = MyHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
