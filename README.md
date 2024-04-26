# *Virtual Riesling* a GroIMP Model of *Vitis Vinifera* L.

This repository contains the
development version for the functional-structural plant model *Virtual Riesling*
to be executed in GroIMP (Growth Grammar-related Interactive Modelling Platform).

### Getting Started

Before you clone the repository, make sure that you have GroIMP (v1.5/1.6) installed on your computer. 
You can download GroIMP from the official website: <https://wwwuser.gwdg.de/~groimp/
grogra.de/software/groimp/index.html> or <https://gitlab.com/grogra/groimp>

To be able run the model, please contact us for additional installation instructions.

For Post-Processing you will need recent versions of `R` (>v.4.3) and `RStudio` (recommended, >v.2023.12.1 Build 402).


### Cloning the Repository

To clone the repository, use the following Git command:
"git clone https://github.com/dschmidt-hgu/ViRi-dev.git"

Extract the folders in `ViRi_Input/Cluster_Folders.zip` into `ViRi_Input` to fill the respective empty folders (`Folder_1`, ..., `Folder_12`). 


## Running the Model

- Open `GroIMP`  
- Navigate to `File > Open`    
- Select the `ViRi.gs` file in the folder `ViRi_dev`    
- Follow the more detailed example instructions below   


## Contact

For any futher queries or issues related to the model, please contact us:   
dominik.schmidt@hs-gm.de (primary contact)  
katrin.kahlen@hs-gm.de  
christopher.bahr@hs-gm.de  



## Related publications

- Schmidt, D., Bahr, C., Friedel, M., and Kahlen, K., Modelling Approach for Predicting the Impact of Changing Temperature Conditions on Grapevine Canopy Architectures. Agronomy, 9, 426, 2019. https://doi.org/10.3390/agronomy9080426
- Bahr, C., Schmidt, D., Friedel, M., and Kahlen, K., Leaf removal effects on light absorption in virtual Riesling canopies (*Vitis vinifera*), *in silico Plants*, Volume 3, Issue 2, diab027, 2021. https://doi.org/10.1093/insilicoplants/diab027  
- Bahr, C., Schmidt, D., and Kahlen, K. Missing Links in Predicting Berry Sunburn in Future Vineyards. *Front. Plant Sci.* 12:715906, 2021. https://doi.org/10.3389/fpls.2021.715906  
- Schmidt, D., Bahr, C., Kahlen, K., and Friedel, M., Towards a Stochastic Model to Simulate Grapevine Architecture: A Case Study on Digitized Riesling Vines Considering Effects of Elevated CO2. *Plants*, 11, 801, 2022. https://doi.org/10.3390/plants11060801  



## Funding

The model development has been partialy funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation), project numbers 449374897 and 432888308.


---

## Manual example simulation setup


### Simulation

#### 1. Open GroImp 

#### 2. Open `ViRi.gs` File in `ViRi_dev`

#### 3. Set paths in `Globals.rgg`

	static final String inputPath = 
	"/full/path/to/ViRi_Input/";

	static final String outputPath =
	"/full/path/to/ViRi_Output/";


#### 4. Change 3 lines of code in `main_develop.rgg`

to:

	const boolean compass = false;  

	const boolean transOn = true;   

	//enableView3DRepaint();  


... save these changes to disable visualiztaion during simulation


#### 5. Press button `loopSim`

---

### Post-Processing


#### 1. `ViRi_Output`

- Simulation produces 5 files in ViRi_Output    
- Sunburn Post-Processing relies on:  
	- `Berries_Minutes_`   
	- `Leaves_Minutes_`  


#### 2. Go to folder `ViRi_Post_Processing`

- launch `data_processing.Rproj` to get to `RStudio`   
- run script `process_ViRi_output.R`  

w/o `RStudio`

- run script `process_ViRi_output.R` in terminal mode
	- `Rscript process_ViRi_output.R`





### Optional settings to change scenario in `main_develop.rgg`

- rowOrientation: activate scene view (enableView3DRepaint(); and const boolean transOn = false;) and compass (const boolean compass = true;) to see orientation and cane growth direction  
- defoliateOnSide: left=left side of cane growth direction; right=right side of cane growth direction  
- defoliateAbove: leaf removal above z (height above ground)  
- defoliateBelow: leaf removal below z (height above ground)  

 


