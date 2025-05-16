Notes on the content of this directory
--------------------------------------

Scenario 3 can be divided into two components: data assimilation and forecast.
The firs part uses the "nwprun" software, developed at Arpae, to assimilate conventional observations, and uses IFS forecasts as the starting point.
The "nwprun" software is available at:
https://github.com/ARPA-SIMC/nwprun.git

Once installed, it is necessary to copy/replace the files inside scenario_3/nwprun/conf with the ones from this repository.
Then, the script "suite_scenario_3_enda.py" inside scenario_3/nwprun/ecflow creates the ecflow suite.
The script must be run by first calling "ec_wrap" (in the same directory).
For example, the suite for the date 18/10/2024 can be created by executing:
./ec_wrap ./suite_scenario_3_enda.py --fc_date=20241018

The suite produces the analysis increments and the first guesses.
These files will be placed inside the "prod" directory, in a sub-directory whose name depends on the date and hour of the analysis.
At the hour 00:00 and 12:00, all needed files to initialize an ensemble forecast are also stored inside the directory "scenario_3/arkimet/archive".

The second part of the scenario is analogous to the previous ones: BACY is used to remap boundary conditions and perform the forecast.
The suite for this second part is created by the script scenario_3/bacy/ecflow_suite/define_scenario_3.py
This suite uses:
- the analysis increments produced by the first one,
- boundary conditions from the IFS forecast.
The configuration provided in this scenario produces by default a 20-members ensemble, which runs for a forecast lenght of 48 hours.

More information on how to run the scenario for an example case are provided in the tutorial document.
