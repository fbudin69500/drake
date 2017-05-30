#!/usr/bin/env python

import re
import sys

def_re = re.compile("set\(TINYOBJLOADER_VERSION\s+([0-9]+).([0-9]+).([0-9]+)")

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
  "Name": "tinyobjloader",
  "Description": "Tiny but powerful single file wavefront obj loader ",
  "License": ["The MIT License (MIT)"],
  "Version": "%(VERSION_MAJOR)s.%(VERSION_MINOR)s.%(VERSION_PATCH)s",
  "Compat-Version": "%(VERSION_MAJOR)s.0.0",
  "Default-Components": [ ":tinyobjloader" ],
  "Components": {
    "tinyobjloader": {
      "Type": "dylib",
      "Location": "@prefix@/lib/libtinyobjloader.so"
    }
  },
  "X-CMake-Variables": {
    "TINYOBJLOADER_VERSION": "%(VERSION_MAJOR)s.%(VERSION_MINOR)s.%(VERSION_PATCH)s"
  }
}
""" % defs

print(content[1:])
