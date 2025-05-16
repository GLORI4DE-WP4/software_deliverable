Notes on the content of this directory
--------------------------------------

This directory contains the data used by nwprun for the first part of scenario 3.

The necessary subdirectories are:

- archive
  in which the output of the data assimilation is stored

- gts_bufr_conv
  which contains the conventional observations to be assimilated

- hres_am_foricon
  the deterministic IFS forecast used for initialization

- ifsens_am_foricon
  the ensemble IFS forecast used for initialization of the enable members

- import_signal
  a directory which contains a series of subdirectories called "gts_bufr_conv", "hres_am_foricon", "ifsens_am_foricon".
  Each of them must have a file called "IMPORTED" for each file stored inside the other arkimet subdirectories.
  The "IMPORTED" files should be stored inside subdirectories named after the date and time (e.g. 202410180000).