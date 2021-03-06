#!/bin/bash

# Copyright (C) 2015 Yiqun Zhang <contact@yzhang.io>
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

if [ $# -ne 4 ]; then
  echo "This script is used to generate SciDB arrays with specified density."
  echo "Usage: gensparse [name] [n] [d] [density]"
  echo "Example: gensparse n100kd100den50 100000 100 0.5"
  echo "The dense version will be named as n100kd100den50_dense."
  echo "The sparse version will be named as n100kd100den50_sparse."
  exit
fi

if [ $(echo "$4<=1" | bc) -eq 0 -o $(echo "$4>=0" | bc) -eq 0 ]; then
  echo "Density value should be between 0 and 1."
  exit
fi

port=1239
chunksize=10000
rm gensparse.afl > /dev/null 2>&1
density=`echo "$4*1000" | bc`
echo "n = $2"
echo "d = $3"
echo "density = $4"
echo -e "Generating AFL file...\n"

echo "CREATE ARRAY ${1}_dense <val:double> [i=1:$2,${chunksize},0,j=1:$3,$3,0];" | tee -a gensparse.afl
echo "CREATE ARRAY ${1}_sparse <val:double> [i=1:$2,${chunksize},0,j=1:$3,$3,0];" | tee -a gensparse.afl
echo "store(build(${1}_dense, iif(random()%1000<${density}, random()%2000/20.0, 0)), ${1}_dense);" | tee -a gensparse.afl
echo "store(filter(${1}_dense, val<>0), ${1}_sparse);" | tee -a gensparse.afl

echo -e "\nExecuting..."
iquery -anp ${port} -q "remove(${1}_dense);" > /dev/null 2>&1
iquery -anp ${port} -q "remove(${1}_sparse);" > /dev/null 2>&1
iquery -anp ${port} -f gensparse.afl --ignore-errors
rm gensparse.afl > /dev/null 2>&1
echo "Done."

