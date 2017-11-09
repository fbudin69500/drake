from __future__ import absolute_import, division, print_function
from os.path import dirname, join, pardir, realpath
from platform import python_version_tuple

# We specifically do this prior to loading any other pydrake modules, in order
# to get assertion configuration done as early as possible.
from . import common

from . import rbtree

from .pydrake_path import getDrakePath
