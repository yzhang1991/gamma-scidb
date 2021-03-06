#!/bin/bash
# Copyright (C) 2013-2018 Yiqun Zhang <contact@yzhang.io>
# All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [[ $# -eq 0 ]]; then
    echo -e "Usage: scidbtime [AFL]\n       or\n       scidbtime [AFL] [output template]"
    exit
fi
port=1239
if [[ $# -eq 1 ]]; then
    # this is the old version of scidbtime
    # it just execute the command and give out the time
    /usr/bin/time -f "%e seconds" iquery -anp $port -q "$1"
elif [[ $# -eq 2 ]]; then
    # the new version of scidbtime accepts 2 args,
    # after the command is executed and time is returned, 
    # it can generate the output according to the given format.
    # %t will be replaced by the execution time.
    t=$( { /usr/bin/time -f "%e" iquery -anp $port -q "$1" > /dev/null; } 2>&1 )
    output=$(echo -n $2 | sed "s#%t#"$t"#g")
    echo -ne "$output"
fi
