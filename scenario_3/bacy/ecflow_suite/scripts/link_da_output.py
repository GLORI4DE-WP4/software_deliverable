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
    if len(sys.argv) != 7:
        print("Usage: python link_da_output.py <nwprun_out_dir> <num_members> " + \
              "<fc_start> <grid_dom01> <grid_dom02> <bacy_data_root_dir>")
        sys.exit(1)
    nwprun_out_dir     = sys.argv[1]
    num_members        = int(sys.argv[2])
    fc_start           = sys.argv[3]
    grid_dom01         = sys.argv[4]
    grid_dom02         = sys.argv[5]
    bacy_data_root_dir = sys.argv[6]

    # Formats
    datehours   = '%Y%m%d%H'
    dateminutes = datehours + '%M'
    dateseconds = dateminutes + '%S'

    # Computing and formatting dates and times
    fc_start_datetetime = datetime.datetime.strptime(fc_start, datehours)

    enda_expected_start = fc_start_datetetime #- datetime.timedelta(hours=3)
    enda_start = fc_start_datetetime - datetime.timedelta(hours=1)
    enda_55min = fc_start_datetetime - datetime.timedelta(minutes=5)

    enda_expected_start_datesecond= enda_expected_start.strftime(dateseconds) 
    enda_start_dateminute = enda_start.strftime(dateminutes) 
    enda_55min_datesecond = enda_55min.strftime(dateseconds) 
    enda_end_datesecond = fc_start_datetetime.strftime(dateseconds) 

    # Linking files for each member
    for mem_num in range(1, num_members + 1):
        formatted_mem_num = f'{mem_num:03d}'
        
        if mem_num == 0:
            # Note: not used, but it could be used if we were planning on adding the deterministic
            src_enda_suffix  = 'det'
        else:
            src_enda_suffix  = f'{mem_num:03d}'
        
        # Nwprun output
        src_icon_55min_dom01       = os.path.join(nwprun_out_dir,
                                                  f'icon_{enda_start_dateminute}_bacy_+00005500_DOM01_{src_enda_suffix}.grb')
        src_icon_55min_tiles_dom01 = os.path.join(nwprun_out_dir,
                                                  f'icon_{enda_start_dateminute}_tiles_+00005500_DOM01_{src_enda_suffix}.grb')
        src_icon_55min_dom02       = os.path.join(nwprun_out_dir,
                                                  f'icon_{enda_start_dateminute}_bacy_+00005500_DOM02_{src_enda_suffix}.grb')
        src_icon_55min_tiles_dom02 = os.path.join(nwprun_out_dir,
                                                  f'icon_{enda_start_dateminute}_tiles_+00005500_DOM02_{src_enda_suffix}.grb')
        src_enda_an_inc            = os.path.join(nwprun_out_dir,
                                                  f'laf{enda_end_datesecond}_inc_DOM01.{src_enda_suffix}')

        # BACY input
        bacy_data_dir = os.path.join(bacy_data_root_dir, f'mem{formatted_mem_num}', f'{enda_expected_start_datesecond}')
        if not os.path.isdir(bacy_data_dir):
            print(f"Warning: Destination directory {bacy_data_dir} does not exist. It will be created.")
            os.makedirs(bacy_data_dir, exist_ok=True)

        tgt_icon_55min_dom01       = os.path.join(bacy_data_dir, f'fc_{grid_dom01}.{enda_55min_datesecond}')
        tgt_icon_55min_tiles_dom01 = os.path.join(bacy_data_dir, f'fc_{grid_dom01}_tiles.{enda_55min_datesecond}')
        tgt_icon_55min_dom02       = os.path.join(bacy_data_dir, f'fc_{grid_dom02}_N02.{enda_55min_datesecond}')
        tgt_icon_55min_tiles_dom02 = os.path.join(bacy_data_dir, f'fc_{grid_dom02}_N02_tiles.{enda_55min_datesecond}')
        tgt_enda_an_inc      = os.path.join(bacy_data_dir, f'an_{grid_dom01}.{enda_end_datesecond}_inc')

        # linking
        link_and_print(src_icon_55min_dom01,       tgt_icon_55min_dom01)
        link_and_print(src_icon_55min_tiles_dom01, tgt_icon_55min_tiles_dom01)
        link_and_print(src_icon_55min_dom02,       tgt_icon_55min_dom02)
        link_and_print(src_icon_55min_tiles_dom02, tgt_icon_55min_tiles_dom02)
        link_and_print(src_enda_an_inc,            tgt_enda_an_inc)

        print('link_da_output.py execution complete.')

if __name__ == "__main__":
    main()