#!/bin/bash

# = = = = = = = = =  = = = = = = = = = = = = = = = = = = = = = = = = = = #
#  Program:  Y.F(ortran).S(ource).F(ormatter)                            #
#                                                                        #
#  Purpose: Provide and automatic approach for formatting                #
#  fortran sources according to YF's standards                           #
#                                                                        #
#  Standard:                                                             #
#  See full description >>> ...                                          #
#                                                                        #
#  Standards addressed by this script:                                   #
#      - Every Fortran keyword in upper case                             #
#      - Spaces around operators                                         #
#      - Tabs replaced by 4 spaces                                       #
#      - Spaces before parenthesis                                       #
#                                                                        #
#  Standards NOT adressed by this script                                 #
#      - Blocks alignments                                               #
#      - Spaces in function calls                                        #
#                                                                        #
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =  #

#==================================================== #
#             INIIT  & CHECKS                         #
#==================================================== #

# Checking sed and awk version
if [ ! "$(sed --version|head -n 1)" == 'sed (GNU sed) 4.2.2' ] || [ ! "$(awk --version|head -n 1)" == 'GNU Awk 4.0.2' ]
then 
    printf "You're using: \n Sed:  %s \n Awk: %s \n" "$(sed --version|head -n1)" "$(awk --version|head -n 1)"
    printf "Recommended versions are: \n Sed:  %s \n Awk: %s \n" "(GNU sed) 4.2.2" "GNU Awk 4.0.2" 
    printf "Wish to continue ? \n"
    read yesno
    case ${yesno} in
       [Yy][Ee][Ss]|[Yy]) echo "Use with caution ... " ;;
       *) exit 1 ;;
    esac
fi

# Some vars
madecorrections=0
function_header='header_function.txt'
subroutine_header='header_subroutine.txt'

# Deletes output directory if already existing 
[ -d CORRECTED ] && rm -rf corrected

#==================================================== #
#           FORMATTING SOURCES                        #
#==================================================== #

