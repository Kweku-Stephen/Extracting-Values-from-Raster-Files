#
#require(disk.frame)






require(arrow)
require(dplyr)

# Output Directory For SUH
if(!file.exists("H:/Dr.Cater/SUH/MWLMask")) dir.create("H:/Dr.Cater/SUH/MWLMask")

# SUH mould-wetland mask
suh_mw_mask1 <- arrow::open_csv_dataset(
	file.path(
		"H:/Dr.Cater/SUH",
		grep("2021_01_10", dir(path = "H:\\Dr.Cater\\SUH"), value = TRUE)
	)
) 









suh_mw_mask <- arrow::open_csv_dataset(
	file.path(
		"H:/Dr.Cater/SUH",
		grep("2021_01_10", dir(path = "H:\\Dr.Cater\\SUH"), value = TRUE)
	)
) %>%
	mutate(flag = ifelse(is.na(value) | value == 0, 0, 1)) %>%
	filter(flag == 1) %>% 
	select(row, col) |> 
	collect() |> 
	with(paste(row, col, sep = "_"))


suh <- arrow::open_dataset("H:/Dr.Cater/SUH")






















# Masking SUH Files
#
numb = length(dir(path = "H:/Dr.Cater/SUH", pattern = ".csv"))

ddt <- data.table::fread(
	
	dir(
		path = "H:/Dr.Cater/SUH", 
		pattern = ".csv", 
		full.names = TRUE
	)[numb],
	nThread = 5
	
) 

#
cl <- parallel::makeCluster(type = 'PSOCK', spec = 5)
workers = parallel::splitIndices(nrow(ddt), length(cl))
parallel::clusterExport(cl, c("suh_mw_mask"))
#
parallel::clusterApply(
	cl,
	
	x = workers,
	
	\(x, data, mask) {
		
		data[x, ] |> . =>
			.[paste(.[ ,row], .[ ,col]) %in% mask]
		
	},
	data = ddt,
	mask = suh_mw_mask
)


	
dir(
	path = "H:/Dr.Cater/SUH", 
	pattern = ".csv", 
	full.names = TRUE
)[numb]

|> . =>
	.[paste(.[ ,"row"], .[ ,"col"], sep = "_") %in% suh_mw_mask]





#



# |> . =>
# 	.[(with(., paste(row, col, sep = "_"))) %in% suh_mw_mask] |> 
# 	
# 	data.table::fwrite(
# 		file = file.path(
# 			"H:/Dr.Cater/SUH/MWLMask",
# 			dir(
# 				path = "H:/Dr.Cater/SUH", 
# 				pattern = ".csv"
# 			)[numb]
# 		)
# 	)	






#write_dataset("H:/Dr.Cater/SUH/MWLMask/FiteredMask.csv", format = "csv")



suh <- arrow::open_csv_dataset(sources = "H:/Dr.Cater/SUH/")

suh |> 
	filter(!is.na(value))
