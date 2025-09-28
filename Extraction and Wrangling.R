#
require(parallel)
Sys.setenv("_R_USE_PIPEBIND_" = "true")
# test data
canopy <- raster::raster("E:/R Projects/Spatial Analysis with R/Spatial analysis with sf and raster in R/canopy.tif") |> 
	oceanmap::raster2matrix()
eg <- list(a = head(canopy), b = head(canopy), c = head(canopy))


# Cluster
cl <- parallel::makeCluster(spec = 5, type = "PSOCK")
vec = 1:nrow(eg$a)
parallel::clusterExport( cl, c("eg","vec") )

#
out <- parallel::clusterApply(
	
	cl,
	x = vec,
	fun = \(x) {
		
		lapply(
			eg, 
			\(mat) {
				res = as.data.frame(mat) |> . =>
					.[x, ]
				colnames(res) <- paste("row", x, "col", 1:ncol(res), sep = "")
				return(res)
				
			}
		) |> . =>
			do.call(rbind, .)
		
	}
	
) |> . =>
	setNames(., paste("row", 1:length(.), "s", sep = ""))

#
for(i in 1:length(out)) 
	write.csv(out[[i]], file = paste("row", i, "s", ".csv", sep = ""), row.names = TRUE)


# stop Cluster
parallel::stopCluster(cl)