# Gets arguments and works ...
#
for file in $@ 
do

   # Systematically creates a copy of input file
   mkdir -p CORRECTED/$(dirname ${file})
   filenew="CORRECTED/${file}"
   cp -f ${file} ${filenew}

   printf "Working on file %-s \n" "$file"

   case ${filenew} in
      *.[HhFf]|*.*90|*.inc)

             # Suppresses whitespaces at the end of lines
             printf "\t - Deleting whitespaces at the end of lines \n"
             sed -e "s/[ \t]*$//g" \
                 -e "s/^ *!/!/g" \
                 -i ${filenew}

             # Replace leading tabs by 4 spaces 
             # Alternative version : expand -i -t 4 ${filenew} | sponge out
             # (Sponge belongs to moreutils)
             printf "\t - Replacing tabs by 4 spaces \n"
             expand -i -t 4 ${filenew} > tmp_file
             mv tmp_file ${filenew}

             # CONTROL STRUCTURES are converted to UPPER_CASE
             printf "\t - Making control structures UPPER_CASE \n"
             sed -e "s/^\( *\)[Ee][Nn][Dd] *[Dd][Oo]\b/\1END DO/g" \
                 -e "s/^\( *\)[Ee][Nn][Dd] *[Ii][Ff]\b/\1END IF/g" \
                 -e "s/^\( *[0-9]* *\)[Dd][Oo]\b/\1DO/g" \
                 -e "s/^\( *[0-9]* *\)[Dd][Oo] *[Ww][Hh][Ii][Ll][Ee]\b/\1DO WHILE/g" \
                 -e "s/^\( *[0-9]* *\)[Ii][Ff] *(/\1IF (/g" \
                 -e "s/^\( *\)[Ee][Ll][Ss][Ee] *[Ii][Ff] *(/\1ELSE IF (/g" \
                 -e "s/^\( *\)[Ee][Ll][Ss][Ee]\b/\1ELSE/g" \
                 -e "s/\(^[^\!]*\)) *[Tt][Hh][Ee][Nn]\b/\1) THEN/g" \
                 -e "s/^\( *\)[Ee][Nn][Dd]\b/\1END/g" \
                 -i ${filenew}

             # FORTRAN KEYWORDS are converted to UPPER_CASE
             printf "\t - Making other Fortran keywords UPPER_CASE \n"
             sed -e "s/^\( *[0-9]* *\)[Cc][Aa][Ll][Ll]\b */\1CALL /g" \
                 -e "s/^\( *[0-9]* *\)\b[Cc][Oo][Nn][Tt][Ii][Nn][Uu][Ee]\b/\1CONTINUE/g" \
                 -e "s/\(^ *\)\b[Ss][Tt][Oo][Pp]\b/\1STOP/g" \
                 -e "s/\(^ *\)\b[Pp][Aa][Uu][Ss][Ee]\b/\1PAUSE/g" \
                 -e "s/\b[Rr][Ee][Ww][Ii][Nn][Dd]\b/REWIND/g" \
                 -e "s/\(^ *\)[Ii][Mm][Pp][Ll][Ii][Cc][Ii][Tt] *[Nn][Oo][Nn][Ee]\b/\1IMPLICIT NONE/g" \
                 -e "s/\(^ *\)[Ii][Mm][Pp][Ll][Ii][Cc][Ii][Tt]\b/\1IMPLICIT/g" \
                 -e "s/\(^ *\)[Pp][Rr][Oo][Gg][Rr][Aa][Mm]\b/\1PROGRAM/g" \
                 -e "s/\(^ *\)[Ee][Nn][Dd] *[Pp][Rr][Oo][Gg][Rr][Aa][Mm] */\1END PROGRAM /g" \
                 -e "/^[^']*$/ s/\(^[^\!]*\)\b[Ss][Uu][Bb][Rr][Oo][Uu][Tt][Ii][Nn][Ee]\b */\1SUBROUTINE /g" \
                 -e "s/\(^ *\&* *\)[Pp][Aa][Rr][Aa][Mm][Ee][Tt][Ee][Rr]\b/\1PARAMETER/g" \
                 -e "/^[^']*$/ s/\(^[^\!]*, *\)[Pp][Aa][Rr][Aa][Mm][Ee][Tt][Ee][Rr]\b/\1PARAMETER/g" \
                 -e "s/\(^ *\)\b[Dd][Ee][Aa][Ll][Ll][Oo][Cc][Aa][Tt][Ee] *( */\1DEALLOCATE ( /g" \
                 -e "s/\(^ *\)\b[Aa][Ll][Ll][Oo][Cc][Aa][Tt][Ee] *( */\1ALLOCATE ( /g" \
                 -e "s/\(^[^\!]*\)\b[Aa][Ll][Ll][Oo][Cc][Aa][Tt][Ee][Dd] *( */\1ALLOCATED ( /g" \
                 -e "s/\(^[^\!]*\)\b[Aa][SS][Ss][Oo][Cc][Ii][Aa][Tt][Ee][Dd] *( */\1ASSOCIATED ( /g" \
                 -e "s/\(^[^\!]*\)\b[Ll][Ee][Nn]\b/\1LEN/g" \
                 -e "s/ *( *[Ll][Ee][Nn] *= *\(\b[^)]*\b\) *)/(LEN=\1)/g" \
                 -e "s/\(^[^\!]*\)\b[Ii][Nn][Dd][Ex][Xx]\b/\1INDEX/g" \
                 -e "s/\(^[^\!]*\)[Aa][Ll][Ll][Oo][Cc][Aa][Tt][Aa][Bb][Ll][Ee]\b/\1ALLOCATABLE/g" \
                 -e "s/\(^[^\!]*\)[Dd][Ii][Mm][Ee][Nn][Ss][Ii][Oo][Nn] *( */\1DIMENSION(/g" \
                 -e "s/\(^ *\&* *\)[Ii][Nn][Tt][Ee][Gg][Ee][Rr]\b/\1INTEGER/g" \
                 -e "s/\(, *\)[Ii][Nn][Tt][Ee][Gg][Ee][Rr]\b/\1INTEGER/g" \
                 -e "/implicit/ s/[Ii][Nn][Tt][Ee][Gg][Ee][Rr]\b/INTEGER/g" \
                 -e "s/\(^ *\&* *\)[Cc][Oo][Mm][Pp][Ll][Ee][Xx]\b/\1COMPLEX/g" \
                 -e "s/\(, *\)[Cc][Oo][Mm][Pp][Ll][Ee][Xx]\b/\1COMPLEX/g" \
                 -e "/implicit/ s/[Cc][Oo][Mm][Pp][Ll][Ee][Xx]\b/COMPLEX/g" \
                 -e "s/\(^ *\&* *\)[Cc][Hh][Aa][Rr][Aa][Cc][Tt][Ee][Rr]\b/\1CHARACTER/g" \
                 -e "s/\(, *\)[Cc][Hh][Aa][Rr][Aa][Cc][Tt][Ee][Rr]\b/\1CHARACTER/g" \
                 -e "s/\(^ *\&* *\)[Ll][Oo][Gg][Ii][Cc][Aa][Ll]\b/\1LOGICAL/g" \
                 -e "s/\(, *\)[Ll][Oo][Gg][Ii][Cc][Aa][Ll]\b/\1LOGICAL/g" \
                 -e "s/\(^ *\&* *\)[Rr][Ee][Aa][Ll]\b/\1REAL/g" \
                 -e "s/\(, *\)[Rr][Ee][Aa][Ll]\b/\1REAL/g" \
                 -e "/implicit/ s/\b[Rr][Ee][Aa][Ll]\b/REAL/g" \
                 -e "s/\(^ *\&* *\)[Dd][Oo][Uu][Bb][Ll][Ee] *[Pp][Rr][Ee][Cc][Ii][Ss][Ii][Oo][Nn]\b/\1DOUBLE PRECISION/g" \
                 -e "s/\(, *\)[Dd][Oo][Uu][Bb][Ll][Ee] *[Pp][Rr][Ee][Cc][Ii][Ss][Ii][Oo][Nn]\b/\1DOUBLE PRECISION/g" \
                 -e "/implicit/ s/[Dd][Oo][Uu][Bb][Ll][Ee] *[Pp][Rr][Ee][Cc][Ii][Ss][Ii][Oo][Nn]\b/DOUBLE PRECISION/g" \
                 -e "s/\(^ *\)[Ii][Nn][Tt][Rr][Ii][Nn][Ss][Ii][Cc]\b/\1INTRINSIC/g" \
                 -e "s/\(^ *\)[Rr][Ee][Tt][Uu][Rr][Nn]\b/\1RETURN/g" \
                 -e "s/\(^[^\!]*\)\b[Kk][Ii][Nn][Dd]\b/\1KIND/g" \
                 -e "s/ *( *[Kk][Ii][Nn][Dd] *( *\(\b[^)]*\b\) *) *)/(KIND(\1))/g" \
                 -e "s/\(^ *\)[Uu][Ss][Ee]\b */\1USE /g" \
                 -e "s/\(^ *\)[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee]\b/\1INTERFACE/g" \
                 -e "s/\(^[^\!]*\)[Ii][Nn][Tt][Ee][Nn][Tt] *( */\1INTENT(/g" \
                 -e "s/\(^[^\!]*\)[Ii][Nn][Tt][Ee][Nn][Tt]( *[Ii][Nn] *)/\1INTENT(IN)/g" \
                 -e "s/\(^[^\!]*\)[Ii][Nn][Tt][Ee][Nn][Tt]( *[Oo][Uu][Tt] *)/\1INTENT(OUT)/g" \
                 -e "s/\(^[^\!]*\)[Ii][Nn][Tt][Ee][Nn][Tt]( *[Ii][Nn][Oo][Uu][Tt] *)/\1INTENT(INOUT)/g" \
                 -e "s/\(^[^\!]*\)intent( *[Ii][Nn] *)/\1INTENT(IN)/g" \
                 -e "s/\(^[^\!]*\)intent( *[Oo][Uu][Tt] *)/\1INTENT(OUT)/g" \
                 -e "s/\(^[^\!]*\)intent( *[Ii][Nn][Oo][Uu][Tt] *)/\1INTENT(INOUT)/g" \
                 -e "s/\b[Hh][Ii][Dd]_[Tt]\b/HID_T/g" \
                 -e "s/\b[Hh][Ss][Ii][Zz][Ee]_[Tt]\b/HSIZE_T/g" \
                 -e "s/\b[Ss][Ii][Zz][Ee]_[Tt]\b/SIZE_T/g" \
                 -e "s/\(^ *\)\b[Ss][Aa][Vv][Ee]\b/\1SAVE/g" \
                 -e "s/\(^ *\)\b[Dd][Aa][Tt][Aa]\b\( *[^(]\)/\1DATA\2/g" \
                 -e "s/\(^ *\)\b[Cc][Oo][Mm][Mm][Oo][Nn]\b/\1COMMON/g" \
                 -e "s/\(^ *\)\b[Ii][Nn][Cc][Ll][Uu][Dd][Ee]\b/\1INCLUDE/g" \
                 -e "s/\(^ *\)\b[Cc][Oo][Nn][Tt][Aa][Ii][Nn][Ss]\b/\1CONTAINS/g" \
                 -e "s/\(^ *\)\b[Mm][Oo][Dd][Uu][Ll][Ee]\b/\1MODULE/g" \
                 -e "s/\(^ *\)\b[Ee][Qq][Uu][Ii][Vv][Aa][Ll][Ee][Nn][Cc][Ee]\b/\1EQUIVALENCE/g" \
                 -e "s/\(^ *\)[Tt][Yy][Pp][Ee]\b/\1TYPE/g" \
                 -e "s/\(^ *\)[Ee][Nn][Dd] *[Tt][Yy][Pp][Ee]\b/\1END TYPE/g" \
                 -e "s/\(^ *\)[Cc][Ll][Oo][Ss][Ee] *(/\1CLOSE (/g" \
                 -e "s/\(^ *\)[Oo][Pp][Ee][Nn] *(/\1OPEN (/g" \
                 -e "s/\(^ *\)[Ww][Rr][Ii][Tt][Ee] *(/\1WRITE (/g" \
                 -e "s/\(^ *\)[Ii][Nn][Qq][Uu][Ii][Rr][Ee] *(/\1INQUIRE (/g" \
                 -e "s/\(^ *\)[Pp][Oo][Ii][Nn][Tt][Ee][Rr]\b/\1POINTER/g" \
                 -e "/^[^']*$/ s/\(^[^\!]*, *\)[Pp][Oo][Ii][Nn][Tt][Ee][Rr]\b/\1POINTER/g" \
                 -e "/^[^']*$/ s/\(^[^\!]*, *\)[Tt][Aa][Rr][Gg][Ee][Tt]\b/\1TARGET/g" \
                 -e "s/\(^ *\)[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn] */\1FUNCTION /g" \
                 -e "s/\(^ *\)[Ee][Nn][Dd] *[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn] */\1END FUNCTION /g" \
                 -i ${filenew}

             ## OPERATORS 
             #printf "\t - Formatting operators \n"
             #sed -e "s/ *>= */ .GE. /g" \
             #    -e "s/ *> */ .GT. /g" \
             #    -e "s/ *<= */ .LE. /g" \
             #    -e "s/ *< */ .LT. /g" \
             #    -e "s/ *== */ .EQ. /g" \
             #    -e "s/ *\/= */ .NE. /g" \
             #    -i ${filenew}

             # SPECIAL CHARACTERS:
             # # Variable declaration : puts exactly one space before and after ::
             printf "\t - Formatting variable declarations \n"
             sed -i "s/ *:: */ :: /g" ${filenew}

             # Removes whitespaces before parenthesis
             # Example : func (x,y,z) ==> func(x,y,z)
             printf "\t - Formatting function calls \n"
             sed -E "s@([[:alnum:]]+)([[:blank:]]*)\((.+)@\1(\3@g" \
                 -i "${filenew}"
             ./format_parenthesis.sh ${filenew}

             # OPERATORS 
             printf "\t - Formatting operators \n"
             sed -e "s/ *>= */ .GE. /g" \
                 -e "s/ *> */ .GT. /g" \
                 -e "s/ *<= */ .LE. /g" \
                 -e "s/ *< */ .LT. /g" \
                 -e "s/ *== */ .EQ. /g" \
                 -e "s/ *\/= */ .NE. /g" \
                 -i ${filenew}

             # Isolated corrections
             sed -e "s/IF(/IF (/g" \
                 -e "s/WHILE(/WHILE (/g" \
                 -i ${filenew}

             # Adding some header
#             awk -v f1="$function_header" '/FUNCTION/{print f1;print;next}
             printf "\t - Adding some headers to functions and subroutines. \n"
             sed -i -e "/^[[:blank:]]*FUNCTION/r $function_header" "${filenew}"
             sed -i -e "/^[[:blank:]]*SUBROUTINE/r $subroutine_header" "${filenew}"
      ;;
   esac

   # Checks if something changed
   diff ${filenew} ${file} >& /dev/null
   if [ $? -ne 0 ]; then
      madecorrections=1
      printf "Corrected file : %s \n" "${file}"
   else
      printf "Found nothing to do for file : %s \n" "${file}"
   fi
done


if [ $((${madecorrections})) -eq 1 ]; then
    echo 'Modified files are in CORRECTED/*'
else
    echo 'Found nothing to do' 
fi


exit
