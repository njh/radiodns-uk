Ceremonial County Boundaries GeoJSON
------------------------------------

This directory contains [GeoJSON](http://geojson.org) files for the boundaries 
of each of the Ceremonial Counties of the United Kingdom of Great Britain
and Northern Ireland. Each county is a Feature object in its own file.

* In England these are known as [Ceremonial Counties](https://en.wikipedia.org/wiki/Ceremonial_counties_of_England)
* In Scotland these are known as [Lieutenancy Areas](https://en.wikipedia.org/wiki/Lieutenancy_areas_of_Scotland)
* In Wales these are known as [Preserved Counties](https://en.wikipedia.org/wiki/Preserved_counties_of_Wales)
* For Northern Ireland, I used the [historical six counties of Ireland](https://en.wikipedia.org/wiki/Counties_of_Northern_Ireland)

The Ceremonial Counties were defined by the [Lieutenancies Act 1997](https://en.wikipedia.org/wiki/Lieutenancies_Act_1997).

As far as I can tell there are no officially designated identifiers for the ceremonial counties.


Sources of County Boundary Data
-------------------------------

I sourced the County Boundary data for Great Britain from [Ordnance Survey](https://www.ordnancesurvey.co.uk): 
https://www.ordnancesurvey.co.uk/business-and-government/help-and-support/products/boundary-line.html

I sourced the County Boundary data for Northern Ireland from [OpenDataNI](https://www.opendatani.gov.uk):
https://www.opendatani.gov.uk/dataset/osni-open-data-50k-admin-boundaries-counties1


Instructions for re-building this dataset
-----------------------------------------

1. Install GDAL and Python bindings - Geospatial Data Abstraction Library.
    * On a Mac you can run `brew install gdal`
    * On a Debian/Ubuntu you can run `apt-get install python-gdal`
2. Download and extract the [boundary-line-ceremonial-counties-shp.zip](https://www.ordnancesurvey.co.uk/docs/support/boundary-line-ceremonial-counties-shp.zip) *Shapefile* from Ordnance Survey
3. Download and extract the Nothern Ireland county boundaries *Shapefile* from OpenDataNI:    [53073a8daf5547f0a0ed8d61268a1493_1.zip](http://osni-spatial-ni.opendata.arcgis.com/datasets/53073a8daf5547f0a0ed8d61268a1493_1.zip)
4. Run `python generate-geojson.py` to generate the GeoJSON files

The Python script converts the OSGB Shapefile to WGS-84 coordinates, simplifies the dataset and then writes a separate GeoJSON file for each county.

