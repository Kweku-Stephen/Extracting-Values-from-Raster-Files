# pipebind operator
Sys.setenv("_R_USE_PIPEBIND_" = "true")
# Cluster
cl <- parallel::makeCluster(type = "PSOCK", spec = 5)

# Data Import and extracting matrix
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


# Extraction
# Workers/nodes
vec <- parallel::splitIndices(
	length(1:nrow(dat$T18SUJ_2021_01_10_nocld_HerbWet_NDVI.tif)), 
	5
)
# Exporting data to all nodes
parallel::clusterExport(cl, c("dat","vec"))
# parallel::clusterEvalQ(cl, {
# 	library(parallel)
# })
# Extracting data
parallel::clusterApply(
	
	cl,
	x = z,#vec, # chunking on workers side
	
	fun = \(x) {
		
		lapply(
			x,
			\(y){
				lapply(
					dat,
					\(mat){
						res = as.data.frame(mat) |> . =>
							.[y, ]
					}
				) |> . => do.call("rbind", .) |> . =>
					setNames(., paste("row", y, "col", 1:ncol(.), sep = ""))
			}
		)
		
	}
	
)

#
parallel::stopCluster(cl)






