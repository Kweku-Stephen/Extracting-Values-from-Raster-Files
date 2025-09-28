################################################################################

# pipebind operator
Sys.setenv("_R_USE_PIPEBIND_" = "true")
# Cluster
cl <- parallel::makeCluster(type = "PSOCK", spec = 3)

# Data Import and extracting matrix ####
dat <- parallel::clusterApplyLB(
	
	#cluster
	cl,
	
	# Data
	(dir(
		path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
		pattern = ".tif",
		full.names = TRUE
	)[1:3]),
	
	# Function
	\(path) raster::raster(path) 
) |> . =>
	# Converting to matrix
	parallel::clusterApplyLB(
		cl,
		.,
		\(data) raster::as.matrix(data) 
	) |> 
	# Naming elements of the list above
	setNames(
		dir(
			path = "E:/Dr.Cater/T18SUJ_no_cloud_HerbWet_NDVI",
			pattern = ".tif"
		)[1:3]
	)



# Extraction ####
# Output Directory
if(!file.exists("output")) dir.create("output")

# Exporting data to all nodes
parallel::clusterExport(cl, c("dat"))

parallel::clusterApply(
	
	cl,
	x = 1:length(dat), # chunking on workers side
	
	fun = \(x, data) {
		# data for worker x
		dt <- data[[x]]
		# Naming rows and columns
		dimnames(dt) <- list(
			paste("row", 1:nrow(dt)),
			paste("col", 1:ncol(dt))
		)
		# Converting to long format
		dt = data.table::data.table(row = rownames(dt), dt) |>
			data.table::melt.data.table(
				id.vars = "row",
				measure.vars = 2:ncol(dt),
				variable.name = "col"
			)
		#
		return(dt)
		
	},
	data = dat
	
) |> . =>

# Ordering
parallel::clusterApply(
	cl,
	x = 1:length(cl),
	\(x, data) {
		# data for worker X
		dt1 <- data[[x]]
		#Ordering by "row" column
		data.table::setorder(dt1, "row")
	},
	data = .
) -> test

# clearing unused memory
gc()

# removing data from all workers
parallel::clusterEvalQ(cl, \() rm(dat))

# Writing Files out
parallel::clusterApplyLB(
	cl,
	x = 1:3,
	\(x, data, fileName) {
		
		data.table::fwrite(
			dt1, 
			file = file.path("output", paste(fileName[x], ".csv")), 
			na = "NA"
		)
		
	},
	data = test,
	fileName = names(dat)
)


# Stop Cluster
parallel::stopCluster(cl)






