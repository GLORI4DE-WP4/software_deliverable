Notes on the content of this directory
--------------------------------------

The Jupyter notebooks in this directory enable visualization of ICON model output on both the native triangular grid and regular lat/lon grid. 
To illustrate a wide variety of possible visualizations, we have implemented the following approach:
- Data on the native grid are shown interactively for a subset of variables across all model levels
- Data on the regular grid are shown as static images for a single variable (total precipitation) at the surface

Required Python packages are listed in the "requirements.txt" file in this directory. 
Note that the visualization runs independently from the ecFlow suite, so we created a dedicated Python virtual environment for it.


Example usage
--------------------------------------

Sample output files for both grids (produced by global and LAM runs) are available at:
https://drive.google.com/drive/folders/1YHxeHd_e8M5vNw21ik23mnCYZvyiI6RG?usp=drive_link

To test the notebooks:

1. Download and place these LAM files:
   - fc_R19B07.20241019060000_00000000 (native grid, forecast hour 0)
   - fc_R19B07.20241019060000_00010000 (native grid, forecast hour 1)
   - fc_R19B07_ll.20241019060000_00000000 (regular grid, forecast hour 0)
   - fc_R19B07_ll.20241019060000_00010000 (regular grid, forecast hour 1)
   in directory: "scenario_3/bacy/lam/bacy_more/data/20241019060000"

2. Download and place these global files:
   - fc_R03B07.2023051512_00000000 (native grid, forecast hour 0)
   - fc_R03B07.2023051512_00030000 (native grid, forecast hour 1)
   - fc_R03B07_ll.2023051512_00000000 (regular grid, forecast hour 0)
   - fc_R03B07_ll.2023051512_00030000 (regular grid, forecast hour 1)
   in directory: "scenario_4_s3/global/bacy/2023051512"

3. Download and place the grid files:
   - icon_grid_1000_R19B07_L.nc (LAM grid) → "scenario_3/bacy/bacy_data/routfoxfox/icon/grids/public/edzv"
   - icon_grid_1000_R03B07_L.nc (global grid) → "scenario_4_s3/bacy_data/routfoxfox/icon/grids/public/edzv"

Running the notebooks:

For local execution:
1. Activate the Python virtual environment containing the required packages:
   source [path_to_environment]/bin/activate
2. Navigate to this directory (containing the README.txt)
3. Start Jupyter server:
   jupyter notebook
4. A browser tab should open automatically with the notebook interface

For server execution:
1. Connect to the server with port forwarding:
   ssh -L 8888:localhost:8888 [username]@[server_address]
2. Activate the Python virtual environment:
   source [path_to_environment]/bin/activate
3. Launch Jupyter without browser:
   jupyter notebook --no-browser --port=8888
4. Access the notebook from your local browser at:
   http://localhost:8888

Using the notebooks:
1. Open the desired notebook (*.ipynb file)
2. Before execution:
   - Verify all file paths match your project structure
   - Confirm the grid name/number (e.g. R19B07 for LAM, R03B07 for global) matches your visualization needs
3. Execute cells sequentially:
   - Interactive visualizations using Panel will open a new tab with sliders/dropdown menus
   - Static visualizations will display directly below the executed cell

Notes:
- The first execution might take longer as data is loaded
- For large datasets, allow extra time for rendering
- Kernel restart may be needed if changing between global/LAM visualizations