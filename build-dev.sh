#!/usr/bin/env bash

drush make --concurrency=5 build-civihr-package.make.yml site --overrides=civihr-dev.make.yml --contrib-destination=profiles/civihr
