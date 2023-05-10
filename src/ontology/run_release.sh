# Running the FYPO release pipeline

# 1. First, lets make sure the ODK is up to date
docker pull obolibrary/odkfull

# 2. Next lets run the preprocessing.
# This process results in an updated source file fypo-edit-release.owl
sh run.sh make prepare_release -B
