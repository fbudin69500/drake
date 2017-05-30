#!/usr/bin/env python

import re
import sys

def_re = re.compile("set\(FCL_(\w+_VERSION)\s+([0-9]+)")

defs = {}
with open(sys.argv[1]) as h:
    for l in h:
        m = def_re.match(l)
        if m is not None:
            defs[m.group(1)] = m.group(2)

content = """
{
  "Cps-Version": "0.8.0",
  "Name": "fcl",
  "Description": "Flexible Collision Library",
  "License": ["BSD License"],
  "Version": "%(MAJOR_VERSION)s.%(MINOR_VERSION)s.%(PATCH_VERSION)s",
  "Compat-Version": "%(MAJOR_VERSION)s.0.0",
  "Default-Components": [ ":config", ":fcl_h_genrule", ":fcl" ],
  "Components": {
    "fcl_h_genrule": {
      "Type": "interface",
      "Includes": [ "@prefix@/include/fcl" ]
    },
    "config": {
      "Type": "interface",
      "Includes": [ "@prefix@/include/fcl" ]
    },
    "fcl": {
      "Type": "dylib",
      "Location": "@prefix@/lib/libfcl.so",
      "Requires": [ ":fmt-header-only", ":config" ]
    }
  }
}
""" % defs

print(content[1:])
