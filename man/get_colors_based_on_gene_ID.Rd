% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_layers_values.R
\name{get_colors_based_on_gene_ID}
\alias{get_colors_based_on_gene_ID}
\title{get_colors_based_on_gene_ID}
\usage{
get_colors_based_on_gene_ID(data, vec_gene_ids = "None", col_nodes = "black")
}
\arguments{
\item{data}{List of two ffdf objects (format generated by the geNet() function )}

\item{vec_gene_ids}{vector of genes IDs to color. Mandatory argument.}

\item{col_nodes}{color of the nodes that match the specified IDs. Default to "black".}
}
\value{
Object of class "dataframe", which reports the new colors for each node of the network
}
\description{
function to get the colors based on the ID of the nodes
}
\examples{
\dontrun{get_colors_based_on_gene_ID(data,vec_gene_ids="None",col_nodes="black")}
}
