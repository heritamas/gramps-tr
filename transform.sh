#!/usr/bin/env bash

while getopts i:o: flag
do
    case "${flag}" in
        i) input=${OPTARG};;
        o) output=${OPTARG};;
    esac
done

# cleanup
rm -rf out/md/*

# transform
java -cp saxon/saxon-he-11.4.jar net.sf.saxon.Transform -s:${input} -xsl:tr2.xsl -o:out/${output}