# GLORI4DE Scenarios - ecFlow Suite Definitions

This repository contains the deliverable of Arpae Emilia Romagna for the GLORI4DE project, providing the ecFlow suite definitions for all four project scenarios. The suites manage the workflow for running ICON model simulations with different configurations.

## Key Components

1. **BACY Installation Required**  
   - The primary workflow management system (BACY) is not included as it belongs to DKRZ
   - Hosted on DKRZ's GitLab: [BACY repository](https://gitlab.dkrz.de/)
   - Requires modification to include Leonardo as a supported site
   - A dedicated branch with Leonardo support will be available soon on the same repository
   - This repository includes:
     - Job templates
     - Configuration files (to overwrite standard installation files)
     - Leonardo-specific settings

2. **nwprun for Scenario 3**  
   - Required only for Scenario 3's data assimilation
   - Developed by Arpae-SIMC: [nwprun GitHub](https://github.com/ARPA-SIMC/nwprun.git)
   - Includes modifications for:
     - GLORI alpine domain simulations
     - Nesting configuration
   - Configuration files provided should overwrite standard installation files

3. **ecFlow & Python Environment**  
   - Requires ecFlow installation
   - Uses dedicated Python virtual environment
   - Package requirements in `tools/venv_ecflow/requirements.txt`

## Scenario Variants

Scenarios 2 and 4 have two versions each:

| Version | Data Source | Assimilation | Description                              |
|---------|-------------|--------------|------------------------------------------|
| **s3**  | Amazon S3   | No           | Uses DWD analysis from Horeka server     |
| **da**  | Local       | Yes          | Uses pre-downloaded data with BACY cycle |

## Repository Structure

```
glori4de_scenarios/
├── scenario_1/     # Scenario 1
├── scenario_2_da/  # Scenario 2 with data assimilation
├── scenario_2_s3/  # Scenario 2 using S3 data
├── scenario_3/     # Scenario 3 (requires nwprun)
├── scenario_4_da/  # Scenario 4 with data assimilation
├── scenario_4_s3/  # Scenario 4 using S3 data
├── tools/          # Installation helpers
│ ├── ecflow/       # ecFlow installation guide
│ ├── python_tools/ # Tools for defining the ecFlow suites
│ └── venv_ecflow/  # Python environment setup
└── visualization/  # Visualization Jupyter notebooks
```

## Key Directories

- **ecflow_suite/**  
  Contains Python suite definitions and ECF scripts for each scenario

- **bacy_data/**  
  Configuration files and grid definitions:
  - `routfoxfox/icon/grids/` - ICON grid files
  - `boundary_data/` - Lateral boundary conditions
  - `data/` - Initial conditions and first guesses
  - `obs_local` - Observations for the data assimilation (BACY only)

- **modules/**  
  BACY module configurations:
  - `common/` - Shared settings
  - `core/` - Data assimilation configurations  
  - `cycle/` - Cycle (i.e. multiple module calls) configurations
  - `int2lm/` - Remapping of initial and boundary conditions
  - `more/` - Model run configurations
  Some module contain the following sub-directory:
  - `const/` - Job submission templates

## Getting Started

1. **Prerequisites**:
   - Install BACY from DKRZ GitLab
   - For Scenario 3: Install nwprun from Arpae-SIMC GitHub
   - Set up ecFlow (see `tools/ecflow/`)
   - Create Python environment (see `tools/venv_ecflow/`)

2. **Configuration**:
   - Overwrite BACY/nwprun config files with provided versions
   - Verify paths in all configuration files
   - Check grid names in all configuration files (e.g. R19B07 for LAM, R03B07 for global)
   - Check forecast duration and number of ensemble members in all BACY configuration and ecFlow suite definition

3. **Usage**:
   Basic information on the scenario are available in the scenario-specific README files.
   More information and specific examples available in the `tutorial.pdf` file

## Visualization

The `visualization/` directory contains Jupyter notebooks for:
- Interactive visualization of native grid data
- Static visualization of regular grid data
See `visualization/README.txt` for complete instructions.
