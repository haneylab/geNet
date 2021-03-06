% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_visnetwork.R
\name{plot_visnetwork}
\alias{plot_visnetwork}
\title{plot_visnetwork}
\usage{
plot_visnetwork(
  data,
  show_label = F,
  show_legend = T,
  seed = 123,
  name_net = "None",
  show_negative = F,
  contract_net = T,
  size_opt = "fixed"
)
}
\arguments{
\item{data}{list of two ffdf objects generated by the geNet algorithm. Mandatory argument.}

\item{show_label}{show the labels of the nodes?}

\item{show_legend}{show the legend of groups?}

\item{seed}{set the seed of the current instance}

\item{name_net}{name of the network}

\item{show_negative}{show negative edges?}

\item{contract_net}{Should the network be contracted? Default to True}

\item{size_opt}{\itemize{
\item fixed: the size of the node is equal to 8 (size layer values ignored)
\item size_opt: the size of the node  is proportional to the size layer values
}

Default to "fixed". Note: if the there are too many nodes the size of the node is reduced regardless the option specified by the user.}
}
\value{
data:  data object modified with the new size layer
}
\description{
function to plot the visnetwork object based on the data input
}
\examples{
\dontrun{ 
plot_visnetwork(data,show_label=F,
show_legend=T,seed=123,name_net="None",
show_negative=F,contract_net=T,
size_opt="fixed")
}
}
