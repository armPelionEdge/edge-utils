#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#---------------------------------------------------------------------------------------------------------------------------
# getopts helpper utilities for cli options
#---------------------------------------------------------------------------------------------------------------------------


#/	Desc:	checks if an array contains an exact element
#/	Ver:	.1
#/	$1:		name passed array
#/	$2:		search text
#/	Out:	0|1
#/	Expl:	out=$(array_contains array string)
array_contains() { 
local array="$1[@]"
local seeking=$2
local in=0
for element in "${!array}"; do
	if [[ $element == $seeking ]]; then
		in=1
		break
	fi
done
echo $in
} #end_array_contains



#/	Desc:	validates field is accpetable in array and throws help error if not
#/	Ver:	.1
#/	$1:		namded array
#/	$2:		seeking value
#/	$3:		name1
#/	Out:	return 0 if all is ok
#/	Expl:	clihelp_validArgument <array> <argument>
clihelp_validArgument(){
	local array="$1[@]"
	local seeking="$2"
	local in=0
	local localfirstTrip=1;
	local fullray="< "
	for element in "${!array}"; do
		log debug "$element <> $seeking";
		if [[ "$element" == "$seeking" ]]; then
			in=1
		else
			if [[ $localfirstTrip -eq 1 ]]; then
				localfirstTrip=0;
				fullray=$fullray"$element "
			else
				fullray=$fullray"| $element "
			fi
		fi
	done
	if [[ $in -eq 0 ]]; then
		fullray=$fullray">"
		clihelp_displayHelp "$seeking is not a valid field. seeking:  $fullray"
	else
		return 0
	fi
} #end_clihelp_validateArgument


#/	Desc:	Gathers all the keys from the menu system and builds a proper string for getopts
#/	Ver:	.1	
#/	Out:	echo - switch_conditions
#/	Expl:	switch_conditions=$(clihelp_switchBuilder)
clihelp_switchBuilder(){
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
		fi
		double=""
		if [[ ${#KEY} -gt 1 ]]; then
			double=":"
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			myline=$myline$dKEY$double
		fi
	done
	echo "$myline"
} #end_clihelp_switchBuilder


#/	Desc:	Generates a menu based on a named template system
#/	Ver:	.1
#/  Global: declare -A hp=() assoiative array of switches
#/			exects an associateve array named hp.
#/			hp nomenclature hp[x] where x represents a switch
#/			and where hp[xx] represents a switch and varriable
#/	$1:		[error text]  OPTIONAL
#/	$2:		name1
#/	$3:		name1
#/	Out:	a help text for the cli
#/	Expl:	clihelp_displayHelp
clihelp_displayHelp(){
	if [[ "$1" != "" ]]; then
		echo -e "\nERROR: ${REV}${BOLD}$1${NORM}"
	fi
	echo -e \\n"Help documentation for ${BOLD}$0${NORM}"
	echo -e "${hp[description]}"
	echo -e "----------------------------------------------------------------------------------------"
	echo -e "${BOLD}Basic usage:${NORM}${BOLD} $0 ${NORM} ${hp[useage]}"
	etext=""
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
			if [[ ${KEY:0:1} = "e" ]]; then
				etext=$etext"${UND}${BOLD} Example:${NORM} $VALUE\n"
			fi
		fi
		if [[ ${#KEY} -gt 1 ]]; then
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			switches=$switches"${BOLD}-$dKEY${NORM} $VALUE\n"
		fi
	done  
	echo -e "$switches"  | sort -n -k1
	echo -e "$etext\n"
	exit 1
} #end_clihelp_displayHelp

# declare -A hp=(
# 	[description]="Updates a relay with a different firmware version (up and down)"
# 	[useage]="-options <[buildNo|buildURL|buildFile]>"
# 	[a]="advanced interactive mode"
# 	[bb]="specify the build branch -b <branchname>"
# 	[e1]="\t${BOLD}${UND}Update a Relay factory partition to Build 1.1.1 ${NORM}\n\t\t$0 -u factory  1.1.1 ${NORM}\n"
# 	)

# argprocessor(){
# 	switch_conditions=$(clihelp_switchBuilder)
# 	while getopts "$switch_conditions" flag; do
# 		case $flag in
# 			a);;
# 			#
# 			b);;
# 			#
# 			c);;
# 			#
# 			d);;
# 			#
# 			D);;
# 			#
# 			\?)  echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed.";clihelp_displayHelp;exit; ;;
# 			#
# 		esac
# 	done
# 	shift $(( OPTIND - 1 ));

# 	if [[ "$1" = "xxx" ]]; then
# 		:
# 	fi
# 	main $1
# } 


# if [[ "$#" -lt 1 ]]; then
# 	clihelp_displayHelp
# else
# 	argprocessor "$@"
# fi