import datetime
import glob
import os
import sys


def link_and_print(src, tgt):
    if os.path.islink(tgt):
        print(f"Warning: Destination link {tgt} exists. It will be replaced.")
        os.remove(tgt)
    elif os.path.exists(tgt):
        print(f"Warning: Destination file {tgt} exists. It will NOT be replaced.")
        os.remove(tgt)
    os.symlink(src, tgt)
    print(f'Linked {src} to {tgt}.')
    print('----------------------------------------------------')
    return 0


def main():
    if len(sys.argv) != 6:
        print("Usage: python link_da_output.py <fc_start> <num_members> " + \
              "<src_bacy_data_root_dir> <tgt_bacy_data_root_dir> <main_number>")
        sys.exit(1)
    fc_start               = sys.argv[1]
    num_members            = int(sys.argv[2])
    src_bacy_data_root_dir = sys.argv[3]
    tgt_bacy_data_root_dir = sys.argv[4]
    main_number            = sys.argv[5]

    # Formats
    datehours   = '%Y%m%d%H'
    dateminutes = datehours + '%M'
    dateseconds = dateminutes + '%S'

    # Computing and formatting dates and times
    fc_start_datetetime = datetime.datetime.strptime(fc_start, datehours)

    enda_expected_start = fc_start_datetetime #- datetime.timedelta(hours=3)

    enda_expected_start_datesecond= enda_expected_start.strftime(dateseconds) 
    enda_end_datesecond = fc_start_datetetime.strftime(dateseconds) 

    for mem_num in range(1,num_members+1):
        formatted_mem_num = f'{mem_num:03d}'
        
        # int2lm output
        src_data_dir = os.path.join(src_bacy_data_root_dir, f'mem{formatted_mem_num}',
                                    f'{enda_end_datesecond}', f'main*')
        src_flist = sorted(glob.glob(os.path.join(src_data_dir, 'lbc*')))

        if not len(src_flist):
            print(f'ERROR: No lbc files found inside {src_data_dir}')
            return 1

        # more input
        tgt_data_dir = os.path.join(tgt_bacy_data_root_dir, f'mem{formatted_mem_num}',
                                    f'{enda_expected_start_datesecond}', f'main{main_number}')

        if not os.path.isdir(tgt_data_dir):
            print(f"Warning: Destination directory {tgt_data_dir} does not exist. It will be created.")
            os.makedirs(tgt_data_dir, exist_ok=True)


        for src_fpath in src_flist:
            f_basename = os.path.basename(src_fpath)
            tgt_fpath = os.path.join(tgt_data_dir, f_basename)
            link_and_print(src_fpath, tgt_fpath)

    print('link_int2lm_output.py execution complete.')
    return 0

if __name__ == "__main__":
    main()