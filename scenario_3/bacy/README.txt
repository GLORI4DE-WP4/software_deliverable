Notes on the content of this directory
--------------------------------------

The "bacy" directory contains the BACY code and the scripts needed to define the ecflow suite that performs the forecast starting from the analysis created by nwprun.
It contains the following sub-directories:

- bacy_data
  containing constants (e.g. grids), initial conditions (inside the "data" directory), and boundary conditions (inside "boundary_data")

- lam
  containing the BACY code, pre-configured for the current scenario.
  It contains two important subdirectories:
  - bacy_remap
    to perform the remapping of the boundary conditions from IFS
  - bacy_more
    to perform the model run

- ecflow_suite
  containing the scripts and templates necessary to define the ecflow suite.