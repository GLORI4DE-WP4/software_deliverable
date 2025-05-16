import datetime
import ecflow
import os
import sys

#------------------------------------------------------------------
# CONSTANTS & PARAMETERS
# Base paths
base_dir = "/leonardo_work/DE360_GLORI/smr_prod/"
nwprun_root_dir = os.path.join(base_dir, "scenarios", "scenario_3")
scenario_dir    = os.path.join(nwprun_root_dir, "bacy")
# Tools paths
ecflow_suite_dir = os.path.join(scenario_dir, "ecflow_suite")
tools_dir        = os.path.join(base_dir, "scenarios", "tools")
venv_dir         = os.path.join(tools_dir, "venv_ecflow")
# BACY code paths
bacy_lam_dir   = os.path.join(scenario_dir, "lam")
bacy_more_dir  = os.path.join(bacy_lam_dir, "bacy_more")
bacy_remap_dir = os.path.join(bacy_lam_dir, "bacy_remap")
# Data paths
nwprun_arki_dir   = os.path.join(nwprun_root_dir, "arkimet")
bacy_data_dir     = os.path.join(scenario_dir, "bacy_data")
bacy_boundary_dir = os.path.join(bacy_data_dir, "boundary_data")

# Additional costants
fcast_duration = datetime.timedelta(hours=48)
kenda_duration = datetime.timedelta(hours=1) # Note: value to be matched to the kenda suite
default_number_of_members = 20
default_time_interval = 1 # hours
default_grid_str_dom01 = "R19B07"
default_grid_str_dom02 = "R19B08"

# Loading additional Python tools
sys.path.append(os.path.join(tools_dir, "python_tools"))
from custom_ecflow_tools import ModelSuite, read_command_line_args
#------------------------------------------------------------------

