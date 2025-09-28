Sys.setenv("_R_USE_PIPEBIND_" = "true")
require(raster)
require(data.table)


# mask <- fread(file.path(
#   "F:/Dr.Cater/SUH",
#   grep("2021_01_10", dir(path = "F:\\Dr.Cater\\SUH"), value = TRUE)
#   )
# ) %>%
#   mutate(flag = ifelse(is.na(value) | value == 0, 0, 1)) %>%
#   filter(flag == 1) %>% 
#   select(row, col)

###### Next is 
number = length(dir(
	path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
	pattern = ".tif$",
	full.names = TRUE
))

#############################################################

#
for(i in 1:2) print(gc())

dat <- (dir(
	path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
	pattern = ".tif$",
	full.names = TRUE
)[number])  |> 
	raster::raster() |> 
	raster::as.matrix()

# col and Row names
dimnames(dat) <- list(
	paste("row", 1:nrow(dat)),
	paste("col", 1:ncol(dat))
)

#
datT <- dat |> . =>
	data.table::data.table(
		row = rownames(.),
		.
	)

#
datT <- data.table::melt.data.table(
	datT,
	id.vars = "row",
	measure.vars = 2:ncol(datT),
	variable.name = "col"
)

#
data.table::setorder(datT, "row") 

# gabbage collector
for(i in 1:2) print(gc()) 


# Writing Raw Unmasked data out
data.table::fwrite(
	datT,
	file = file.path(
		"E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
		paste(
			dir(
				path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
				pattern = ".tif$"
			)[number],
			".csv"
		)
	),
	na = "NA"
)


# masking
datT <- datT[paste0(datT$row, datT$col) %in% paste0(mask$row, mask$col)]


#
# cl <- parallel::makeCluster(spec = 4, type = "PSOCK")

#
# datT <- parallel::clusterApply(
#   cl,
#   
#   parallel::splitIndices(nrow(datT, length(cl))) %>% 
#     lapply(\(vec) datT[vec]),
#   
#   fun = \(data, msk) data[paste0(dataT$row, dataT$col) %in% paste0(msk$row, msk$col)]
# ) %>% 
#   do.call("rbind", .)

#
# parallel::stopCluster(cl)



# Writing mask out
data.table::fwrite(
	datT,
	file = file.path(
		"E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI/maskedFiles", 
		paste(
			dir(
				path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
				pattern = ".tif$"
			)[number],
			".csv"
		)
	),
	na = "NA"
)


#
sprintf("Next is %i", number - 1)
number = number - 1
