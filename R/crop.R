

#' @title A dataset of annotations using openseadragon
#' @description A dataset of annotations using openseadragon
#' @name openseadragon_areas
#' @docType data
#' @examples
#' data(openseadragon_areas)
#' openseadragon_areas
#' attr(openseadragon_areas, "src")
NULL

#' @title Crop annotations to a bounding box
#' @description Crop annotations to a bounding box
#' @param data an object as returned by \code{\link{read_annotorious}}
#' @param bbox a vector with elements x, y, xmax, ymax
#' @export
#' @return \code{data} where column \code{polygon} and the rectangle information in \code{x, y, width, height} is limited to the provided bounding box
#' @examples
#' \dontshow{
#' if(require(opencv))
#' \{
#' }
#' library(opencv)
#' data(openseadragon_areas)
#' \dontshow{
#'   url <- system.file(package = "recogito", "examples",
#'                      "Cat_and_dog_standoff_(3926784260).jpg")
#'   attr(openseadragon_areas, "src") <- url
#' }
#' url  <- attr(openseadragon_areas, "src")
#' img  <- ocv_read(url)
#' bbox <- ocv_info(img)
#' bbox <- c(xmin = 0, ymin = 0, xmax = bbox$width - 1, ymax = bbox$height - 1)
#' x    <- ocv_crop_annotorious(data = openseadragon_areas)
#' x    <- ocv_crop_annotorious(data = openseadragon_areas, bbox = bbox)
#'
#' img
#' area <- x[2, ]
#' ocv_polygon(img, pts = area$polygon[[1]], crop = TRUE)
#' area <- x[1, ]
#' ocv_rectangle(img, x = area$x, y = area$y, width = area$width, height = area$height)
#' area <- x[3, ]
#' ocv_rectangle(img, x = area$x, y = area$y, width = area$width, height = area$height)
#' \dontshow{
#' \}
#' }
ocv_crop_annotorious <- function(data, bbox){
  if(missing(bbox)){
    url <- attr(data, "src")
    if(is.null(url)){
      stop("Please provide a bbox")
    }
    if(requireNamespace("magick")){
      bbox <- magick::image_info(magick::image_read(url))
      bbox <- c(xmin = 0, ymin = 0, xmax = bbox$width - 1, ymax = bbox$height - 1)
    }else{
      stop("Install packages magick to read the image or provide a bbox")
    }
  }
  ##
  ## CROP POLYGONS
  ##
  idx  <- which(data$type %in% "POLYGON")
  if(length(idx) > 0){
    if(!requireNamespace("sf")){
      stop("Install packages sf to limit polygons to the bounding box")
    }
    # make polygon closed
    area <- lapply(data$polygon, FUN = function(x) rbind(x, head(x, n = 1)))
    # crop the polygon to the bounding box using sf
    data$polygon[idx] <- lapply(area[idx], FUN = function(x){
      x <- as.matrix(x)
      area <- sf::st_polygon(list(x))
      area <- sf::st_sfc(area, crs = sf::NA_crs_)
      area <- sf::st_crop(area, bbox)
      if(length(area) > 0){
        pts <- as.matrix(area[[1]])
        colnames(pts) <- c("x", "y")
        pts <- as.data.frame(pts)
      }else{
        pts <- data.frame(x = numeric(), y = numeric())
      }
      pts
    })
  }

  ##
  ## CROP RECTANGLES
  ##
  toomuch     <- ifelse(data$x < 0, abs(data$x), 0)
  data$x      <- data$x + toomuch
  data$width  <- data$width - toomuch
  toomuch     <- pmax(0, (data$x + data$width) - bbox[["xmax"]])
  data$width  <- data$width - toomuch
  toomuch     <- ifelse(data$y < 0, abs(data$y), 0)
  data$y      <- data$y + toomuch
  data$height <- data$height - toomuch
  toomuch     <- pmax(0, (data$y + data$height) - bbox[["ymax"]])
  data$height <- data$height - toomuch
  data$x      <- as.numeric(data$x)
  data$y      <- as.numeric(data$y)
  data$width  <- as.numeric(data$width)
  data$height <- as.numeric(data$height)

  data
}


#' @title Extract the areas of interests of an image
#' @description Extract the areas of interests of an image
#' @param data an object as returned by \code{\link{read_annotorious}}
#' @param image an ocv image object
#' @export
#' @return a list of ocv images with the extracted areas of interest
#' @examples
#' \dontshow{
#' if(require(opencv) && require(magick))
#' \{
#' }
#' library(opencv)
#' library(magick)
#' data(openseadragon_areas)
#' \dontshow{
#'   url <- system.file(package = "recogito", "examples",
#'                      "Cat_and_dog_standoff_(3926784260).jpg")
#'   attr(openseadragon_areas, "src") <- url
#' }
#' url  <- attr(openseadragon_areas, "src")
#' img  <- ocv_read(url)
#'
#' areas <- ocv_read_annotorious(data = openseadragon_areas, image = img)
#' areas[[1]]
#' areas[[2]]
#' img <- lapply(areas, FUN = function(x) image_read(ocv_bitmap(x)))
#' img <- do.call(c, img)
#' img <- image_append(img, stack = FALSE)
#' image_resize(img, "x200")
#' \dontshow{
#' \}
#' }
ocv_read_annotorious <- function(data, image){
  if(!requireNamespace("opencv")){
    stop("Install packages opencv to extract the areas of interest")
  }
  if(missing(image)){
    url <- attr(data, "src")
    if(is.null(url)){
      stop("Please provide a bbox")
    }
    image <- opencv::ocv_read(url)
  }
  stopifnot(inherits(image, "opencv-image"))
  bbox <- opencv::ocv_info(image)
  bbox <- c(xmin = 0, ymin = 0, xmax = bbox$width - 1, ymax = bbox$height - 1)
  data <- ocv_crop_annotorious(data, bbox)
  ## Loop over all annotations, extract polygons or rectangles
  lapply(seq_len(nrow(data)), FUN = function(i){
    type <- data$type[i]
    if(type == "POLYGON"){
      opencv::ocv_polygon(image, pts = data$polygon[[i]], crop = TRUE)
    }else if(type == "RECTANGLE"){
      opencv::ocv_rectangle(image, x = data$x[i], y = data$y[i], width = data$width[i], height = data$height[i])
    }
  })
}
