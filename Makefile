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