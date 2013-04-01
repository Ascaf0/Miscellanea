#!/bin/bash

#Author: acsaf
#Licene: GPL-3.0+
#Disclaimer: use this script at your own risk
# susewiki-translate a script to retrieve a source openSUSE mwiki page -in lang XY- and (optionally) its translated version
# -in lang MN- in order to start translating/update from lang XY to lang MN. It works on XY.opensuse.org Wiki articles,
# but should be easy to adapt the script to other domains.

Usage() {
echo $0' [options] source [dest; def: same of source]
this script retrieve the source page from XY.opensuse.org/source
and save it in source.mwiki (while saving a pre-existent version in a backup file)
retrieve its translation MN.opensuse.org/destination
and save it in destination.MN.mwiki (while saving a pre-existent version in a backup file)
if destination is not existent (locally or remotely), copy source to destination.
Requires meld to properly side-by-side show and edit mwiki file
Requires kate to edit
Warning: Uses mediawiki API option action=raw therefore does not
dereference redir (or does not expand transclusion)
Then you can translate in your preferred language,
compare versions, or update them.
-----------------------------------------------------------------------
options:
 --clean: remove old time-versions
 --help: this help
 --source-lang xy (source-lang): default --source-lang en (as in http://en.opensuse.org/Help:Todo)
 --dest-lang mn (dest-lang): default --dest-lang it (as in http://it.opensuse.org/Portal:Wiki/Lavoro_da_fare)
-----------------------------------------------------------------------
examples:
 '$0' [namespace:]pagename[/subpage]
 '$0' [namespace:]pagename[/subpage] [namespace:]pagename[/subpage]
 '$0' [--source-lang en] [--dest-lang it] [namespace:]pagename[/subpage] [namespace:]pagename[/subpage]'
exit 0
}

exe_diff=meld
exe_edit=kate
wiki_dom=opensuse.org

[ $# -eq 0 ] && Usage

source_lang=en
dest_lang=it

while true
do
if [ "${1:0:2}" = '--' ]
then
  case "${1:2}" in
    source-lang) source_lang=${2}
    shift 2
      ;;
    dest-lang) dest_lang=${2}
    shift 2
      ;;
    help) Usage
      ;;
    clean) clean_f=true
    shift
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
sourceFM="$sourceF.${source_lang}.mwiki"
destFM="${2:-$sourceF}.${dest_lang}.mwiki"
destFM="${destFM//\//%2f}"
destF="${destFM%.${dest_lang}*}"

# retrieve source
# check if file esists on server...
wget --spider "http://${source_lang}.${wiki_dom}/index.php?title=${sourceF}&stable=0&redirect=no&action=raw" || exit 1
[ -f "$sourceFM" ] && {
[ "$clean_f" ] && rm "$sourceF".+\([0-9][0-9]\).${source_lang}.mwiki
sourceFM_old="$sourceF.$(date -u +%s).${source_lang}.mwiki"
cp "$sourceFM" "$sourceFM_old"
}
# NB: &stable=0&redirect=no should be superfluous (and useless)
wget -O "${sourceFM}" "http://${source_lang}.${wiki_dom}/index.php?title=${sourceF}&stable=0&redirect=no&action=raw" || exit 1

#retrieve destination
[ -f "$destFM" ] && {
[ "$clean_f" ] && rm "$destF".+\([0-9][0-9]\).${dest_lang}.mwiki
destFM_old="$destF.$(date -u +%s).${dest_lang}.mwiki"
cp "$destFM" "$destFM_old"
} || cp "$sourceFM" "$destFM" # we don't know yet if destFM exist on server, therefore copy source to destination...
# ...it will be overwritten if a remote copy of destination really exists
# check if file exists on server...
wget --spider "http://${dest_lang}.${wiki_dom}/index.php?title=${destF}&stable=0&redirect=no&action=raw" && \
wget -O "${destFM}" "http://${dest_lang}.${wiki_dom}/index.php?title=${destF}&stable=0&redirect=no&action=raw"

$exe_diff "$sourceFM_old" "$sourceFM" &
$exe_diff "$sourceFM" "$destFM" &
$exe_diff "$sourceFM_old" "$sourceFM" "$destFM" &
exec $exe_edit "$destFM"