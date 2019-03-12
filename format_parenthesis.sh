#!/bin/bash

# = = = = = = = = =  = = = = = = = = = = = = = = = = = = = = = = = = = = #
#  Program:  format_parenthesis.sh                                       #
#                                                                        #
#  Parent: YFSF.sh                                                       #
#                                                                        #
#  Purpose: format function calls                                        #
#  fortran sources according to YF's standards                           #
#                                                                        #
#  Standard:                                                             #
#  function(x, y, z, t)                                                  #
#                                                                        #
#  Notes:                                                                #
#  Assumes the input files does containing things like function  (x...)  #
#  as YFSF has tackled this before                                       #
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  #

# INPUTS / OUTPUTS
in_file=$1
cpt=0
# Getting filename without extension
l_name=$(echo $in_file|awk -F "." '{print $1}')
# Output sed script
sed_script="$l_name"'.sed'

[ -f "$sed_script" ] && rm -f $sed_script

while read line
do
 
    ((cpt++))
    if [ -z "$(echo "$line")" ] || [ ! -z "$(echo "$line"|grep -E '^[[:space:]]*!')" ] 
    then 
        :	
    else
        # Gets what's between parenthesis and the function name
        in_par=$(echo $line|awk -F "[()]" '/\(/{print "(" $2 ")" }')
        func_name=$(echo $line|awk -F "[()]" '/\(/{print $1}')
        # Formats to my desired format
        in_par_mod=$(echo $line|awk -F "[()]" '/\(/{print $2}'|awk '{ gsub (" ", "", $0); print}'|awk 'BEGIN{FS=","; OFS=", "} {$1=$1; print "(" $0 ")"}')
        # Re-buils full patterns
        in_name=$func_name$in_par
        mod_name=$func_name$in_par_mod
        # Generating script to be launched 
        if [ ! -z "$in_name" ]
        then
        #    printf " Before : %-30s  After : %-30s \n" "$in_name" "$mod_name"
            printf "sed -i -e 's/%s/%s/g' %s \n " "$in_name" "$mod_name" "$in_file" >> "$sed_script"
        # else
        #    printf "Line contains nothing to change \n"
        fi
    fi
done < $in_file

chmod 750 $sed_script

$sed_script $in_file
