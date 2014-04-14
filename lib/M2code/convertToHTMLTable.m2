#!/usr/bin/env M2 --script

path = prepend(currentDirectory()|"lib/M2code", path)

if #scriptCommandLine != 1 then (
    stderr << "convertToHTMLTable.m2 <list of limit cycles>" << endl;
    exit(1);
    )

limitCycles = scriptCommandLine#1

needsPackage "solvebyGB"

stdio << gbTable limitCycles << endl;

