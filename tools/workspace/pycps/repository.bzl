# -*- python -*-

load("@drake//tools/workspace:github.bzl", "github_archive")

def pycps_repository(
        name,
        mirrors = None):
    github_archive(
        name = name,
        repository = "mwoehlke/pycps",
        commit = "b571fa1e13f5ad00360d91847f8805cce73e2eaf",
        sha256 = "e4c7196e4c95b21a6b7befa19b721effcebaedda1ba2de4f6511c37ffd70fd67",  # noqa
        build_file = "@drake//tools/workspace/pycps:package.BUILD.bazel",
        mirrors = mirrors,
    )
