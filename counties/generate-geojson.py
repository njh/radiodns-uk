#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# This script creates a GeoJSON file for each of the ceremonial counties
#

from osgeo import ogr
from collections import OrderedDict
import json
import os
import re
import csv
import subprocess

OSGB36_SHP_FILE = 'boundary-line-ceremonial-counties-shp/Boundary-line-ceremonial-counties_region.shp'
OSGB_WGS84_SHP_FILE = 'boundary-line-ceremonial-counties-wgs84-shp/boundary-line-ceremonial-counties-wgs84.shp'
OSNI_WGS84_SHP_FILE = 'OSNI_Open_Data_50K_Admin_Boundaries_–_Counties/OSNI_Open_Data_50K_Admin_Boundaries_–_Counties.shp'
SIMPLIFY_TOLERENCE = 0.001
GEOJSON_OPTIONS = ['COORDINATE_PRECISION=6', 'RFC7946=YES']


# FIXME: can this efficiently be re-written in Python, instead of calling ogr2ogr?
if not os.path.exists(OSGB_WGS84_SHP_FILE):
    print "Converting OS Shapefile to WGS84"
    target_dir = os.path.dirname(OSGB_WGS84_SHP_FILE)
    if not os.path.exists(target_dir):
        os.mkdir(target_dir)

    subprocess.check_call([
        'ogr2ogr',
        '-f', 'ESRI Shapefile',
        '-t_srs', 'EPSG:4326',
        OSGB_WGS84_SHP_FILE,
        OSGB36_SHP_FILE
    ])


def getFieldNames( layer ):
    fieldNames = []
    ldefn = layer.GetLayerDefn()
    for n in range(ldefn.GetFieldCount()):
        fdefn = ldefn.GetFieldDefn(n)
        fieldNames.append(fdefn.name)
    return fieldNames

def intOrNone(str):
    if str == '':
      return None
    else:
      return int(str)

def writeJson(filename, data):
    str = json.dumps(data, indent=2)
    
    # Hacky way of changing coordinates to be on a single line
    # Results in smaller files and easier diffs
    str = re.sub(r'\[\s*(\-?\d+\.\d+),\s*(\-?\d+\.\d+)\s*\]', r'[\1, \2]', str)    

    with open(filename, 'wb') as outfile:
        outfile.write(str)


def processShapeFile(filename, counties):
    "convert a ShapeFile to multiple GeoJSON"
    print "Processing: " + os.path.basename(filename)
    file = ogr.Open(filename)
    layer = file.GetLayer(0)

    featureCount = layer.GetFeatureCount()
    fieldNames = getFieldNames(layer)
    if 'NAME' in fieldNames:
        countyField = 'NAME'
    elif 'CountyName' in fieldNames:
        countyField = 'CountyName'
    else:
        raise Exception("Unable to get field for name of county")

    print "Number of features is: %d" % featureCount
    for feature in layer:
        feature_name = feature.GetField(countyField)
        county = counties[feature_name]
        json_filename = re.sub(r"\W+", '-', county['Name'].lower()) + '.json'

        if not os.path.exists(json_filename):
          print " => Generating: " + json_filename
          geom = feature.geometry()
          simple = geom.Simplify(SIMPLIFY_TOLERENCE)
          feature.SetGeometry(simple)
          data = feature.ExportToJson(as_object=True, options=GEOJSON_OPTIONS)
          output = OrderedDict([
            ('type', 'Feature'),
            ("properties", OrderedDict([
              ('name', county['Name']),
              ('country', county['Country']),
              ('wikidata-id', county['Wikidata ID']),
              ('osm-relation-id', intOrNone(county['OSM Relation ID']))
            ])),
            ("geometry", data['geometry'])
          ])

          writeJson(json_filename, output)

counties = {}
with open('counties.csv', 'rb') as csvfile:
  reader = csv.DictReader(csvfile)
  for row in reader:
    counties[row['Shapefile Feature Name']] = row

processShapeFile(OSGB_WGS84_SHP_FILE, counties)
processShapeFile(OSNI_WGS84_SHP_FILE, counties)

