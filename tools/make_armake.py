#!/usr/bin/env python3

import os
import subprocess
import sys

def main():
    projectroot = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    includepath = os.path.join(projectroot, "include")
    componentspath = os.path.join(projectroot, "addons")
    buildpath = os.path.join(projectroot, ".build")

    for component in os.listdir(componentspath):
        if os.path.isdir(os.path.join(componentspath, component)):
            try:
                subprocess.check_output([
                    "armake",
                    "build",
                    "-f",
                    "-i",
                    includepath,
                    "-x",
                    "*.md",
                    os.path.join(componentspath, component),
                    os.path.join(buildpath, "mfx_{}.pbo".format(component.lower()))
                ], stderr = subprocess.STDOUT)
            except:
                print("Failed to make {}.".format(component))
            else:
                print("Successfully made {}.".format(component))

if __name__ == "__main__":
    sys.exit(main())
