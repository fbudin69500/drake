import os.path
import pydrake.common


def getDrakePath():
    return os.path.abspath(pydrake.common.GetDrakePath())
