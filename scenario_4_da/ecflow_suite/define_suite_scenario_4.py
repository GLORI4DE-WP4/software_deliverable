import datetime
import ecflow
import os
import sys
sys.path.append("/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/python_tools")
from custom_ecflow_tools import ModelSuite, read_command_line_args

#------------------------------------------------------------------
# Paths
base_dir = "/leonardo_work/DE360_GLORI/smr_prod/"
scenario_dir = os.path.join(base_dir, "scenarios/scenario_4_da")
ecflow_suite_dir = os.path.join(scenario_dir, "ecflow_suite")
venv_dir = os.path.join(base_dir, 'scenarios/tools/venv_ecflow')
bacy_code_dir = os.path.join(scenario_dir, "global/bacy")
#------------------------------------------------------------------

def create_suite(fc_date):
    suite = ecflow.Suite('scenario_4_da')

    # Set ECF_HOME where .ecf files are located
    suite.add_variable("ECF_HOME", os.path.join(ecflow_suite_dir, 'ecf_files'))
    
    # Set ECF_FILES for where scripts are stored
    suite.add_variable("ECF_FILES", os.path.join(ecflow_suite_dir, 'scripts'))

    # Finding the previous date for the "fc" files
    curr_datetime = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    prev_date_str = (curr_datetime - datetime.timedelta(minutes=90)).strftime('%Y%m%d%H%M%S')

    # Set date as a variable (FC_DATE) so it can be changed in the UI
    suite.add_variable("FC_DATE", fc_date)
    suite.add_variable("PREV_FC_DATE", prev_date_str)

    # Family for organization
    fam = ecflow.Family('ICON_global')
    
    # Task 1: Call BACY simulation cycle
    task_bacy_cycle = ecflow.Task('bacy_simulation_cycle')
    task_bacy_cycle.add_variable("CYCLE_DIR", os.path.join(bacy_code_dir, "modules/cycle"))

    # Add tasks to family
    fam.add_task(task_bacy_cycle)

    # Add family to suite
    suite.add_family(fam)

    return suite


def main():
    # Read variables from commad line
    args = read_command_line_args()
    fc_date = args.fc_date
    try:
        _date = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    except:
        print('ERROR: The datetime provided is not valid. Expected datetime in format YYYYMMDDHH.')
        return 1

    # Create the ModelSuite
    scenario_name = 'scenario_4_da'
    scenario = ModelSuite(scenario_name)
    suite = create_suite(fc_date)
    scenario.add_suite(suite)

    # Check and save the definition file
    scenario.check()
    output_fname = os.path.join(ecflow_suite_dir, f"GLORI4DE_{scenario_name}.def")
    scenario.write(output_fname)
    print(f'Suite for the date {fc_date} has been created.')
    return 0


if __name__ == "__main__":
    main()
