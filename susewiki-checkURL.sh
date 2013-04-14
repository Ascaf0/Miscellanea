#!/bin/bash

#Author: acsaf
#License: GPL-3.0+
#Disclaimer: use this script at your own risk
# susewiki-checkURL: check if openSUSE Wiki page actually exist on server
# otherwise, suggests English wikilink

Usage() {
echo $0' [options] source
this script check a URL openSUSE wiki for its existence on server
it uses default user $LANG for language to check against
Optionally you can pass the language you desire
If page does not exist the command will suggest: ":en:SOURCEPAGE"
-----------------------------------------------------------------------
options:
 --help: this help
 --source-lang xy (source-lang): default --source-lang $LANG (as in http://it.opensuse.org/Help:Todo)
-----------------------------------------------------------------------
examples:
 '$0' [namespace:]pagename[/subpage]
 '$0' [namespace:]pagename[/subpage]
 '$0' [--source-lang zh_tw] [namespace:]pagename[/subpage]'
exit 0
}

wiki_dom=opensuse.org

[ $# -eq 0 ] && Usage

source_lang=${LANG%%_*}

while true
do
if [ "${1:0:2}" = '--' ]
then
  case "${1:2}" in
    source-lang) source_lang=${2,,}
    shift 2
      ;;
    help) Usage
      ;;
    *) echo "Unknown option"
      exit 1
      ;;
  esac
else
  break
fi
done

[ $# -eq 0 ] && Usage

sourceF="${1// /_}"
# from ../subpage to ..%2f[ascii]subpage
sourceF="${sourceF//\//%2f}"

# check if file exists on server...
wget --spider "http://${source_lang}.${wiki_dom}/index.php?title=${sourceF}&stable=0&redirect=no&action=raw" || \
echo "Try using: \":en:$1\""