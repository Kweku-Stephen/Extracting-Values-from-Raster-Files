Sys.setenv("_R_USE_PIPEBIND_" = "true")
require(raster)
require(data.table)

dir.create("I:/Dr.Cater/T18SUH_no_cloud_HerbWet_NDVI/maskeds")

# mask
mask <- data.table::fread("F:/Dr.Cater/SUH/mask.csv") |> . =>
  .[ ,c("row", "col")]

###### Next is 
number = length(dir(
  path = "I:/Dr.Cater/T18SUH_no_cloud_HerbWet_NDVI",
  pattern = ".tif$",
  full.names = TRUE
))

#############################################################

#35
###############################################################

dat <- (dir(
  path = "I:/Dr.Cater/T18SUH_no_cloud_HerbWet_NDVI",
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
# datT <- within(
# 	data.table::data.table(row = rownames(dat)),
# 	{data.table::as.data.table(dat)}
# )

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
#datT <- datT[!is.na(value)]

#
data.table::setorder(datT, "row") 

# masking
dTr = paste0(datT$row, datT$col)
msr = paste0(mask$row, mask$col)
datT = datT[dTr %in% msr]

#
data.table::fwrite(
  datT,
  file = file.path(
    "I:/Dr.Cater/T18SUH_no_cloud_HerbWet_NDVI/maskeds", 
    paste(
      dir(
        path = "I:/Dr.Cater/T18SUH_no_cloud_HerbWet_NDVI",
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
