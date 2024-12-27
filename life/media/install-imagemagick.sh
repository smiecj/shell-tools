#!/bin/bash
set -exo pipefail

cd /tmp

## imagemagick
rm -rf ImageMagick
git clone ${github_url}/ImageMagick/ImageMagick
cd ImageMagick
git checkout tags/${image_magick_tag}

./configure
make
make install

cd ..
rm -r ImageMagick