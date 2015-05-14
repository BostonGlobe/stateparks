R:

	Rscript -e "rmarkdown::render('data/stateparks.Rmd')"
	open data/stateparks.html

R_deploy:

	cp data/stateparks.html /Volumes/www_html/multimedia/graphics/projectFiles/Rmd/
	rsync -rv data/stateparks_files /Volumes/www_html/multimedia/graphics/projectFiles/Rmd
	open http://private.boston.com/multimedia/graphics/projectFiles/Rmd/stateparks.html

download:

	# # GMTED rasters
	# cd data/downloaded; mkdir GMTED; cd GMTED; curl http://dds.cr.usgs.gov/ltaauth//hsm/lta1/archive/gtopo_v2/075/GMTED2010N30W090_075.zip > GMTED2010N30W090_075.zip; unzip GMTED2010N30W090_075.zip; rm -rf GMTED2010N30W090_075.zip;

	# MassGIS layers
	cd data/downloaded; mkdir MassGIS; cd MassGIS; \
		curl http://wsgw.mass.gov/data/gispub/shape/open_spc/openspace.zip > openspace.zip; unzip openspace.zip; rm -rf openspace.zip; \
		curl http://wsgw.mass.gov/data/gispub/shape/state/towns.zip > towns.zip; unzip towns.zip; rm -rf towns.zip; \
		curl http://wsgw.mass.gov/data/gispub/shape/ne/nemask.zip > nemask.zip; unzip nemask.zip; rm -rf nemask.zip;

	# TIGER layers
	cd data/downloaded; mkdir TIGER; cd TIGER; \
		curl ftp://ftp2.census.gov/geo/tiger/TIGER2014/STATE/tl_2014_us_state.zip > tl_2014_us_state.zip; unzip tl_2014_us_state.zip; rm -rf tl_2014_us_state.zip;

	# OpenStreetMap layers
	cd data/downloaded; mkdir OpenStreetMap; cd OpenStreetMap; \
		curl http://data.openstreetmapdata.com/water-polygons-split-4326.zip > water-polygons-split-4326.zip; unzip water-polygons-split-4326.zip; rm -rf water-polygons-split-4326.zip; \

make_MA:

	cd data/downloaded/MassGIS; mapshaper -i TOWNS_POLY.shp -dissolve -o MA.shp

make_MA-ocean:

	cd data/downloaded/OpenStreetMap/water-polygons-split-4326; ogr2ogr -clipsrc -74.628 40.464 -69.058 43.948 MA-ocean.shp water_polygons.shp;
	echo "HEY! Make sure to dissolve/merge all these polygons in QGIS."

shadedrelief-clean:
	rm data/output/*;

shadedrelief-listgeo:

	listgeo ${file} > data/output/meta.txt;

shadedrelief-slope:

	gdaldem slope ${file} data/output/slope.tif -s 111120;
	gdaldem color-relief data/output/slope.tif data/slope.txt data/output/slopeshade.tif;

shadedrelief-hillshade:	

	gdaldem hillshade ${file} data/output/hills.tif -s 111120;

shadedrelief-color:

	gdaldem color-relief ${file} data/ramp.txt data/output/color.tif;

shadedrelief-merge:

	cd data/output; \
		convert -gamma 0.5 hills.tif hills_gamma.tif; \
		convert -gamma 1 slopeshade.tif slopeshade_gamma.tif; \
		convert color.tif hills_gamma.tif -compose Overlay -composite output_temp.tif; \
		convert output_temp.tif slopeshade_gamma.tif -compose linear-burn -composite output.tif; \
		geotifcp -g meta.txt output.tif output-merged.tif;

shadedrelief-clip:

	gdalwarp -dstnodata 255 -te -73.50823953186817 41.23796168918525 -69.92780164508935 42.886818298840936 data/output/output-merged.tif data/output/shadedrelief-MA.tif;

shadedrelief-all-steps: shadedrelief-clean shadedrelief-listgeo shadedrelief-slope shadedrelief-hillshade shadedrelief-color

shadedrelief:

	make shadedrelief-all-steps file='data/downloaded/GMTED/30n090w_20101117_gmted_mea075.tif';
	cd data/output; \
		gdalwarp -dstnodata 255 -te -73.50823953186817 41.23796168918525 -69.92780164508935 42.886818298840936 color.tif color-MA-bbox.tif; \
		gdalwarp -dstnodata 255 -te -73.50823953186817 41.23796168918525 -69.92780164508935 42.886818298840936 hills.tif hills-MA-bbox.tif; \
		gdalwarp -dstnodata 255 -te -73.50823953186817 41.23796168918525 -69.92780164508935 42.886818298840936 slopeshade.tif slopeshade-MA-bbox.tif;
	# cd data/output; \
	# 	rm -rf color.tif; \
	# 	rm -rf hills.tif; \
	# 	rm -rf hills_gamma.tif; \
	# 	rm -rf output.tif; \
	# 	rm -rf output_temp.tif; \
	# 	rm -rf slope.tif; \
	# 	rm -rf slopeshade.tif; \
	# 	rm -rf slopeshade_gamma.tif; \


gabriel:

	gdalwarp -t_srs EPSG:26986 data/shaded-relief-MA.tif data/shaded-relief-MA-26986.tif











# get_elevation:

# 	cd data/downloaded; \
# 		gdalinfo -stats 30n090w_20101117_gmted_mea075.tif | grep Minimum;


# # clipwater:

# # 	ogr2ogr -clipsrc -74.628 40.464 -69.058 43.948 data/output/water.shp data/downloaded/water-polygons-split-4326/water_polygons.shp

# # all_1: clean shadedrelief clipshadedrelief_1 clipwater

# # 	echo "dissolve water in QGIS!"

# # all 2:

# # massachusetts-with-padding_land:

# # 	ogr2ogr -clipsrc -74.628 40.464 -69.058 43.948 data/output/massachusetts-with-padding_land.shp data/downloaded/land-polygons-complete-4326/land_polygons.shp

# # massachusetts-towns:

# # 	ogr2ogr -clipsrc data/output/massachusetts-with-padding_land.shp data/output/massachusetts-towns.shp data/downloaded/BOUNDARY_POLY.shp









