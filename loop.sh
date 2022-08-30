#!/bin/bash
declare -a arr=("element1" "element2" "element3")

for i in "${arr[@]}"
do
   echo "$i"
   aws servicecatalog create-portfolio-share --portfolio-id port-syxr6e3b6fbzo --account-id $i
done