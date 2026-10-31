#!/usr/bin/env python3
"""Check the local release files without enabling the lock or installing SDDM."""

import configparser
import json
from pathlib import Path
import re
import struct
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def main():
    manifest = json.loads((ROOT / "manifest.json").read_text())
    assert manifest["schemaVersion"] == 1
    assert manifest["id"] == "waffles46.omaresistance"
    assert manifest["name"] == "OmaResistance"
    assert manifest["omarchy"]["clonedFrom"] == "omarchy.lock"
    assert manifest["entryPoints"]["service"] == "Service.qml"
    for name in ["LICENSE", "OMARCHY-LICENSE", "CREDITS.md", "preview.png",
                 "assets/login.gif", "assets/lock.gif", "docs/INSTALL.md",
                 "docs/SDDM.md", "docs/VALIDATION.md"]:
        assert (ROOT / name).is_file(), f"Missing release file: {name}"
    assert (ROOT / "LICENSE").read_text().startswith("MIT License\n")
    for path in ROOT.rglob("*"):
        if ".git" in path.parts or "previews" in path.relative_to(ROOT).parts:
            continue
        assert not path.is_symlink(), f"Plugin symlink: {path}"
    for doc in [ROOT / "README.md", ROOT / "CREDITS.md", *sorted((ROOT / "docs").glob("*.md"))]:
        text = doc.read_text()
        assert "/home/" not in text, f"Local home path in {doc.name}"
        for target in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", text):
            if target.startswith(("https://", "http://", "#")):
                continue
            target = target.split("#", 1)[0]
            assert (doc.parent / target).resolve().is_file(), f"Broken link in {doc.name}: {target}"
    metadata = configparser.ConfigParser()
    metadata.read(ROOT / "sddm-theme/metadata.desktop")
    section = metadata["SddmGreeterTheme"]
    assert section["Name"] == manifest["name"]
    assert section["Version"] == manifest["version"]
    assert section["Author"] == "Waffles46"
    assert section["QtVersion"] == "6"
    for name in ["login", "lock"]:
        path = ROOT / "assets" / f"{name}.gif"
        with path.open("rb") as file:
            header = file.read(10)
        assert header[:6] in [b"GIF87a", b"GIF89a"]
        width, height = struct.unpack("<HH", header[6:10])
        assert width == 960 and height > 0
        result = subprocess.run([
            "ffprobe", "-v", "error", "-count_frames", "-show_entries",
            "stream=nb_read_frames,duration", "-of", "json", str(path),
        ], check=True, capture_output=True, text=True)
        stream = json.loads(result.stdout)["streams"][0]
        assert int(stream["nb_read_frames"]) == 72
        assert float(stream["duration"]) == 6.0
        assert b"NETSCAPE2.0" in path.read_bytes(), f"Missing loop extension: {path.name}"
        print(f"{path.relative_to(ROOT)}: {width}x{height}, 72 frames, 6 seconds")
    print("Release files, metadata, documentation links, and GIFs passed.")
    print("Real authentication and owner confirmation remain separate release checks.")


if __name__ == "__main__":
    main()
