## Customize Makefile settings for fypo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

pre_release:
	$(ROBOT) merge -i $(SRC) -i import-statements.owl -o fypo-edit-release.owl
