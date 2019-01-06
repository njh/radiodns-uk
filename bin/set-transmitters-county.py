#!/usr/bin/env python
#
# This script is written in Python because it has much better support for GIS
# I tried Ruby's rgeo and found it to be incredibly slow
#
# This script uses the GDAL Python bindings
#
# Debian: apt install python-gdal
# Mac: brew install gdal
#

from osgeo import ogr
import sqlite3
import glob

conn = sqlite3.connect('database.sqlite')
conn.row_factory = sqlite3.Row


def set_county(conn, transmitter_id, county):
    cur = conn.cursor()
    sql = 'UPDATE transmitters SET county=? WHERE id=?'
    result = cur.execute(sql, (county, transmitter_id))
    if result.rowcount != 1:
        raise Exception('Failed to set county for transmitter ' + str(transmitter_id))
    conn.commit()


# First load the features from each of the GeoJSON files
features = []
driver = ogr.GetDriverByName('GeoJSON')
for file in glob.glob('counties/*.json'):
    datasource = driver.Open(file, 0)
    layer = datasource.GetLayer(0)
    for feature in layer:
        features.append(feature)

print 'Loaded ' + str(len(features)) + ' geographic features'


# Next try and work out which county each transmitter is within
cur = conn.cursor()
cur.execute('SELECT * FROM transmitters ORDER BY ngr')
for transmitter in cur:
    pt = ogr.Geometry(ogr.wkbPoint)
    pt.SetPoint_2D(0, transmitter['long'], transmitter['lat'])

    found_feature = False
    for feature in features:
      ply = feature.GetGeometryRef()
      if ply.Contains(pt):
          set_county(conn, transmitter['id'], feature['name'])
          found_feature = True
          break

    if found_feature == False:
      print 'Warning: failed to find county for ' + transmitter['name']


conn.close()
