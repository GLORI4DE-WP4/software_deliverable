import datetime
import ecflow
import os
import sys
sys.path.append("/leonardo_work/DE360_GLORI/smr_prod/scenarios/tools/python_tools")
from custom_ecflow_tools import ModelSuite, read_command_line_args

#------------------------------------------------------------------
# Paths
base_dir = "/leonardo_work/DE360_GLORI/smr_prod/"
scenario_dir = os.path.join(base_dir, "scenarios/scenario_4_s3")
ecflow_suite_dir = os.path.join(scenario_dir, "ecflow_suite")
venv_dir = os.path.join(base_dir, 'scenarios/tools/venv_ecflow')
bacy_code_dir = os.path.join(scenario_dir, "global/bacy")
#------------------------------------------------------------------

def create_suite(fc_date):
    suite = ecflow.Suite('scenario_4_s3')

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

    # Task 1: Call the python script to download initial conditions
    task_download = ecflow.Task('download_from_s3')
    task_download.add_variable("ACTIVATE_PATH", os.path.join(venv_dir, "bin/activate"))
    task_download.add_variable("SUITE_DIR", ecflow_suite_dir)
    task_download.add_variable("PYTHON", os.path.join(venv_dir, "bin/python3"))
    task_download.add_variable("BUCKET", "bacy_icon_italy")
    task_download.add_variable("DEST", os.path.join(scenario_dir, "bacy_data/data"))
    task_download.add_variable("BOTO_CRED", os.path.join(ecflow_suite_dir, "scripts/cred.txt"))
    task_download.add_variable("VERBOSE", "True")

    # Task 2: Create symbolic link
    task_symlink = ecflow.Task('create_symlink')
    task_symlink.add_variable("ORIGIN_DIR", os.path.join(scenario_dir, f"bacy_data/data/{fc_date}"))
    task_symlink.add_variable("DEST_DIR", os.path.join(bacy_code_dir, f"data/{fc_date}"))
    
    # Task 3: Call BACY simulation cycle
    task_bacy_cycle = ecflow.Task('bacy_simulation_cycle')
    task_bacy_cycle.add_variable("CYCLE_DIR", os.path.join(bacy_code_dir, "modules/cycle"))

    # Add dependencies: tasks should run in sequence
    task_symlink.add_trigger("download_from_s3 == complete")
    task_bacy_cycle.add_trigger("create_symlink == complete")

    # Add tasks to family
    fam.add_task(task_download)
    fam.add_task(task_symlink)
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
    scenario_name = 'scenario_4_s3'
    scenario = ModelSuite(scenario_name)
    suite = create_suite(fc_date)
    scenario.add_suite(suite)

    # Check and save the definition file
    scenario.check()
    output_fname = os.path.join(ecflow_suite_dir, 'GLORI4DE_scenario_4.def')
    scenario.write(output_fname)
    print(f'Suite for the date {fc_date} has been created.')
    return 0


if __name__ == "__main__":
    main()
