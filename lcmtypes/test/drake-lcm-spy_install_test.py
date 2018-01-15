from __future__ import absolute_import, division, print_function

import os
import signal
import subprocess
import sys
import time
import unittest
import install_test_helper


class TestCommonInstall(unittest.TestCase):
    def testInstall(self):
        tmp_folder = "tmp"
        result = install_test_helper.install(tmp_folder,
                                             ['bin', 'lib', 'share'])
        self.assertEqual(None, result)
        executable_folder = os.path.join(tmp_folder, "bin")
        proc = subprocess.Popen([os.path.join(executable_folder,
                                 "drake-lcm-spy")])
        start = time.time()
        while time.time() - start < 2.0:
            time.sleep(0.5)
            ret = proc.poll()
            self.assertEqual(None, result)
        # time's up: kill the proc (and it's group):
        try:
            os.kill(proc.pid, signal.SIGTERM)
        except OSError as e:
            self.assertEqual("", e.strerror)
        self.assertEqual(-signal.SIGTERM, proc.wait())


if __name__ == '__main__':
    unittest.main()
