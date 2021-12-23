#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2019 Alessandro "Locutus73" Miele

# You can download the latest version of this script from:
# https://github.com/MiSTer-devel/Scripts_MiSTer

# Version 1.0 - 2019-05-13 - First commit



sleep 5
export PATH="/media/fat/Scripts:$PATH"
#stty 9600 -F /dev/ttyACM0 raw -echo
#bash -v </dev/ttyACM0 
#bash
stty 9600 -F /dev/ttyUSB0 raw -echo
#bash -v </dev/ttyUSB0 
bash </dev/ttyUSB0
#bash