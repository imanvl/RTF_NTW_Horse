Description: This script uses a fitness model to bootstrap directed network ensembles
	     from existing incomplete network data.

Folder structure: 'code' --> matlab code is stored here.
		  'data_bootstrap_input'--> csv files with network information are stored here. 
		  'data_bootstrap_output'--> network ensembles are stored here as csv edgelists

Input data format: Input information should be stored in two .csv file types. 
	           
                   1) File type 1 should contain nodes attributes. The current format requires the following variables in the                       following order: time, node id, amount of capital, amount of total assets. 
		      Each file should be named with 4 digits indicating year of the snapshot, 2 digits indicating quarter or                       month, and the suffix '_capital'. See sample file in the input folder.

	           2) File type 2 should contain an edgelist for the known network. For each edge, properties are stored in the                       following order: time, source node id, end node is, exposure weight. Each file should be named with 4 		              digits indicating year of the snapshot, 2 digits indicating quarter or month, and the suffix '_capital'.                        See sample file in the input folder.

                   NOTE: Both formats and input data types can be changed by the user, provided that the Matlab code is also 		           adjusted for the changes.

                   WARNING: There must be as many type 1 files as type 2 files!

Instructions: 1) Copy input data in the input folder.
              2) Open the main file 'f_bootstrap_net.m’ in the code folder.
	      3) Set initial parameters as instructed in the code.
              4) Run the analysis. 
              5) Access network ensembles in the subfolder located in the output folder. 

Author: Stefano Gurciullo, stefano.gurciullo.11@ucl.ac.uk

Version: 1.0

Date: 29/05/2014

This code is released on a Creative Commons Attribution-NonCommercial CC BY-NC License. 



