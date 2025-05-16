import argparse
import datetime
import boto3
import os
import time


GLOBAL_TEMPLATE_DICT = {
    'date_str': ['input/an_R03B07.{0}_inc'],
    'prev_date_str': ['input/fc_R03B07_tiles.{0}',
                      'input/fc_R03B07.{0}',
                      'input/fc_R03B08_N02_tiles.{0}',
                      'input/fc_R03B08_N02.{0}']
}


def read_command_line_args():
    '''
    Read command line arguments

    Returns
    -------
    argparse.Namespace
        Object containing parsed arguments.

    '''
    parser = argparse.ArgumentParser(description = 'Download from S3 bucket.\
                        The script downloads all files files from the specified bucket\
                        and saves into the destination folder provided by the user.')
    parser.add_argument('--bucket',
                        default = "bacy_icon_italy",
                        type = str,
                        help = 'Name of the S3 bucket whose content will be downloaded.')
    parser.add_argument('--destination',
                        default = "bacy_data/data",
                        type = str,
                        help = 'The folder in which the data will be stored.')
    parser.add_argument('--fc_date',
                        default = "2023051600",
                        type = str,
                        help = 'The start date of the forecast. Default: 2023051600')
    parser.add_argument('--boto_credentials',
                        default = "./cred.txt",
                        type = str,
                        help = 'The credentials to access S3. Default: ./cred.txt')
    parser.add_argument('--verbose',
                        default = 'False',
                        type = str,
                        help = 'Optiona printing of information during the download. \
                        Default: False')
    return parser.parse_args()


def download_files_from_s3(bucket_name, destination, fc_date="unknown",
                           boto_credentials='./cred.txt', verbose=False):
    # Source credentials which are found in ./cred.txt file
    os.environ['AWS_SHARED_CREDENTIALS_FILE'] = boto_credentials

    # Initialize S3 client
    s3 = boto3.client('s3', endpoint_url='https://imk-glori.s3.scc.kit.edu:9021')

    # List objects of the specific bucket
    response = s3.list_objects(Bucket=bucket_name)

    # Ensure that there are objects in the bucket
    if ('Contents' not in response) and verbose:
        print("No objects found in the bucket.")
        return 1

    # Finding the previous date for the "fc" files
    curr_datetime = datetime.datetime.strptime(fc_date, '%Y%m%d%H')
    prev_date_str = (curr_datetime - datetime.timedelta(minutes=90)).strftime('%Y%m%d%H%M%S')

    # Formatting the expected file names
    expected_fnames = []
    for to_format in GLOBAL_TEMPLATE_DICT['date_str']:
        expected_fnames.append(to_format.format(fc_date))
    for to_format in GLOBAL_TEMPLATE_DICT['prev_date_str']:
        expected_fnames.append(to_format.format(prev_date_str))

    # Select items to download
    count=0
    objects_to_download = []
    for res in response['Contents']:
        if res['Key'] in expected_fnames:
            objects_to_download.append(res)
            count+=1
            if verbose:
                print(f"Key: {res['Key']}")
    if verbose:
        print('Total number of objects:', count)

    if not count:
        print('ERROR: No files are available or match the expected filenames.')
        return 2

    # Directory to save downloaded files
    download_dir = os.path.join(destination, fc_date)

    # Create directory if it doesn't exist
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)
        if verbose:
            print(f'{download_dir} did not exist. It has ben created.')

    download_times = []
    total_bytes_downloaded = 0

    # Iterate over each object and download it
    for obj in objects_to_download:
        key = obj['Key']
        file_path = os.path.join(download_dir, os.path.basename(key))

        # debug print
        if verbose:
            print(f"Downloading {key} to {file_path}")
                
        start_time = time.time()

        # Download the object
        s3.download_file(bucket_name, key, file_path)

        end_time = time.time()

        # Calculate download time
        download_time = end_time - start_time

        # Calculate download speed
        file_size = os.path.getsize(file_path)
        download_speed = file_size / download_time

        # Add download time to the list
        download_times.append(download_time)

        # Update total bytes downloaded
        total_bytes_downloaded += file_size
        if verbose:
            print(f"Downloaded {key}. Time taken: {download_time:.2f} seconds. Download speed: {download_speed / (1024*1024):.2f} MB/s")

    # Compute average download speed (bandwidth) including all cases
    average_download_speed = total_bytes_downloaded / sum(download_times)
    if verbose:
        print(f"Average download speed (including all cases): {average_download_speed / (1024*1024):.2f} MB/s")

    # Remove two fastest and two slowest cases
    download_times_sorted = sorted(download_times)
    download_times_trimmed = download_times_sorted[2:-2]
    total_bytes_downloaded_trimmed = total_bytes_downloaded - sum(os.path.getsize(os.path.join(download_dir, os.path.basename(obj['Key']))) for obj in objects_to_download[:2]) - sum(os.path.getsize(os.path.join(download_dir, os.path.basename(obj['Key']))) for obj in objects_to_download[-2:])
    average_download_speed_trimmed = total_bytes_downloaded_trimmed / sum(download_times_trimmed)

    if verbose:
        print(f"Average download speed (excluding two fastest and two slowest cases): {average_download_speed_trimmed / (1024*1024):.2f} MB/s")
    return 0


if __name__ == "__main__":
    # Read variables from commad line
    args = read_command_line_args()
    bucket = args.bucket
    destination = args.destination
    fc_date = args.fc_date
    boto_credentials = args.boto_credentials
    verbose = args.verbose
    if verbose.upper() == 'FALSE' or verbose.upper() == 'F' or \
        verbose.upper() == 'N' or verbose.upper() == 'NO' or verbose == '0':
        verbose = False 

    # Download files
    start_time = time.time()
    download_files_from_s3(bucket, destination, fc_date, boto_credentials, verbose)
    end_time = time.time()
    if verbose:
        print('Total time: ', end_time - start_time, 's')
