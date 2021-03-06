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

if [ $# -ne 1 ]; then
  echo "Tell the dimensionality of the CSV file."
  echo "Usage: dim [CSV file name]"
  echo "Example: dim kdd.csv"
  exit
fi

row=`wc -l $1 | cut -d' ' -f1`
col=`head -n 1 $1 | sed "s/,/\n/g" | wc -l`
echo "File $1 has $row rows and $col columns."

