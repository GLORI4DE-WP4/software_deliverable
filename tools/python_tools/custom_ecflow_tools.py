import argparse
import ecflow
import os


def ask_confirm(msg=""):
    if type(msg) is not str:
        try:
            msg = str(msg)
        except:
            print(f'WARNING: message {msg} cannot be converted to str.')
            return "(y/n)?"
    ans = input(f"{msg} (y/n)? ")
    return ans.upper().startswith("Y")


class ModelSuite():
    def __init__(self, name):
        self.name = name
        self.defs = ecflow.Defs()
        self.suite = None
        self.checked = False

    def add_suite(self, suite):
        if type(suite) is not ecflow.Suite:
            print('WARNING: trying to add suite that is not ecflow.Suite. Adding empty suite instead.')
            suite = ecflow.Suite('empty_suite')
        self.defs.add_suite(suite)
        self.suite = suite

    def check(self):
        # check syntax
        result = self.defs.check()
        if result != "":
            print(f"Error in {self.name} suite definition:")
            print(result)
        else:
            # check job tree
            result = self.defs.check_job_creation()
            if result != "":
                print(f"Error in {self.name} suite job creation:")
                print(result)
            else: 
                self.checked = True

    def write(self, fname=None, interactive=True):
        if not self.checked:
            print(f"Suite {self.name} has not been checked, refusing to write")
            return
        if type(fname) is not str:
            fname = self.name + ".def"
        if not fname.upper().endswith('.DEF'):
            fname += '.def'
        if interactive:
            if os.path.exists(fname):
                if not ask_confirm(f"Definition file {fname} exists, replace"):
                    return
        self.defs.save_as_defs(fname)
        print(f"Suite saved as {fname}.")

    def replace(self, interactive=True):
        if not self.checked:
            print(f"suite {self.name} has not been checked, refusing to replace")
            return
        if interactive:
            if not ask_confirm(f"Replace suite {self.name} on server"):
                return
        client = ecflow.Client() # connect using environment
        client.replace(f"/{self.name}", self.defs)
        print(f"Suite {self.name} replaced on server")


def read_command_line_args():
    '''
    Read command line arguments

    Returns
    -------
    argparse.Namespace
        Object containing parsed arguments.

    '''
    parser = argparse.ArgumentParser(description = \
                        'The script defines an ecflow suite for the scenario 4 of GLORI4DE. \
                        It downloads the data from S3, links them to the bacy_data folder, \
                        and starts the BACY cycle for a global ICON run.')
    parser.add_argument('--fc_date',
                        default = "2023051512",
                        type = str,
                        help = 'The start date of the forecast. Default: 2023051512')
    return parser.parse_args()
