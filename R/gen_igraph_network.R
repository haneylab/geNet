#############################################################################
####################### generate igraph network object #######################
#############################################################################
#' @title  generate igraph network

#' @description function to generate the igraph network object based on the final scores. 
#' It is called automatically by the geNet() function.
#' @param final_df_score the dataframe of scores generated by the final_score() function. Mandatory argument.
#' @return Object of class "igraph"
#' @import igraph
gen_network_obj<-function(final_df_score){
  igraph_network <- graph_from_data_frame(final_df_score,directed = F)
  return(igraph_network)
}
