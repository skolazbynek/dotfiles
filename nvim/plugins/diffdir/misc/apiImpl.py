#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import filecmp

# Diff status codes
DIFF_SAME = 0
DIFF_DIFF = 1
DIFF_ONLY_L = 2
DIFF_ONLY_R = 3
DIFF_UNKNOWN = 4

# Node type codes
NODE_DIR = 'DD'
NODE_FILE = 'FF'

def list_entries(path, ignore_patterns):
    """Lists entries in a directory, filtering out ignored patterns."""
    entries = set()
    try:
        for name in os.listdir(path):
            if name not in ignore_patterns:
                entries.add(name)
    except OSError:
        pass  # Ignore permission errors, etc.
    return entries

def compare_dirs(pathL, pathR, ignore_patterns):
    """
    Recursively compares two directories and prints the differences.
    """
    entriesL = list_entries(pathL, ignore_patterns)
    entriesR = list_entries(pathR, ignore_patterns)

    all_entries = sorted(list(entriesL | entriesR))

    for name in all_entries:
        full_pathL = os.path.join(pathL, name)
        full_pathR = os.path.join(pathR, name)
        is_dirL = os.path.isdir(full_pathL)
        is_dirR = os.path.isdir(full_pathR)

        rel_path = name # For top-level, relative path is just the name

        if name in entriesL and name not in entriesR:
            node_type = NODE_DIR if is_dirL else NODE_FILE
            print(f"{DIFF_ONLY_L} {node_type} /{name}")
            if is_dirL:
                print_tree(full_pathL, f"/{name}", DIFF_ONLY_L, ignore_patterns)

        elif name not in entriesL and name in entriesR:
            node_type = NODE_DIR if is_dirR else NODE_FILE
            print(f"{DIFF_ONLY_R} {node_type} /{name}")
            if is_dirR:
                print_tree(full_pathR, f"/{name}", DIFF_ONLY_R, ignore_patterns)

        else: # In both
            if is_dirL and is_dirR:
                # For now, just mark dirs as same. Deeper comparison can be added.
                print(f"{DIFF_SAME} {NODE_DIR} /{name}")
                compare_recursive(full_pathL, full_pathR, f"/{name}", ignore_patterns)
            elif is_dirL or is_dirR:
                # Directory vs File conflict
                print(f"{DIFF_DIFF} {NODE_DIR if is_dirL else NODE_FILE} /{name}")
            else: # Both are files
                try:
                    if filecmp.cmp(full_pathL, full_pathR, shallow=False):
                        print(f"{DIFF_SAME} {NODE_FILE} /{name}")
                    else:
                        print(f"{DIFF_DIFF} {NODE_FILE} /{name}")
                except OSError:
                    print(f"{DIFF_UNKNOWN} {NODE_FILE} /{name}")


def compare_recursive(pathL, pathR, base_path, ignore_patterns):
    """Helper for recursive comparison."""
    entriesL = list_entries(pathL, ignore_patterns)
    entriesR = list_entries(pathR, ignore_patterns)
    all_entries = sorted(list(entriesL | entriesR))

    for name in all_entries:
        full_pathL = os.path.join(pathL, name)
        full_pathR = os.path.join(pathR, name)
        is_dirL = os.path.isdir(full_pathL)
        is_dirR = os.path.isdir(full_pathR)
        rel_path = os.path.join(base_path, name)

        if name in entriesL and name not in entriesR:
            node_type = NODE_DIR if is_dirL else NODE_FILE
            print(f"{DIFF_ONLY_L} {node_type} {rel_path}")
            if is_dirL:
                print_tree(full_pathL, rel_path, DIFF_ONLY_L, ignore_patterns)
        elif name not in entriesL and name in entriesR:
            node_type = NODE_DIR if is_dirR else NODE_FILE
            print(f"{DIFF_ONLY_R} {node_type} {rel_path}")
            if is_dirR:
                print_tree(full_pathR, rel_path, DIFF_ONLY_R, ignore_patterns)
        else:
            if is_dirL and is_dirR:
                print(f"{DIFF_SAME} {NODE_DIR} {rel_path}")
                compare_recursive(full_pathL, full_pathR, rel_path, ignore_patterns)
            elif is_dirL or is_dirR:
                print(f"{DIFF_DIFF} {NODE_DIR if is_dirL else NODE_FILE} {rel_path}")
            else:
                if filecmp.cmp(full_pathL, full_pathR, shallow=False):
                    print(f"{DIFF_SAME} {NODE_FILE} {rel_path}")
                else:
                    print(f"{DIFF_DIFF} {NODE_FILE} {rel_path}")

def print_tree(start_path, base_path, diff_status, ignore_patterns):
    """Recursively print a directory tree with a given diff status."""
    for root, dirs, files in os.walk(start_path):
        # Filter ignored directories
        dirs[:] = [d for d in dirs if d not in ignore_patterns]
        files[:] = [f for f in files if f not in ignore_patterns]

        for name in dirs:
            rel_path = os.path.join(base_path, os.path.relpath(os.path.join(root, name), start_path))
            print(f"{diff_status} {NODE_DIR} {rel_path}")
        for name in files:
            rel_path = os.path.join(base_path, os.path.relpath(os.path.join(root, name), start_path))
            print(f"{diff_status} {NODE_FILE} {rel_path}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python apiImpl.py <pathL> <pathR> [ignore1,ignore2,...]", file=sys.stderr)
        sys.exit(1)

    pathL = sys.argv[1]
    pathR = sys.argv[2]
    ignore_patterns = set(sys.argv[3].split(',') if len(sys.argv) > 3 and sys.argv[3] else [])

    # Print root node
    print(f"{DIFF_SAME} {NODE_DIR} /")
    compare_dirs(pathL, pathR, ignore_patterns)