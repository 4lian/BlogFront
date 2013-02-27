#!/bin/bash

rm -rf `ls -l1 public`
node_modules/.bin/brunch watch
