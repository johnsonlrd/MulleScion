#!/usr/bin/env bash
#
#  run-test.sh
#  MulleObjC
#
#  Created by Nat! on 01.11.13.
#  Copyright (c) 2013 Mulle kybernetiK. All rights reserved.
#  (was run-mulle-scion-test)

set -m

# check if running a single test or all

executable=`basename $0`
executable=`basename $executable .sh`


VERBOSE="YES"

while [ $# -ne 0 ]
do
   case "$1" in
      -v|-vv|-vvv|-V) # not really the same :)
         VERBOSE="YES"
      ;;

      -q)
         VERBOSE="NO"
      ;;

      --path-prefix)
         shift # ignore argument
      ;;
      -*)
         echo "unknown option $1" >&2
         exit 1
      ;;

      *)
         break
      ;;
   esac
   shift
done

TEST="$1"
shift

trace_ignore()
{
  return 0
}

trap trace_ignore 5 6


# parse optional parameters
MULLE_SCION=`ls -1 "${PWD}/../build/mulle-scion" | tail -1 2> /dev/null`

if [ -z "${MULLE_SCION}" ]
then
   echo "mulle-scion can not be found ($PWD)" >&2
   exit 1
fi

DIR=`pwd`
shift

HAVE_WARNED="NO"
RUNS=0


search_plist()
{
   local plist
   local root

   dir=`dirname "$1"`
   plist=`basename "$1"`
   root="$2"

   while :
   do
      if [ -f "$dir"/"$plist" ]
      then
         echo "$dir/$plist"
         break
      fi

      if [ "$dir" = "$root" ]
      then
         break
      fi

      next=`dirname "$dir"`
      if [ "$next" = "$dir" ]
      then
         break
      fi
      dir="$next"
   done
}


relpath()
{
   python -c "import os.path; print os.path.relpath('$1', '$2')"
}


run()
{
   local template
   local plist
   local stdin
   local stdout
   local stderr
   local output
   local errput
   local random
   local fail
   local match

   template="$1"
   plist="$2"
   stdin="$3"
   stdout="$4"
   stderr="$5"

   random=`mktemp -t "mulle-scion-XXXX"`
   output="$random.stdout"
   errput="$random.stderr"
   errors=`basename $template .scion`.errors

   pwd=`pwd`
   pretty_template=`relpath "$pwd"/"$template" "$root"`
   if [ "$VERBOSE" = "YES" ]
   then
      echo "$pretty_template" >&2
   fi

   RUNS=`expr $RUNS + 1`

   # plz2shutthefuckup bash
   set +m
   set +b
   set +v
   # denied, will always print TRACE/BPT

   $MULLE_SCION "$template" "$plist" < "$stdin" > "$output" 2> "$errput"

   if [ $? -ne 0 ]
   then
      if [ ! -f "$errors" ]
      then
         echo "TEMPLATE CRASHED: \"$pretty_template\"" >& 2
         echo "DIAGNOSTICS:" >& 2
         cat  "$errput"
         exit 1
      else
         fail=0
         while read expect
         do
            match=`grep "$expect" "$errput"`
            if [ "$match" = "" ]
            then
               if [ $fail -eq 0 ]
               then
                  echo "TEMPLATE FAILED TO PRODUCE ERRORS: \"$pretty_template\"" >& 2
                  fail=1
               fi
               echo "   $expect" >&2
            fi
         done < "$errors"
         if [ $fail -eq 1 ]
         then
            exit 1
         fi
         rm "$output" "$errput" 2> /dev/null
         return 0
      fi
   else
      if [ -f "$errors" ]
      then
         echo "TEMPLATE FAILED TO CRASH: \"$pretty_template\"" >& 2
         echo "DIAGNOSTICS:" >&2
         cat  "$errput"
         exit 1
      fi
   fi


   if [ "$stdout" != "-" ]
   then
      result=`diff -q "$stdout" "$output"`
      if [ "$result" != "" ]
      then
         white=`diff -q -w "$stdout" "$output"`
         if [ "$white" != "" ]
         then
            echo "FAILED: \"$pretty_template\" produced unexpected output" >& 2
            echo "DIFF: ($stdout vs. $output)" >& 2
            diff -y "$stdout" "$output" >& 2
         else
            echo "FAILED: \"$pretty_template\" produced different whitespace output" >& 2
            echo "DIFF: ($stdout vs. $output)" >& 2
            od -a "$output" > "$output".actual.hex
            od -a "$stdout" > "$output".expect.hex
            diff -y "$output".expect.hex "$output".actual.hex >& 2
         fi

         echo "DIAGNOSTICS:" >& 2
         cat  "$errput"
         exit 2
      fi
   fi

   if [ "$stderr" != "-" ]
   then
      result=`diff "$stderr" "$errput"`
      if [ "$result" != "" ]
      then
         echo "WARNING: \"$pretty_template\" produced unexpected diagnostics ($errput)" >& 2
         echo "" >& 2
         diff "$stderr" "$errput" >& 2
         echo "DIAGNOSTICS:" >& 2
         cat  "$errput"
         exit 3
      fi
   fi
   rm "$output" "$errput" 2> /dev/null
}


