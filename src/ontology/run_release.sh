# Running the FYPO release pipeline

# 1. First, lets make sure the ODK is up to date (I comment this out because I use even newer version)
# docker pull obolibrary/odkfull

# 2. Next lets run the preprocessing.
# This process results in an updated source file fypo-edit-release.owl
sh run.sh make pre_release -B

# 3. Now lets run the proper release. Note that here, we are overwriting the SRC variable to be the newly created fypo-edit-release.owl
# This process generates everything like the simple and base releases
# All deviations from the standard OBO process can be found in the fypo.Makefile file
sh run.sh make SRC=dpo-edit-release.owl prepare_release -B
