#!/usr/bin/env python3

from os import listdir
from shutil import copy

for filename in listdir():
    if " " in filename:
        copy(filename, filename.replace(" ", "A"))
