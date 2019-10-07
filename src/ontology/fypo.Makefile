## Customize Makefile settings for fypo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

fypo-edit-release.owl: $(SRC) import-statements.owl
	$(ROBOT) merge -i $< -i import-statements.owl -o $@

pre_release: fypo-edit-release.owl