import glob
import os
import argparse
from datetime import datetime, timedelta
import shutil

def parse_args():
    parser = argparse.ArgumentParser(description="Rename ensemble IFS files based on date range and initialization time.")
    parser.add_argument("--archive_path", required=True, help="Path to the folder where the files are stored")
    parser.add_argument("--start_datehour", required=True, help="Start date and hour in format YYYYMMDDHH")
    parser.add_argument("--end_datehour", required=True, help="End date and hour in format YYYYMMDDHH")
    parser.add_argument("--output_dir", required=True, help="Output directory where files should be copied and renamed")
    return parser.parse_args()

def datehour_to_timestamp(datehour):
    return int(datetime.strptime(datehour, "%Y%m%d%H").timestamp())

def dateminute_to_timestamp(datehour):
    return int(datetime.strptime(datehour, "%Y%m%d%H%M").timestamp())

def main():
    args = parse_args()
    archive_path = args.archive_path
    start_timestamp = datehour_to_timestamp(args.start_datehour)
    end_timestamp = datehour_to_timestamp(args.end_datehour) + 3599  # Set to last minute of the hour
    output_dir = args.output_dir
    ini_year = args.start_datehour[0:4]
    end_year = args.end_datehour[0:4]

    print(args.start_datehour)
    print(args.end_datehour)

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    # Loop through all files in the archive path
    raw_flist = sorted(glob.glob(os.path.join(archive_path, 'U3X*')))
    for file_path in raw_flist:
        file = os.path.basename(file_path)
        if os.path.isfile(file_path):
            # Extract initialization date and forecast date from the filename
            forecast_init_date = ini_year + file[3:9]  # Extract YYYYMMDDHH for forecast initialization
            forecast_date = file[9:19]                 # Extract forecast period in YYYYMMDDHH
            member = int(file.split(".")[2])           # Extract ensemble member (e.g., '1', '2', etc.)

            print(file,file[9:15])
            print(forecast_date, forecast_init_date)

            # Convert forecast and initialization dates to timestamps
            try:
                file_timestamp = datehour_to_timestamp(forecast_date)
                init_timestamp = datehour_to_timestamp(forecast_init_date)
            except ValueError:
                print(f"Skipping file {file}: Unable to parse date format")
                continue
            
            print(file_path, start_timestamp, file_timestamp, end_timestamp)
            # Check if the file timestamp is within the specified range
            if start_timestamp <= file_timestamp <= end_timestamp:
                # Calculate the time difference in seconds
                time_diff = file_timestamp - init_timestamp
                days, remainder = divmod(time_diff, 86400)
                hours, remainder = divmod(remainder, 3600)
                minutes = remainder // 60

                # Format days, hours, and minutes to two digits
                days_str = f"{days:02}"
                hours_str = f"{hours:02}"
                minutes_str = f"{minutes:02}"

                # Generate the new filename
                new_name = f"fc_ifs.{forecast_init_date}_{days_str}{hours_str}{minutes_str}00.{member:03d}"

                # Copy and rename the file
                shutil.copy(file_path, os.path.join(output_dir, new_name))
                print(f"Copied and renamed {file} to {new_name}")

if __name__ == "__main__":
    main()