def create_suite(scenario_name, fc_date):
    suite = ecflow.Suite(scenario_name)

    # Set ECF_HOME where .ecf files are located
    suite.add_variable("ECF_HOME", os.path.join(ecflow_suite_dir, 'ecf_files'))
    
    # Set ECF_FILES for where scripts are stored
    suite.add_variable("ECF_FILES", os.path.join(ecflow_suite_dir, 'ecf_files'))

    # Set ECF_TRIES to 1 to prevent task retries
    suite.add_variable("ECF_TRIES", "1")

    # Computing auxiliary dates
    da_start            = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    fc_start            = da_start + kenda_duration
    fc_end              = fc_start + fcast_duration
    
    # Formatting to string (up to hours)
    fc_start_str_h = fc_start.strftime('%Y%m%d%H')
    fc_end_str_h = fc_end.strftime('%Y%m%d%H')

    # Set dates as a variables so THEY can be changed in the UI
    suite.add_variable("DA_START", fc_date)
    suite.add_variable("FC_START", fc_start_str_h)
    suite.add_variable("FC_END", fc_end_str_h)

    # --- Manual start ---
    # Task 00: Manual trigger
    task_manual_trigger = ecflow.Task('manual_trigger').add_defstatus(ecflow.DState.suspended)

    # --- Family: LAM preparation ---
    fam_lam_prep = ecflow.Family('ICON_lam_preparation')

    # Task 01: Split ensemble into individual members
    task_split_members = ecflow.Task("divide_input_members")
    task_split_members.add_variable("OUTPUT_DIR", os.path.join(bacy_boundary_dir, fc_start_str_h, "raw_members"))
    task_split_members.add_variable("NUMBER_OF_MEMBERS", default_number_of_members)
    task_split_members.add_variable("TIME_INTERVAL", default_time_interval)
    task_split_members.add_variable("PARENTMODEL_ARKI_DS", os.path.join(nwprun_arki_dir, "ifsens_am_foricon"))
    task_split_members.add_variable("BASE_DIR", os.path.join(base_dir, "scenarios"))
    task_split_members.add_variable("CONTAINER_PATH", os.path.join(nwprun_root_dir, "simctools_nwprun_r8.sif"))
    task_split_members.add_variable("SCRIPTS_DIR", os.path.join(ecflow_suite_dir, "scripts"))
    
    # # Task 02: Rename the IFS initial/boundary conditions
    task_rename_IFS = ecflow.Task('rename_IFS')
    task_rename_IFS.add_variable("SCRIPTS_DIR", os.path.join(ecflow_suite_dir, "scripts"))
    task_rename_IFS.add_variable("ARCHIVE_PATH", os.path.join(bacy_boundary_dir, f"{fc_start_str_h}","raw_members"))
    task_rename_IFS.add_variable("OUTPUT_DIR", os.path.join(bacy_boundary_dir, f"{fc_start_str_h}"))
    task_rename_IFS.add_variable("ACTIVATE_PATH", os.path.join(venv_dir, "bin", "activate"))

    # Task 03: Prepare folders for each member for the remapping
    task_prepare_members = ecflow.Task('prepare_members')
    task_prepare_members.add_variable("INPUT_DIR", os.path.join(bacy_boundary_dir, f"{fc_start_str_h}"))
    task_prepare_members.add_variable("OUTPUT_DIR", os.path.join(bacy_remap_dir, "data"))
    task_prepare_members.add_variable("INT_DIR", os.path.join(bacy_remap_dir, "modules", "int2lm"))
    task_prepare_members.add_variable("MORE_DIR", os.path.join(bacy_remap_dir, "modules", "more"))
    task_prepare_members.add_variable("NUM_MEMBERS", default_number_of_members)

    # Add dependencies
    task_rename_IFS.add_trigger("divide_input_members == complete")
    task_prepare_members.add_trigger("rename_IFS == complete")

    # Add tasks to family
    fam_lam_prep.add_task(task_split_members)
    fam_lam_prep.add_task(task_rename_IFS)
    fam_lam_prep.add_task(task_prepare_members)

    # --- Family group: remapping IC and BC for all members ---
    fam_lam_remap_all = ecflow.Family('ICON_lam_remapping')
    fam_lam_remap_dict = {}
    for i_mem in range(1, default_number_of_members+1):  #default_number_of_members
        i_mem_str = f'{i_mem:03d}'
        fam_lam_remap = ecflow.Family(f'ICON_lam_remap_mem{i_mem_str}')

        # Task 01: Prepare int2lm (remapping IFS to ICON grid)
        task_lam_prep_int2lm = ecflow.Task("lam_prep_int2lm")
        task_lam_prep_int2lm.add_variable("LAM_DATA_DIR", os.path.join(bacy_remap_dir, "data"))
        task_lam_prep_int2lm.add_variable("INT_DIR", os.path.join(bacy_remap_dir, "modules", "int2lm"))
        task_lam_prep_int2lm.add_variable("MEM_NUM", i_mem_str)

        # Task 02: Running int2lm
        task_lam_int2lm = ecflow.Task("lam_int2lm")
        task_lam_int2lm.add_variable("INT_DIR", os.path.join(bacy_remap_dir, "modules", "int2lm"))
        task_lam_int2lm.add_variable("MEM_NUM", i_mem_str)

        # Task 03: Saving int2lm
        task_lam_save_int2lm = ecflow.Task("lam_save_int2lm")
        task_lam_save_int2lm.add_variable("INT_DIR", os.path.join(bacy_remap_dir, "modules", "int2lm"))
        task_lam_save_int2lm.add_variable("MEM_NUM", i_mem_str)
        task_lam_save_int2lm.add_variable("LAM_DATA_DIR", os.path.join(bacy_remap_dir, "data"))

        # Add dependencies
        task_lam_int2lm.add_trigger("lam_prep_int2lm == complete")
        task_lam_save_int2lm.add_trigger("lam_int2lm == complete")

        # Add tasks to family
        fam_lam_remap.add_task(task_lam_prep_int2lm)
        fam_lam_remap.add_task(task_lam_int2lm)
        fam_lam_remap.add_task(task_lam_save_int2lm)

        # Adding family to parent family and dictionary
        fam_lam_remap_dict[i_mem_str] = fam_lam_remap
        fam_lam_remap_all.add_family(fam_lam_remap)

    # --- Family: LAM model run ---
    fam_lam_more_all = ecflow.Family('ICON_lam_forecast')

    # Task 01: Link output of nwprun into bacy_more data folder
    task_link_da_output = ecflow.Task('link_da_output')
    
    task_link_da_output.add_variable("NWPRUN_OUT_DIR", os.path.join(nwprun_arki_dir, "archive", fc_start_str_h))
    task_link_da_output.add_variable("NUM_MEMBERS", default_number_of_members)
    task_link_da_output.add_variable("GRID_DOM01", default_grid_str_dom01)
    task_link_da_output.add_variable("GRID_DOM02", default_grid_str_dom02)
    task_link_da_output.add_variable("SCRIPTS_DIR", os.path.join(ecflow_suite_dir, "scripts"))
    task_link_da_output.add_variable("BACY_DATA_ROOT_DIR", os.path.join(bacy_more_dir, "data"))

    # Task 02: Link output of int2lm from bacy_remapping into bacy_more folder
    task_link_int2lm_output = ecflow.Task('link_int2lm_output')
    task_link_int2lm_output.add_variable("NUM_MEMBERS", default_number_of_members)
    task_link_int2lm_output.add_variable("SRC_BACY_DATA_ROOT_DIR", os.path.join(bacy_remap_dir, "data"))
    task_link_int2lm_output.add_variable("TGT_BACY_DATA_ROOT_DIR", os.path.join(bacy_more_dir, "data"))
    task_link_int2lm_output.add_variable("MAIN_NUMBER", "0000") #0200
    task_link_int2lm_output.add_variable("SCRIPTS_DIR", os.path.join(ecflow_suite_dir, "scripts"))

    # Add dependencies 
    task_link_int2lm_output.add_trigger('link_da_output == complete')

    # Add tasks to family
    fam_lam_more_all.add_task(task_link_da_output)
    fam_lam_more_all.add_task(task_link_int2lm_output)

    # Adding the individual calls to BACY
    for i_mem in range(1, default_number_of_members+1):
        i_mem_str = f'{i_mem:03d}'
        fam_lam_more = ecflow.Family(f'ICON_lam_more_mem{i_mem_str}')

        # Task 01: Prepare more (model run, 1 hour)
        task_more_create_iodir = ecflow.Task("create_iodir_main_memdir")
        task_more_create_iodir.add_variable("INPUT_DIR", os.path.join(bacy_more_dir, "modules", "more"))
        task_more_create_iodir.add_variable("MEM_NUM", i_mem_str)

        # Task 03: Prepare more
        task_lam_prep_more = ecflow.Task("lam_prep_more")
        task_lam_prep_more.add_variable("LAM_DATA_DIR", os.path.join(bacy_more_dir, "data"))
        task_lam_prep_more.add_variable("MORE_DIR", os.path.join(bacy_more_dir, "modules", "more"))
        task_lam_prep_more.add_variable("MEM_NUM", i_mem_str)
        task_lam_prep_more.add_variable("MORE_MODE", "MAIN") 

        # Task 04: Running more
        task_lam_more = ecflow.Task("lam_more")
        task_lam_more.add_variable("MORE_DIR", os.path.join(bacy_more_dir, "modules", "more"))
        task_lam_more.add_variable("MEM_NUM", i_mem_str)
        task_lam_more.add_variable("MORE_MODE", "MAIN")

        # Task 05: Saving more
        task_lam_save_more = ecflow.Task("lam_save_more")
        task_lam_save_more.add_variable("MORE_DIR", os.path.join(bacy_more_dir, "modules", "more"))
        task_lam_save_more.add_variable("MEM_NUM", i_mem_str)
        task_lam_save_more.add_variable("LAM_DATA_DIR", os.path.join(bacy_more_dir, "data"))
        task_lam_save_more.add_variable("MORE_MODE", "MAIN")

        # Add dependencies
        task_lam_prep_more.add_trigger("create_iodir_main_memdir == complete")
        task_lam_more.add_trigger("lam_prep_more == complete")
        task_lam_save_more.add_trigger("lam_more == complete")

        # Add tasks to family
        fam_lam_more.add_task(task_more_create_iodir)
        fam_lam_more.add_task(task_lam_prep_more)
        fam_lam_more.add_task(task_lam_more)
        fam_lam_more.add_task(task_lam_save_more)

        # Add trigger
        fam_lam_more.add_trigger('link_int2lm_output == complete')

        # Adding family to parent family and dictionary
        fam_lam_more_all.add_family(fam_lam_more)

    # --- Sutie final organization ---
    # Add families and tasks to suite
    suite.add_task(task_manual_trigger)
    suite.add_family(fam_lam_prep)
    suite.add_family(fam_lam_remap_all)
    suite.add_family(fam_lam_more_all)

    # Add triggers
    fam_lam_prep.add_trigger("manual_trigger == complete")
    fam_lam_remap_all.add_trigger('ICON_lam_preparation == complete')
    fam_lam_more_all.add_trigger('ICON_lam_remapping == complete')

    return suite


def main():
    # Read variables from commad line
    args = read_command_line_args()
    fc_date = args.fc_date
    try:
        _date = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    except:
        print('WARNING: The datetime provided is not valid. Expected datetime in format YYYYMMDDHH.')
        print(f'Using default value: {fc_date}.')
        fc_date = fc_date

    # Create the ModelSuite
    scenario_name = f'scenario_3_{fc_date}'
    scenario = ModelSuite(scenario_name)
    suite = create_suite(scenario_name, fc_date)
    scenario.add_suite(suite)

    # Check and save the definition file
    scenario.check()
    output_fname = os.path.join(ecflow_suite_dir, f'GLORI4DE_{scenario_name}.def')
    scenario.write(output_fname)


if __name__ == "__main__":
    main()
