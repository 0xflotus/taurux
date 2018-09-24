#!/bin/bash

git log --reverse | grep Author | sed 's/<.*>//g' | sort | uniq | sed 's/Author: //g' > AUTHORS
