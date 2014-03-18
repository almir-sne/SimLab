#!/bin/bash

make_require_relative_in_files(){
	for j in *; do
		if [ -d $j ]; then 
			cd $j;
			make_require_relative_in_files "$1../";
			echo "$1../";
			t=$1;
			for i in *; do
				sed -i "s@require 'spec_helper'@require_relative '$1spec_helper'@" $i;
			done;
			cd ../;
		fi
	done;
}


make_require_relative_in_files "../";