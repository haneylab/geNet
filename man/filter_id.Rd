% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/visualization_functions.R
\name{filter_id}
\alias{filter_id}
\title{function to filter the genes ID}
\usage{
filter_id(data, selected_id)
}
\arguments{
\item{data}{List of two ffdf objects (format generated by the geNet() function ). Mandatory argument}

\item{selected_id}{select the ids to filter data. Optional argument.}
}
\value{
data: data object filtered
}
\description{
function to filter the genes ID from data. It is called automatically by the visualize_network() function
}
