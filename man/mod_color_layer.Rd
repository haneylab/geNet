% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_layers.R
\name{mod_color_layer}
\alias{mod_color_layer}
\title{mod_color_layer}
\usage{
mod_color_layer(data, data_new_colors, no_matching_col = "old")
}
\arguments{
\item{data}{List of two ffdf objects (format generated by the geNet() function )}

\item{data_new_colors}{dataframe that reports the new colors for each node}

\item{no_matching_col}{default color in case of no matching (i.e. gene IDs of the network not reported in data_new_colors)
\itemize{
\item old: the color of no matching nodes is the old color.
\item white: the color of no matching nodes is white ("white" is a reserved color)
}

Default to "white".}
}
\value{
data:  data object modified with the new color layer
}
\description{
function to modify the color layer (colors of the node)
}
\examples{
\dontrun{mod_color_layer(data,data_new_colors,no_matching_col="white")}
}
