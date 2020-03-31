#!/bin/sh

mkdir -p dist
docker run -v "`pwd`:/data" danielfett/markdown2rfc assurance-levels.md dist
