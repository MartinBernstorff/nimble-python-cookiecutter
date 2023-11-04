template_default_dir = nimble-python

test-template:
	# Install cruft if not already installed
	pip install cruft || true
	cruft create . -y --overwrite-if-exists --extra-context '{"release_to_pypi": "yes"}'
	
	# Test the template
	# Create the config file if it does not exist
	mkdir -p ~/.config/gh
	touch ~/.config/gh/hosts.yml
	docker rm -f $(template_default_dir) || true
	cd $(template_default_dir) && docker build . -t $(template_default_dir)
	cd $(template_default_dir) && docker run $(template_default_dir) make validate

push:
	git push --set-upstream origin HEAD
	git push

create-pr:
	gh pr create --fill-first || true

enable-automerge:
	gh pr merge --auto --merge --delete-branch

merge-main:
	git fetch
	git merge origin/main

create-random-branch:
	@git checkout -b "$$(date +'%d_%H_%M')_$(shell cat /dev/urandom | env LC_ALL=C tr -dc 'a-z' | fold -w 5 | head -n 1)"

grow:
	make pr
	@echo "––– 🎉🎉🎉 All tests succeeded! Growing into a new branch 🌳 –––"
	make create-random-branch

pr:
	make merge-main
	make push
	make create-pr
	make test-template
	make enable-automerge