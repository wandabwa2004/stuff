#!/usr/bin/python

'''
A command line tool for processing usage files.
'''


import argparse
import gzip
import json
import os
from os import path
import urllib2
import logging
import shutil


log = logging.getLogger(__name__)



def get_processed_files(state_path):
    if path.exists(state_path):
        with open(state_path) as fle:
            return set((item.strip() for item in fle))
    else:
        log.debug('\nstate-file: %s does not exist, will create it\n', state_path)
        return set()


def get_unprocessed_files(source_dir, state_path):
    processed_files = get_processed_files(state_path)

    for root, _, files in os.walk(source_dir, topdown=False):
        for fle in files:
            name, ext = path.splitext(fle)

            if ext == '.gz':
                if fle not in processed_files:
                    yield (root, fle)


def extract_content(in_path, out_path):
    log.info('\n\nextracting %s -> %s\n', in_path, out_path)

    with gzip.open(in_path, 'rb') as in_file:
        with open(out_path, 'wb') as out_file:
            shutil.copyfileobj(in_file, out_file)


def record_file_processed(fle, state_path):
    with open(state_path, 'a') as state_fle:
        state_fle.write(fle + '\n');


def process_directory(source_dir, output_dir, state_path):
    log.info('\n\nprocessing %s\n\n', source_dir)

    unprocessed_items = get_unprocessed_files(source_dir, state_path)

    for (root, fle) in unprocessed_items:
        name = path.splitext(fle)[0]

        in_path = path.join(root, fle)
        out_path = path.join(output_dir, name)

        extract_content(in_path, out_path)

        record_file_processed(fle, state_path)


def main():
    parser = argparse.ArgumentParser(
        description="Process a directory containing usage data")

    parser.add_argument(
        '--src', help='source directory', required=True)
    parser.add_argument(
        '--dest', help='destination directory', required=True)

    parser.add_argument(
        '--log-level', help='logging level', default='DEBUG')

    parser.add_argument(
        '--history', help='history file location', default='DEBUG')

    args = parser.parse_args()

    logging.basicConfig(level=args.log_level)

    state_path = path.join(args.history, 'processed_items.txt')

    process_directory(args.src, args.dest, state_path)


if __name__ == "__main__":
    main()
