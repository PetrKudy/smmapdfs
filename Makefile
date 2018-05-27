VERSION = $(shell git describe --abbrev=0 --tags)
REPO_FILES ?= git ls-files -z | xargs --null -I '{}' find '{}' -type f -print0
REPO_TXT_FILES ?= git ls-files -z | xargs --null -I '{}' find '{}' -type f -print0 | egrep -zZv '(png|svg)$$'

packages: clean
	python3 setup.py bdist_wheel
	git archive --format=tar.gz $(VERSION) > dist/django-smmapdfs-$(VERSION).tar.gz
	cd dist ; gpg --detach-sign -a *.whl
	cd dist ; gpg --detach-sign -a *.tar.gz

deploy-pypi:
	twine upload dist/*.whl
	twine upload dist/*.whl.asc

deploy: deploy-pypi
	echo Deployed

clean:
	rm -r dist ; exit 0
	rm -r smmapdfs.egg-info ; exit 0
	rm -r build ; exit 0

qa: qa-miscellaneous qa-https-everywhere

qa-miscellaneous:
	$(REPO_TXT_FILES) | grep -zZv 'setup.py$$' | xargs --null sed -i 's#LGPL\s*v3#LGPL-3.0#g;'

qa-https-everywhere:
	$(REPO_TXT_FILES) | xargs --null sed --regexp-extended --in-place 's#http(:\\?/\\?/)(momentjs\.com|overpass-turbo\.eu|www\.gnu\.org|stackoverflow\.com|(:?www\.)?openstreetmap\.(org|de)|nominatim\.openstreetmap\.org|taginfo\.openstreetmap\.org|wiki\.openstreetmap\.org|josm.openstreetmap.de|www.openstreetmap.org\\/copyright|github\.com|xkcd\.com|www\.heise\.de|www\.readthedocs\.org|askubuntu\.com|xpra\.org|docker\.com|linuxcontainers\.org|www\.ecma-international\.org|www\.w3\.org|example\.com|www\.example\.com)#https\1\2#g;'
	$(REPO_TXT_FILES) | xargs --null sed -i 's#http://overpass-api\.de#https://overpass-api.de#g;'
	$(REPO_TXT_FILES) | xargs --null sed --regexp-extended --in-place 's#http://(\w+\.wikipedia\.org)#https://\1#g;'
