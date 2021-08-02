#!/bin/bash
cd `dirname $0`
tclsh ../HolonCode/holoncode.tcl `basename $0 .command`.hdb &
