doMerge() {

  echo "Using Forecast: $FORECAST"
  echo "Using Crop plan: $CROP_PLAN"
  echo "Using Products: $PRODUCTS"
  echo "Using Work Dir: $WORK_DIR"

  cd $WORK_DIR
  rm *.json *.txt

  #
  # csv to json
  #
  csvjson $FORECAST | jq > forecast.json
	csvjson $CROP_PLAN | jq > Crop_plan.json
	csvjson $PRODUCTS | jq > products.json

  # 
  # Data Scrub 
  #
  sed -i "" 's/Est. Yield/estYield/g' Crop_plan.json #remove space from json key
  sed -i "" 's/ Stems//g' Crop_plan.json # remove " Stems" from estYield, this will make it a number
  cat products.json  | iconv -f utf-8-mac -t utf-8 | sed 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/' > products-scrub.json
  cat Crop_plan.json | iconv -f utf-8-mac -t utf-8 | sed 'y/āáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜĀÁǍÀĒÉĚÈĪÍǏÌŌÓǑÒŪÚǓÙǕǗǙǛ/aaaaeeeeiiiioooouuuuüüüüAAAAEEEEIIIIOOOOUUUUÜÜÜÜ/' > Crop_plan-scrub.json
  mv products.json products-backup.json
  mv Crop_plan.json Crop_plan-backup.json
  mv products-scrub.json products.json
  mv Crop_plan-scrub.json Crop_plan.json

  #
  # Generate a unique list of variety to drive the loop
  #
  #jq --raw-output '.[].Variety'  Crop_plan.json | sort | uniq > variety-list.txt
  jq --raw-output '.[].SKU'  forecast.json | sort | uniq > sku-list.txt
    
  # init with the start of an array
  echo "[" > products-updated.json
  update_count=0;
  # loop through each product and update with infrormation from crop plan
  # while read sku; do

  #   # Set fields from forecast sku
  #   variety=$(jq --raw-output '.[] | select (.SKU == "$SKU") | .Variety' forecast.json)
  #   plant=$(jq --raw-output '.[] | select (.SKU == "$SKU") | .Plant' forecast.json)
  #   week1=$(jq --raw-output '.[] | select (.SKU == "$SKU") | ."This Week"' forecast.json)

    # compuge EST_YIELD
    # jq --raw-output ".[] | select(.Variety==\"$v\") | .estYield" Crop_plan.json > estyield-list.txt
    # est_yield=$(awk '{s+=$1} END {printf "%.0f\n", s}' estyield-list.txt) # sum up multiple occurances

    # echo "*****************************************[$sku]*******************************************************"

    # find product by sku
    product_count=$(jq ". | length" products.json)
    for (( p=0; p<$product_count; p++ ))
    do
      # echo p [$p]

      # working record
      jq -c .[$p] products.json > product-record.json
      product_sku=$(jq --raw-output .SKU product-record.json)

#
#
# need to do this:
eval "jq --raw-output '.[] | select (.SKU == \"$s\") | .SKU' ./wrk/forecast.json"
#
#
      jq --raw-output '.[] | select (.SKU == $product_sku) | .SKU' forecast.json > SKU.txt
      sku=$(cat SKU.txt)
      echo sku $sku
      # sku=$(jq --raw-output '.[] | select (.SKU == "AST-VALPK") | .SKU' forecast.json) 
      variety=$(jq --raw-output '.[] | select (.SKU == "$product_sku") | .Variety' forecast.json)
      plant=$(jq --raw-output '.[] | select (.SKU == "$product_sku") | .Plant' forecast.json)
      week1=$(jq --raw-output '.[] | select (.SKU == "$product_sku") | ."This Week"' forecast.json)

echo forecast sku [$sku] product_sku [$product_sku] >> log.txt
# echo forecast variety [$variety]
# echo product_sku [$product_sku]

      # echo compare [$sku] to [$product_sku]
      if [ "$sku" == "$product_sku" ]; then
        update_count=$((update_count+1))
        echo " "
        echo "***************************************************"
        echo "Found sku: $product_sku at index $p" update_count $update_count
        echo "***************************************************"
        echo " "
        yq w product-record.json Description "$plant - $variety (forcast: $week1)" --tojson --inplace

        if [ "$update_count" -gt "1" ]; then
          printf "," >> products-updated.json
        fi
        cat product-record.json >>  products-updated.json
      fi
    done

  # done <sku-list.txt
  # # close up the array
  echo "]" >>  products-updated.json

}

printUsage() {

  echo ""
  echo "This script will merge a tend csv export with a squarespace products export:"
  echo ""
  echo "Usage:"
  echo "  merge.sh [path/to/csv_export/airtable/forecast.csv] [path/to/csv_export/tend/Crop_plan.csv] [path/csv_export/squarespace/products.csv]"
  echo ""
  echo "Example:"
  echo "  $ ./merge.sh tend/cvs_export/Crop_plan.csv squarespace/products.csv"
  echo ""
}   

#  set -x

# Check for input parm
if [[ -z "$1" ]]; then
  echo "Airtable forcast.csv is required"
  printUsage
elif [[ -z "$2" ]]; then
  echo "Tend Crop_plan.csv is required"
  printUsage
elif [[ -z "$3" ]]; then
  echo "Squarespace procucts.csv is required"
  printUsage
else 
  FORECAST=$1
  CROP_PLAN=$2
  PRODUCTS=$3
  WORK_DIR="./wrk"
  mkdir -p $WORK_DIR

  doMerge

fi
