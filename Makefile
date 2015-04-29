R:

	Rscript -e "rmarkdown::render('data/stateparks.Rmd')"
	open data/stateparks.html

R_deploy:

	cp data/stateparks.html /Volumes/www_html/multimedia/graphics/projectFiles/Rmd/
	rsync -rv data/stateparks_files /Volumes/www_html/multimedia/graphics/projectFiles/Rmd
	open http://private.boston.com/multimedia/graphics/projectFiles/Rmd/stateparks.html

download:

	rm data/downloaded/*; cd data/downloaded; \
		curl http://wsgw.mass.gov/data/gispub/shape/open_spc/openspace.zip > openspace.zip; unzip openspace.zip; rm -rf openspace.zip;
		curl http://dds.cr.usgs.gov/ltaauth//hsm/lta1/archive/gtopo_v2/075/GMTED2010N30W090_075.zip > GMTED2010N30W090_075.zip; unzip GMTED2010N30W090_075.zip; rm -rf GMTED2010N30W090_075.zip;

process:

	rm data/output/*; cd data/output; \
		mapshaper -i ../downloaded/OPENSPACE_POLY.shp encoding=utf8 -o openspace.json cut-table

get_elevation:

	cd data/downloaded; \
		gdalinfo -stats 30n090w_20101117_gmted_mea075.tif | grep Minimum;

listgeo:

	listgeo ${file} > data/output/meta.txt;

slope:

	gdaldem slope ${file} data/output/slope.tif -s 111120;
	gdaldem color-relief data/output/slope.tif data/slope.txt data/output/slopeshade.tif;

hillshade:	

	gdaldem hillshade ${file} data/output/hills.tif -s 111120;

color-relief:

	gdaldem color-relief ${file} data/ramp.txt data/output/color.tif;

merge:

	cd data/output; \
		convert -gamma 0.5 hills.tif hills_gamma.tif; \
		convert -gamma 1 slopeshade.tif slopeshade_gamma.tif; \
		convert color.tif hills_gamma.tif -compose Overlay -composite output_temp.tif; \
		convert output_temp.tif slopeshade_gamma.tif -compose linear-burn -composite output.tif; \
		geotifcp -g meta.txt output.tif output-merged.tif;

tile-all: listgeo slope hillshade color-relief merge

tile:

	make tile-all file='data/downloaded/30n090w_20101117_gmted_mea075.tif';


















