#!/usr/bin/env python

import re
import sys

def_re = re.compile("SET\(BULLET_VERSION\s([0-9]+).([0-9])([0-9])")
defs = {}
with open(sys.argv[1]) as h:
    for l in h:
        m = def_re.match(l)
        if m is not None:
            defs['VERSION_MAJOR'] = m.group(1)
            defs['VERSION_MINOR'] = m.group(2)
            defs['VERSION_PATCH'] = m.group(3)

content = """
{
  "Cps-Version": "0.8.0",
  "Name": "bullet",
  "Description": "Bullet 2.x official repository with optional experimental Bullet 3 GPU rigid body pipeline",
  "License":"zlib license",
  "Default-Components": [ ":bullet" ],
  "Components": {
    "bullet": {
      "Type": "dylib",
      "Location": "@prefix@/lib/libbullet.so"
    }
  },
  "X-CMake-Variables": {
    "BULLET_VERSION_STRING": "%(VERSION_MAJOR)s.%(VERSION_MINOR)s%(VERSION_PATCH)s"
  }
}
""" % defs

print(content[1:])
