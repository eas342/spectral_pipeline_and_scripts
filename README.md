# IRTF and General Reduction Tools
This repository contains some IRAF scripts and IDL scripts for viewing and processing spectrograph and image files.
It includes a pipeline for reducing IRTF SpeX prism data in time series modes.
The IRTF SpeX prism data should have 2 sources - a targe and reference star that are imaged on the slit simultaneously.
The pipeline is designed to work with data taken with the 3x30'' slit.
The pipeline will take raw data and apply the following:

 - Correct linearity, trim data
 - Apply flat and dark corrections
 - Shift images to account for pointing errors
 - Rectify the spectra
 - Correct for bad pixels
 - Extract spectral with optimal extraction techniques
This refereed paper describes the pipeline: http://adsabs.harvard.edu/abs/2014ApJ...783....5S

#Requirements
There is a hefty list of code requirements for this pipeline.
Be prepared that installing all these pieces may take a long time unless you already have experience with them.

 - `IRAF`
 - `IDL`
 - `added_scripts` IDL routines from E Schlawin. Put these in IDL path
 - Put this code repository in the IDL path

# Instructions
These are intended as reminders to oneself and not a complete set of instructions for a new user.

## A: Load the necessary NOAO procedures
    noao
    imred
    specred
    ccdred

You may get a warning with my IRAF about camera.dat.
A solution is available here:
http://iraf.net/forum/viewtopic.php?showtopic=1467939
    setinst
Choose `camera.dat`

## B: Prepare data
 - Put all data into a directory called "edited" - this will contain a duplicate of all raw data
 - All data files should be called `run*.fits` (it’s OK if they’re sky images called `runsky*.fits`)
 - All flat images (with relevant (3x60) slit) should be `flat*.fits`
 - All dark images should be `dark*.fits`
 - All arc images (only the 0.3 x 60 slit) should be arc*.fits
 - All sky files (if using) should be listed in sky_choices.txt
 - Get rid of all periods except for the ending of files may be file.a.fits or file.b.fits
 - Remove all files not explicitly described in this list
 - Make a "proc" directory adjacent to the edited folder
 - You may have to modify permissions to the fits files (they were all read only). Accomplished this with `chmod 755 *`

## C: Load all IRAF scripts
These can also be placed in the login.cl file so they are loaded with each log-in.

    task $adjust_headers=/Users/everettschlawin/es_programs/reduction_scripts/adjust_headers.cl
    task $reduction_script=/Users/everettschlawin/es_programs/reduction_scripts/reduction_script.cl
    task $reset_reduction=/Users/everettschlawin/es_programs/reduction_scripts/reset_reduction.cl
    task $extraction_script=/Users/everettschlawin/es_programs/reduction_scripts/extraction_script.cl
    task $reset_extraction=/Users/everettschlawin/es_programs/reduction_scripts/reset_extraction.cl
    task $cleanup_dup_files=/Users/everettschlawin/es_programs/reduction_scripts/cleanup_dup_files.cl

## D: Reduce data from the “edited” directory
The reduction steps will apply linearity corrections (optional), flat fields, bad pixel masks, dark subtractions and accounts for flexure of the telescope, which 
causes the spectra and background to shift positions.

Navigate to the `edited` directory which contains a copy of all relevant raw files.
Edit the `local_red_params.cl` file to have the correct parameters for your file.
You will need to set a trim region the default is `s1 = "[65:749,33:607]"`
Open the image to locate the sources. Make sure that the background box and background spectrum region are between the two sources.
X,Y coordinates are from the bottom left corner.
If you have local `b1 = yes`, it will use the sky flats. You’ll need to select a set of sky images to combine (called `sky_choices.txt`).
You can also have optional `mask_for_runsky005.fits` files to specify where to mask out sources.
If you are not using sky flats, set `b1 = no`

 - Run `adjust_headers` which will set all the `darktime` and other parameters needed by IRAF.
 - (optional) Correct for non-linearity with `IDL`. This can be done within `IRAF` with the following command: `!echo “correct_linearity” | idl`
 - Set the local parameters with custom values with `cl < local_red_params.cl`
 - Run the reduction script with `reduction_script`
 - If at any time, you need to re-run the script, use `reset_reduction` to clear out any previously created files. Note that this will wipe files from the `../proc` directory.

## E: Extract Spectra.
This step will rectify the images, extract spectra from each source, do background subtraction.
It first uses the `IRAF` `apall` routines, but then can be run again with custom optimal extraction techniques.
The resulting files are FITS images with flux and background as function of wavelength for each star.

Start by going through the images in the middle of the time series to be used as a reference aperture-finding.
Select an image with few artifacts, cosmic rays or star-like blemishes due to alpha particles from a Th-containing coating on the optics.
Next create a `local_parameters.cl` file where you will set the distance range between the sources and background fitting parameters (polynomial order).
You can copy a previous file, but will need to be sure that the distance range between the source apertures includes the true value.
The Argon line identification is a very tedious process. It is easier to start by copying the file from a previous extraction.

    mkdir database
    cp ../../other_source/bigdog/proc/database/idfirst_wavecal database/

 - Navigate to the “proc” directory.
 - After choosing the reference image above, write it to a file with `ls run_image_spc_00187.a.fits > ap_reference.txt`
 - Load in the extraction parameters with `cl < local_parameters.cl`
 - Create an initial `IRAF` extractions on the data by running `extraction_script`
 - If the first time running, edit the identification file so that the coefficients for Aperture 1 and Aperture 2 are identical and run again: `emacs database/idfirst_wavecal`
 - If at any time you need to re-run the extraction, first run `reset_extraction` to wipe the previously created files.
 - Run the custom IDL extraction routine with:

    `idl`
    `IDL> es_backsub`

## G: Known errors.
Error in image section specification - usually it happens when I haven’t loaded the local parameters in (either cl < local_red_parameters in the “edited” directory or cl < local_parameters in the “processed” directory).