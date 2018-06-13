workspace(name = "distroless-graalvm")

# Docker rules.
git_repository(
    name = "io_bazel_rules_docker",
    commit = "74441f0d7000dde42ce02c30ce2d1bf6c0c1eebc",
    remote = "https://github.com/bazelbuild/rules_docker.git",
)

load(
    "@io_bazel_rules_docker//docker:docker.bzl",
    "docker_pull",
    "docker_repositories",
)

docker_repositories()

new_http_archive(
    name = "dotnet",
    build_file = "experimental/dotnet/BUILD.dotnet",
    sha256 = "69ecad24bce4f2132e0db616b49e2c35487d13e3c379dabc3ec860662467b714",
    type = "tar.gz",
    urls = ["https://download.microsoft.com/download/5/F/0/5F0362BD-7D0A-4A9D-9BF9-022C6B15B04D/dotnet-runtime-2.0.0-linux-x64.tar.gz"],
)
