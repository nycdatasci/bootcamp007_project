import os

file_dir = os.path.dirname(__file__)

print file_dir
dirname = os.path.dirname
print dirname(dirname(os.path.abspath(__file__)))
