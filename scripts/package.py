#!/usr/bin/env python3
"""Build a deterministic source release from a clean Git commit (no local files)."""
import argparse
import gzip
import hashlib
import io
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]


def package(root, output, expected_tag=None):
    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])
    if git("status", "--porcelain", "--untracked-files=no").strip():
        raise ValueError("Commit tracked changes before packaging a release")
    version = git("show", "HEAD:VERSION").decode().strip()
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        raise ValueError("VERSION must contain a stable semantic version")
    if expected_tag and expected_tag != "v" + version:
        raise ValueError("Tag does not match VERSION")
    prefix = "quick-ui-" + version
    archive = git("archive", "--format=tar", "--prefix=" + prefix + "/", "HEAD")
    # Reject unexpected links; all release paths must remain under the prefix.
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        for member in tar.getmembers():
            if not (member.isfile() or member.isdir()) or ".." in Path(member.name).parts:
                raise ValueError("Unsupported archive entry: " + member.name)
    output.mkdir(parents=True, exist_ok=True)
    destination = output / (prefix + ".tar.gz")
    with destination.open("wb") as stream:
        with gzip.GzipFile(filename="", mode="wb", fileobj=stream, mtime=0) as compressed:
            compressed.write(archive)
    checksum = hashlib.sha256(destination.read_bytes()).hexdigest()
    (output / "SHA256SUMS").write_text(checksum + "  " + destination.name + "\n")
    return destination


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "artifacts/release")
    parser.add_argument("--tag", help="Require this release tag to match VERSION")
    args = parser.parse_args()
    try:
        print(package(ROOT, args.output_dir, args.tag))
    except (ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, "Release packaging failed: {}\n".format(error))


if __name__ == "__main__":
    main()