run_test()
{
   local stdin
   local stdout
   local stderr
   local template
   local plist
   local root

   template="$1.scion"
   plist="$1.plist"
   root="$2"

   if [ ! -f "$plist" ]
   then
      start=`pwd`/default.plist
      plist=`search_plist "$start" "$root"`
      if [ "$plist" = "" ]
      then
         plist="none"
         if [ "$HAVE_WARNED" != "YES" ]
         then
            echo "warning: no default.plist found" >&2
            HAVE_WARNED="YES"
         fi
      fi
   fi

   stdin="$1.stdin"
   if [ ! -f "$stdin" ]
   then
      stdin="provide/$1.stdin"
   fi
   if [ ! -f "$stdin" ]
   then
      stdin="default.stdin"
   fi
   if [ ! -f "$stdin" ]
   then
      stdin="/dev/null"
   fi

   stdout="$1.stdout"
   if [ ! -f "$stdout" ]
   then
      stdout="expect/$1.stdout"
   fi
   if [ ! -f "$stdout" ]
   then
      stdout="default.stdout"
   fi
   if [ ! -f "$stdout" ]
   then
      stdout="-"
   fi

   stderr="$1.stderr"
   if [ ! -f "$stderr" ]
   then
      stderr="expect/$1.stderr"
   fi
   if [ ! -f "$stderr" ]
   then
      stderr="default.stderr"
   fi
   if [ ! -f "$stderr" ]
   then
      stderr="-"
   fi

   run "$template" "$plist" "$stdin" "$stdout" "$stderr"
}


scan_directory()
{
   local i
   local filename
   local root
   local dir

   root="$1"

   for i in [^_]*
   do
      if [ -d "$i" ]
      then
         dir=`pwd`
         cd "$i"
         scan_directory "$root"
         cd "$dir"
      else
         filename=`basename "$i" .scion`
         if [ "$filename" != "$i" ]
         then
            run_test "$filename" "$root"
         fi
      fi
   done
}


test_binary()
{
   local random
   local output
   local errput

   random=`mktemp -t "mulle-scion-XXXX"`
   output="$random.stdout"
   errput="$random.stderr"

   $MULLE_SCION > /dev/null 2>&1
   code=$?

   if [ $code -eq 127 ]
   then
      echo "$MULLE_SCION can not be run (missing shared library probably ($PWD, $PATH)" >&2
      exit 1
   fi

   if [ $code -ne 253 ]
   then
      echo "${MULLE_SCION} is wrong executable" >&2
      exit 1
   fi

   echo "using ${MULLE_SCION} to test" >&2
}


absolute_path_if_relative()
{
   case "$1" in
      .*)  echo `pwd`/"$1"
	   ;;
      *)   echo "$1"
	   ;;
   esac
}



trace_ignore()
{
  return 0
}


main()
{
   trap trace_ignore 5 6

   while [ $# -ne 0 ]
   do
      case "$1" in
         -q)
            VERBOSE="no"
         ;;

         -v)
            VERBOSE="yes"
         ;;

         --path-prefix)
            shift
         ;;

         -*)
            echo "unknown option \"$1\"" >&2 && exit 1
         ;;

         *)
            break
         ;;
      esac

      shift
   done


   TEST="$1"

   #
   # find executable
   #
   exe=`ls -1 ./bin/mulle-scion 2> /dev/null | tail -1`
   if [ ! -x "${exe}" ]
   then
      exe=`ls -1 ../?uild/Products/*/mulle-scion 2> /dev/null | tail -1`
      if [ ! -x "${exe}" ]
      then
         exe=`ls -1 ../?uild/*/mulle-scion 2> /dev/null | tail -1 2> /dev/null`
         if [ ! -x "${exe}" ]
         then
            exe=`ls -1 ../?uild*/mulle-scion 2> /dev/null | tail -1 2> /dev/null`
         fi
      fi
   fi


   if [ -x "${exe}" ]
   then
      MULLE_SCION="${exe}"
   else
      MULLE_SCION="`which mulle-scion`"
   fi

   if [ -z "${MULLE_SCION}" ]
   then
      echo "mulle-scion can not be found" >&2
      exit 1
   fi

   MULLE_SCION=`absolute_path_if_relative "${MULLE_SCION}"`

   DEPENDENCIES="`mulle-bootstrap paths dependencies 2> /dev/null`"
   if [ ! -z "${DEPENDENCIES}" ]
   then
      case "`uname`" in
         Darwin)
            DYLD_FALLBACK_FRAMEWORK_PATH="${DEPENDENCIES}/Frameworks"
            export DYLD_FALLBACK_FRAMEWORK_PATH
            echo "DYLD_FALLBACK_FRAMEWORK_PATH='${DEPENDENCIES}/Frameworks'" >&2
            ;;

         *)
            LD_LIBRARY_PATH="${DEPENDENCIES}/lib:${LD_LIBRARY_PATH}"
            export LD_LIBRARY_PATH
            echo "LD_LIBRARY_PATH='${DEPENDENCIES}/lib:${LD_LIBRARY_PATH}'" >&2
            ;;
      esac
   fi

   test_binary "$MULLE_SCION"

   DIR="`pwd -P`"

   HAVE_WARNED="no"
   RUNS=0

   if [ -z "$TEST" ]
   then
      scan_directory "$DIR"

      if [ "$RUNS" -ne 0 ]
      then
          echo "All tests ($RUNS) passed successfully"
      else
         echo "no tests found" >&2
         exit 1
      fi
   else
       local directory

       directory="`dirname "$TEST"`"
       if [ "${directory}" = "" ]
       then
          directory="."
       fi

       file=`basename "$TEST"`
       filename=`basename "$file" .scion`

       if [ "$file" = "$filename" ]
       then
          echo "error: template file must have .scion extension" >& 2
          exit 1
       fi

       if [ ! -f "$TEST" ]
       then
          echo "error: template file not found" >& 2
          exit 1
       fi

       old=`pwd`
       cd "${directory}"
       run_test "$filename" "${directory}"
       rval=$?
       cd "$old"
       exit $rval
   fi
}

main "$@"
