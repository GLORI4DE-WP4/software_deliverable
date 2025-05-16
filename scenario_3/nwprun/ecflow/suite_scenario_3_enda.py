#!/usr/bin/python3

import os,sys
import datetime
import optparse
import ecflow
from nwprun import *

parser = optparse.OptionParser(usage="%prog [OPTIONS]")
parser.add_option("--yes", help="work in non-interactive mode and answer yes to all questions (it will overwrite files and replace scripts on server)",
                  action="store_true")
parser.add_option("--delta", help="comma-separated list of delta time in days to go back, for each suite",
                  default="0,0,0,0")
parser.add_option("--fc_date", help="Forecast date for the enda suite, as YYYYMMDD string.",
                  default="20241019")

opts, args = parser.parse_args()
interactive = not opts.yes
delta = [int(i) for i in opts.delta.split(',')]
fc_date_str = opts.fc_date
try:
    fc_date = datetime.datetime.strptime(fc_date_str, "%Y%m%d")
except:
    print(f"Date {fc_date_str} is not valid. Using date of today.")
    fc_date = datetime.datetime.now()

hpcenv = os.environ["HPC_SYSTEM"]
common_extra_env = {
    "NO_FAIL": "FALSE",
    "TASK_PER_CORE": "1",
    "HPCENV": os.environ["HPC_SYSTEM"],
    "ECF_TIMEOUT": "7200",
    "ECF_DENIED": "",
    "WALL_TIME_WAIT": "04:10:00",
    "WALL_TIME_ARCHIVE": "04:10:00"
}

# Suite enda_nest
extra_env = common_extra_env.copy()
if hpcenv == "leonardo":
    extra_env.update({
        "NWPCONF": "prod/scenario_3/enda_nest",
        "NNODES_PREMODEL": 1,
        "NNODES_MODEL": 2,
        "NNODES_ENDA": 6,
        "NNODES_MEC": 6,
        "NTASKS_POSTPROC": 2,
        "WALL_TIME_PREMODEL": "00:20:00",
        "WALL_TIME_MODEL": "00:20:00",
        "WALL_TIME_ENDA": "00:30:00",
        "WALL_TIME_MEC": "00:30:00"
    })
else: #default g100
    extra_env.update({
        "NWPCONF": "prod/scenario_3/enda_nest",
        "NNODES_PREMODEL": 1,
        "NNODES_MODEL": 6,
        "NNODES_ENDA": 8,
        "NNODES_MEC": 8,
        "NTASKS_POSTPROC": 2,
        "WALL_TIME_PREMODEL": "00:20:00",
        "WALL_TIME_MODEL": "01:00:00",
        "WALL_TIME_ENDA": "00:30:00",
        "WALL_TIME_MEC": "00:30:00"
    })
basicenv = BasicEnv(srctree=os.path.join(os.environ["WORKDIR_BASE"], "nwprun"),
                    worktree=os.path.join(os.environ["WORKDIR_BASE"], "ecflow"),
                    sched="slurm",
                    client_wrap=os.path.join(os.environ["WORKDIR_BASE"], "nwprun","ecflow","ec_wrap"),
                    ntries=1,
                    extra_env=extra_env)

conf = ModelConfig({"gts": True, "lhn": False, "radarvol": False, "membrange": "0-20",
                    "postprocrange": "-1",
                    "modelname": "icon",
                    "runlist": [GetObs, EpsMembers, EndaAnalysis]}).getconf()
enda_nest = ModelSuite(f"scenario_3_enda_{fc_date_str}")
basicenv.add_to(enda_nest.suite)
day = enda_nest.suite.add_family("day").add_repeat(
    ecflow.RepeatDate("YMD", 
                      int((fc_date-datetime.timedelta(days=delta[0])).strftime("%Y%m%d")), # qui data da girare
                      20301228))

hdep = None # first repetition has no dependency
for h in range(0, 24, 1):
    famname = "hour_" + ("%02d" % h)
    hour = day.add_family(famname).add_variable("TIME", "%02d" % h)
    #    hrun = "%02d:00" % (h+1 % 24) # start 1h after nominal time
    WaitAndRun(dep=hdep, conf=conf).add_to(hour)
    hdep = famname # dependency for next repetition

enda_nest.check()
enda_nest.write(interactive=interactive)
enda_nest.replace(interactive=interactive)


