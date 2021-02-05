# shaztools

bin/scene_chk.pl

>     # this script will validate all of the scene releases
>     # in current directory.
>     #
>     # usage: 
>     #   cd <directory containing scene releases>
>     #   ~/bin/scene_chk.pl
>     #
>     # it is a multi step process:
>     #
>     #    1. use crc32 value of file to get proper name from srrdb
>     #    2. rename file to match srrdb 
>     #    3. check resultant file against predb to see if it has been nuked
>     # 
>     # this does not remove any files, but if you have already renamed
>     # the file to get rid of the title, if applicable, do not re-run as it 
>     # revert them all back to the full name again
>     #
