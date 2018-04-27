#!/usr/bin/env bash

drush make build-civihr-package.make.yml site --overrides=civihr-dev.make.yml --contrib-destination=profiles/civihr
