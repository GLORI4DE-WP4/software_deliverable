import datetime
import ecflow
import os
import sys

#------------------------------------------------------------------
# Paths
base_dir = "/leonardo_work/DE360_GLORI/smr_prod/"
scenario_dir = os.path.join(base_dir, "scenarios", "scenario_2_da")
ecflow_suite_dir = os.path.join(scenario_dir, "ecflow_suite")
tools_dir = os.path.join(base_dir, "scenarios", "tools")
venv_dir = os.path.join(tools_dir, "venv_ecflow")
bacy_lam_dir = os.path.join(scenario_dir, "lam", "bacy")
bacy_cycle_dir = os.path.join(bacy_lam_dir, "modules", "cycle")
bacy_data_dir = os.path.join(scenario_dir, "bacy_data")

# Loading additional Python tools
sys.path.append(os.path.join(tools_dir, "python_tools"))
from custom_ecflow_tools import ModelSuite, read_command_line_args
#------------------------------------------------------------------

def create_suite(scenario_name, fc_date):
    suite = ecflow.Suite(scenario_name)

    # Set ECF_HOME where .ecf files are located
    suite.add_variable("ECF_HOME", os.path.join(ecflow_suite_dir, 'ecf_files'))
    
    # Set ECF_FILES for where scripts are stored
    suite.add_variable("ECF_FILES", os.path.join(ecflow_suite_dir, 'scripts'))

    # Finding the previous date for the "fc" files
    curr_datetime = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    prev_date_str = (curr_datetime - datetime.timedelta(minutes=90)).strftime('%Y%m%d%H%M%S')

    # Set date as a variable (FC_DATE) so it can be changed in the UI
    suite.add_variable("FC_DATE", fc_date)

    # --- Family 1: ICON LAM ---
    fam_lam = ecflow.Family('ICON_lam')

    # Task 1: Run data assimilation cycle with BACY
    task_lam_cycle = ecflow.Task('lam_cycle')
    task_lam_cycle.add_variable("CYCLE_DIR", bacy_cycle_dir)

    # Add tasks to family
    fam_lam.add_task(task_lam_cycle)

    # Add families to suite
    suite.add_family(fam_lam)

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
    scenario_name = 'scenario_2_da'
    scenario = ModelSuite(scenario_name)
    suite = create_suite(scenario_name, fc_date)
    scenario.add_suite(suite)

    # Check and save the definition file
    scenario.check()
    output_fname = os.path.join(ecflow_suite_dir, f'GLORI4DE_{scenario_name}.def')
    scenario.write(output_fname)


if __name__ == "__main__":
    main()
