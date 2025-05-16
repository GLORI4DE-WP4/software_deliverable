import datetime
import ecflow
import os
import sys

#------------------------------------------------------------------
# Paths
base_dir = "/leonardo_work/DE360_GLORI/smr_prod/"
scenario_dir = os.path.join(base_dir, "scenarios", "scenario_1")
ecflow_suite_dir = os.path.join(scenario_dir, "ecflow_suite")
tools_dir = os.path.join(base_dir, "scenarios", "tools")
venv_dir = os.path.join(tools_dir, "venv_ecflow")
bacy_global_dir = os.path.join(scenario_dir, "global", "bacy")
bacy_lam_dir = os.path.join(scenario_dir, "lam", "bacy")
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
    suite.add_variable("PREV_FC_DATE", prev_date_str)

    # --- Family 1: ICON Global ---
    fam_global = ecflow.Family('ICON_global')

    # Task 1: Call the python script to download initial conditions
    task_download = ecflow.Task('download_from_s3')
    task_download.add_variable("ACTIVATE_PATH", os.path.join(venv_dir, "bin", "activate"))
    task_download.add_variable("SUITE_DIR", ecflow_suite_dir)
    task_download.add_variable("PYTHON", os.path.join(venv_dir, "bin", "python3"))
    task_download.add_variable("BUCKET", "bacy_icon_italy")
    task_download.add_variable("DEST", os.path.join(bacy_data_dir, "data"))
    task_download.add_variable("BOTO_CRED", os.path.join(ecflow_suite_dir, "scripts", "cred.txt"))
    task_download.add_variable("VERBOSE", "True")

    # Task 2: Create symbolic link
    task_symlink_input_global = ecflow.Task('create_symlink_input_global')
    task_symlink_input_global.add_variable("ORIGIN_DIR", os.path.join(bacy_data_dir, 
                                                                      "data", fc_date))
    task_symlink_input_global.add_variable("DEST_DIR", os.path.join(bacy_global_dir, "data", fc_date))

    # Task 3: Call BACY simulation cycle
    task_global_cycle = ecflow.Task('global_cycle')
    task_global_cycle.add_variable("CYCLE_DIR", os.path.join(bacy_global_dir, "modules", "cycle"))

    # Task 4: Generate initial analysis (in parallel with task 4)
    task_global_more_init = ecflow.Task('global_more_init_ana')
    task_global_more_init.add_variable("MORE_DIR", os.path.join(bacy_global_dir, "modules", "more"))

    # Task 5: Link boundary conditions into data folder
    task_move_and_link_output_bc = ecflow.Task('move_and_link_output_bc')
    task_move_and_link_output_bc.add_variable("ORIGIN_DIR", os.path.join(bacy_global_dir, "data", fc_date))
    task_move_and_link_output_bc.add_variable("DEST_DIR", os.path.join(bacy_data_dir, "boundary_data"))
    task_move_and_link_output_bc.add_variable("MORE_DIR", os.path.join(bacy_global_dir, "modules", "more"))

    # Add dependencies: tasks should run in sequence
    task_symlink_input_global.add_trigger("download_from_s3 == complete")
    task_global_cycle.add_trigger("create_symlink_input_global == complete")
    task_global_more_init.add_trigger("global_cycle == complete")
    task_move_and_link_output_bc.add_trigger("global_more_init_ana == complete")

    # Add tasks to family
    fam_global.add_task(task_download)
    fam_global.add_task(task_symlink_input_global)
    fam_global.add_task(task_global_cycle)
    fam_global.add_task(task_global_more_init)
    fam_global.add_task(task_move_and_link_output_bc)

    # --- Family 2: ICON LAM ---
    fam_lam = ecflow.Family('ICON_lam')
    fam_lam.add_trigger('ICON_global == complete')

    # Task 1: Create iodir_main directories for int2lm and more
    task_create_lam_dirs = ecflow.Task('create_lam_dirs')
    task_create_lam_dirs.add_variable("INT_DIR", os.path.join(bacy_lam_dir, "modules", "int2lm"))
    task_create_lam_dirs.add_variable("MORE_DIR", os.path.join(bacy_lam_dir, "modules", "more"))

    # Task 2: Link files from global to lam directory
    task_symlink_input_lam = ecflow.Task('create_symlink_input_lam')
    task_symlink_input_lam.add_variable("ORIGIN_DIR", os.path.join(bacy_data_dir, "boundary_data"))
    task_symlink_input_lam.add_variable("DEST_DIR", os.path.join(bacy_lam_dir, "data", fc_date, "FC"))

    # Task 3: Run prep_int2lm task
    task_lam_prep_int2lm = ecflow.Task('lam_prep_int2lm')
    task_lam_prep_int2lm.add_variable("INT_DIR", os.path.join(bacy_lam_dir, "modules", "int2lm"))
    task_lam_prep_int2lm.add_variable("INPUT_DATA_DIR", os.path.join(bacy_lam_dir, "data"))

    # Task 4: Run int2lm task
    task_lam_int2lm = ecflow.Task('lam_int2lm')
    task_lam_int2lm.add_variable("INT_DIR", os.path.join(bacy_lam_dir, "modules", "int2lm"))

    # Task 5: Run saveint2lm task
    task_lam_save_int2lm = ecflow.Task('lam_save_int2lm')
    task_lam_save_int2lm.add_variable("INT_DIR", os.path.join(bacy_lam_dir, "modules", "int2lm"))
    task_lam_save_int2lm.add_variable("LAM_DATA_DIR", os.path.join(bacy_data_dir, "boundary_data",
                                                                   fc_date))

    # Task 6: Run prep_more task
    task_lam_prep_more = ecflow.Task('lam_prep_more')
    task_lam_prep_more.add_variable("MORE_DIR", os.path.join(bacy_lam_dir, "modules", "more"))
    task_lam_prep_more.add_variable("LAM_DATA_DIR", os.path.join(bacy_data_dir, "boundary_data", fc_date))

    # Task 7: Link missing initialization
    task_symlink_missing_analysis = ecflow.Task('create_symlink_missing_analysis')
    task_symlink_missing_analysis.add_variable("MORE_INPUT_DIR", os.path.join(bacy_lam_dir, "modules",
                                                                         "more", "iodir_main", "input"))
    task_symlink_missing_analysis.add_variable("LAM_DATA_DIR", os.path.join(bacy_data_dir, "boundary_data",
                                                                            fc_date, f"{fc_date}0000", "main0000"))
    task_symlink_missing_analysis.add_variable("INT_OUTPUT_DIR", os.path.join(bacy_lam_dir, "modules",
                                                                         "int2lm", "iodir_main", "output"))

    # Task 8: Run more task
    task_lam_more = ecflow.Task('lam_more')
    task_lam_more.add_variable("MORE_DIR", os.path.join(bacy_lam_dir, "modules", "more"))

    # Task 9: Run save_more task
    task_lam_save_more = ecflow.Task('lam_save_more')
    task_lam_save_more.add_variable("MORE_DIR", os.path.join(bacy_lam_dir, "modules", "more"))
    task_lam_save_more.add_variable("LAM_DATA_DIR", os.path.join(bacy_lam_dir, "data", fc_date))

    # Add dependencies
    task_symlink_input_lam.add_trigger("create_lam_dirs == complete")
    task_lam_prep_int2lm.add_trigger("create_symlink_input_lam == complete")
    task_lam_int2lm.add_trigger("lam_prep_int2lm == complete")
    task_lam_save_int2lm.add_trigger("lam_int2lm == complete")
    task_lam_prep_more.add_trigger("lam_save_int2lm == complete")
    task_symlink_missing_analysis.add_trigger("lam_prep_more == complete")
    task_lam_more.add_trigger("create_symlink_missing_analysis == complete")
    task_lam_save_more.add_trigger("lam_more == complete")

    # Add tasks to family
    fam_lam.add_task(task_create_lam_dirs)
    fam_lam.add_task(task_symlink_input_lam)
    fam_lam.add_task(task_lam_prep_int2lm)
    fam_lam.add_task(task_lam_int2lm)
    fam_lam.add_task(task_lam_save_int2lm)
    fam_lam.add_task(task_lam_prep_more)
    fam_lam.add_task(task_symlink_missing_analysis)
    fam_lam.add_task(task_lam_more)
    fam_lam.add_task(task_lam_save_more)

    # Add families to suite
    suite.add_family(fam_global)
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
    scenario_name = 'scenario_1'
    scenario = ModelSuite(scenario_name)
    suite = create_suite(scenario_name, fc_date)
    scenario.add_suite(suite)

    # Check and save the definition file
    scenario.check()
    output_fname = os.path.join(ecflow_suite_dir, f'GLORI4DE_{scenario_name}.def')
    scenario.write(output_fname)


if __name__ == "__main__":
    main()
