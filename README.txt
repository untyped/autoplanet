====== AUTOPLANET ======

Dave Gurnell (dave at untyped)

Simple command line utility to help manage development links for PLaneT packages.
Here's how you use it:

  1. copy autoplanet.ss to ~/bin;

  2. edit the first line to point to your MzScheme installation;

  3. create a directory somewhere called something like "planetdev";

  4. populate this directory with suubdirectories for each development link you
     want to maintain, for example:

       planetdev/untyped/snooze.plt/1/5
       planetdev/schematics/schemeunit.plt/4/5

     (each directory has to be of the format owner/package.plt/major/minor)

  5. run "autoplanet.ss planetdev" on the command line.

Autoplanet will synchronize your PLaneT development links to the packages
found in the planetdev directory. It will ask you to confirm the changes
before it does anything.

If you don't want to type in the name of "planetdev" all the time, you can
set the $AUTOPLANET environment variable instead.
