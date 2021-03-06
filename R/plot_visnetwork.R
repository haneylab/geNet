#######################################################################################
################################# plot the final visnetwork ############################
#######################################################################################

#' plot_visnetwork
#' 
#' function to plot the visnetwork object based on the data input
#' @param data list of two ffdf objects generated by the geNet algorithm. Mandatory argument.
#' @param show_label show the labels of the nodes?
#' @param show_legend show the legend of groups?
#' @param seed set the seed of the current instance
#' @param name_net name of the network
#' @param show_negative show negative edges?
#' @param contract_net Should the network be contracted? Default to True
#' @param size_opt 
#' * fixed: the size of the node is equal to 8 (size layer values ignored)
#' * size_opt: the size of the node  is proportional to the size layer values
#' 
#' Default to "fixed". Note: if the there are too many nodes the size of the node is reduced regardless the option specified by the user.
#' @return data:  data object modified with the new size layer
#' @export
#' @examples
#' \dontrun{ 
#' plot_visnetwork(data,show_label=F,
#' show_legend=T,seed=123,name_net="None",
#' show_negative=F,contract_net=T,
#' size_opt="fixed")
#' }
#' @import ff igraph visNetwork
plot_visnetwork<-function(data,show_label=F,
                          show_legend=T,seed=123,name_net="None",
                          show_negative=F,contract_net=T,
                          size_opt="fixed"){
  #---------- check input data ---------------
  check_columns<-colnames(data$edges) %in% c("from","to","color",
                                             "pvalue","coefficient","adjusted_pvalue",
                                             "logpvalue","weight","width","title",
                                             "physics","hidden")
  if(any(check_columns==F)){
    stop("input to plot_visnetwork not complete")
  }
  # ----- should I contract the network? -----
  if(contract_net==T){
    warning("contracting vertices...")
    list_output<-contract_network(data,seed=seed,show_label=show_label,
                                  show_legend = show_legend)
    return(list_output)
  }
  print("---------plotting network -----")
  # ------------ check size nodes -----------
  if(size_opt=="prop"){
    # we make the size proportional to highest size node
    data$nodes$size<-ff(data$nodes$size[]/max(data$nodes$size[]))
    data$nodes$size<-data$nodes$size*10
  }
  if(size_opt=="fixed"){
    # we set the size of the nodes to a constant value
    x<-rep(8,nrow(data$nodes))
    data$nodes$size<-ff(x)
  }

  
  # ---------- labels nodes visible?------
  if(show_label==F){
    x<-rep(NA,nrow(data$nodes))
    data$nodes$label<-ff(x)
  }
  #------------------------ hide positive edges and activate negative edges --------------
  if(show_negative==T){
    inds<-which(data$edges$coefficient[]<0)
    data$edges$hidden[inds]<-F
    data$edges$hidden[-inds]<-T
  }else if(show_negative==F){
    inds<-which(data$edges$coefficient[]>0)
    data$edges$hidden[inds]<-F
    data$edges$hidden[-inds]<-T
  }
  #----------- check number of nodes -------------
  if(nrow(data$nodes)>1000){
    stop("Extreme high number of nodes, impossible to plot")

  }else if(nrow(data$nodes)>500){
    warning("too many nodes,the size of the nodes is reduced to 4")
    x<-rep(4,nrow(data$nodes))
    data$nodes$size<-ff(x)
  }
  #--------------- generate the instance of the visnetwork ------------------
  df_nodes_legend<-get_legend_df(data)
  visnet<-visNetwork(nodes = as.data.frame(data$nodes[]), edges = as.data.frame(data$edges[]),main = name_net) %>%
    visIgraphLayout(randomSeed = seed,physics = T,layout = "layout_nicely") %>%
    visLegend(enabled = show_legend,useGroups=F,
              addNodes = df_nodes_legend,
              width = 0.5) %>%
    visOptions(highlightNearest = list(enabled =TRUE, degree = 1),selectedBy=list(variable="group",main="select by community")) %>%
    visInteraction(hideEdgesOnDrag = TRUE) %>%
    visPhysics(stabilization = list(enabled=T,iterations=100,updateInterval=5),timestep = 0.5,minVelocity = 10,maxVelocity = 50) %>%
    visEdges(smooth = FALSE) %>%
    visEvents(select = "function(nodes){
                Shiny.onInputChange('current_node_id', nodes.nodes);
                ;}") %>%
    visEvents(type = "once",stabilizationIterationsDone="function () {this.setOptions( { physics: false } );}")
  return(visnet)
}

#' get_mappings
#' 
#' function to get the correct mapping to contract the network. 
#' It is automatically called by the contract_network() function. 
#' @param igraph_net igraph object. Mandatory argument.
#' @param data list of two ffdf objects generated by the geNet algorithm. Mandatory argument.
#' @return Object of "vector" containing the mapping codes.
#' @import ff 

get_mappings<-function(igraph_net,data){
  all_genes_ids<-V(igraph_net)$name
  mapping_vec<-rep(0,length(all_genes_ids))
  all_groups<-unique(as.character(data$nodes$group[]))
  for(i in 1:length(all_groups)){
    current_group<-all_groups[i]
    out<-as.character(data$nodes$group[]) %in% current_group
    inds<-which(out==T)
    gene_ids_current_group<-as.character(data$nodes$id[])[inds]
    out<-all_genes_ids %in% gene_ids_current_group
    inds<-which(out==T)
    mapping_vec[inds]<-i
  }
  return(mapping_vec)
}
#' get_legend_df
#' 
#' function to get the legend of the groups. It is automatically called by the plot_visnetwork() function. 
#' @param data list of two ffdf objects generated by the geNet algorithm. Mandatory argument.
#' @return Object of class "dataframe", which reports the legend information of the nodes
#' @import ff 
get_legend_df<-function(data){
  label<-unique(as.character(data$nodes$group[]))
  df_nodes_legend<-matrix("a",nrow=length(label),ncol = 2)
  for(l in 1:length(label)){
    current_label<-label[l]
    out<-as.character(data$nodes$group[]) %in% current_label
    inds<-which(out==T)
    color_current_label<-as.character(data$nodes$color[])[inds[1]]
    df_nodes_legend[l,1]<- current_label
    df_nodes_legend[l,2]<- color_current_label
    
  }
  df_nodes_legend<-as.data.frame(df_nodes_legend)
  colnames(df_nodes_legend)<-c("label","color")
  return(df_nodes_legend)
}
#' contract_network
#' 
#' function to contract the visnetwork dataframe. It is automatically called by the plot_visnetwork() function if contract_net=T.
#' @param data visnetwork dataframe generated by the geNet algorithm. Mandatory argument.
#' @param seed set seed of the nodes
#' @param show_label should the labels of the nodes be visible? default to False
#' @param show_legend should the legend be visible? default to True
#' @return list of two objects:
#' * visnet: object of class "visNetwork" generated from the contracted data.
#' * data_contracted: a compressed version of the input data object. It is generated by contracting the nodes of each cluster in one vertex.
#' 
#' This dataset reports only the nodes contained in each cluster and the connections between the clusters
#' @import ff igraph visNetwork
contract_network<-function(data,seed=123,show_label=F,show_legend=T){
  # I consider only the positive edges (they are the ones that determine the topology)
  inds<-which(data$edges$coefficient[]>0)
  data_edges_pos<-data$edges[inds,]
  # I generate the contracted network
  igraph_network<-gen_network_obj(data_edges_pos)
  mapping_vec<-get_mappings(igraph_network,data)
  igraph_network_contracted<-contract.vertices(igraph_network,mapping_vec,vertex.attr.comb=toString)
  igraph_network<-simplify(igraph_network_contracted,remove.multiple = T,
                           remove.loops = T,
                           edge.attr.comb = list(weight="mean",color="first",logpvalue="mean",title=function(x)length(x),"ignore"))
  # with function(x)length(x) I get the number of edges before the contraction
  data_contracted<-toVisNetworkData(igraph_network)
  if(nrow(data_contracted$edges)==0){
    # all clusters are isolated. We need to keep the loops (otherwise nothing is showed)
    igraph_network<-simplify(igraph_network_contracted,remove.multiple = T,
                             remove.loops = F,
                             edge.attr.comb = list(weight="mean",color="first",logpvalue="mean",title=function(x)length(x),"ignore"))
    # with function(x)length(x) I get the number of edges before the contraction
    data_contracted<-toVisNetworkData(igraph_network)
    #  but we hide the loops
    data_contracted$edges$hidden<-TRUE 
  }
  # round the average p-values
  data_contracted$edges$weight<-round(data_contracted$edges$weight,4)
  # add the original group column to the nodes
  group_vec<-rep("a",nrow(data_contracted$nodes))
  for(i in 1:length(data_contracted$nodes$id)){
    current_contracted_id<-data_contracted$nodes$id[i]
    splitted_id<-strsplit(current_contracted_id,",")[[1]]
    splitted_id<-trimws(splitted_id) # remove white  spaces
    out<-as.character(data$nodes$id[]) %in% splitted_id
    inds<-which(out==T)
    group_current_contracted_id<-as.character(data$nodes$group[])[inds]
    group_current_contracted_id<-group_current_contracted_id[1]
    group_vec[i]<-group_current_contracted_id
  }
  data_contracted$nodes$group<-group_vec
  # choose if the labels of the nodes should be visible
  if(show_label==F){
    data_contracted$nodes$label<-NA
  }
  # width of edges proportional to number of original edges that connected the clusters
  width<-as.numeric(data_contracted$edges$title)
  data_contracted$edges$width<-width/max(width)
  data_contracted$edges$width<-data_contracted$edges$width*4
  # the number of original edges, the new weights(average of original weights),
  # and pvalues (average original adjusted pvalues) are the tooltips of the edges
  title_vec<- paste(data_contracted$edges$title,data_contracted$edges$weight, data_contracted$edges$adjusted_pvalue,sep = ",")
  data_contracted$edges$title<-title_vec
  # the groups are the tooltips of the nodes
  data_contracted$nodes$title<-data_contracted$nodes$group
  # we don't show the isolated clusters,but we save the full contracted data
  data_contracted_to_show<-data_contracted
  out<-as.character(data_contracted_to_show$nodes$id[]) %in% c(as.character(data_contracted_to_show$edges$from[]),as.character(data_contracted_to_show$edges$to[]))
  inds<-which(out==T)
  data_contracted_to_show$nodes<-data_contracted_to_show$nodes[inds,]
  # generate contracted visnet
  visnet<-visNetwork(nodes = data_contracted_to_show$nodes, edges = data_contracted_to_show$edges) %>%
    visIgraphLayout(randomSeed = seed,physics = T) %>%
    visLegend(enabled = show_legend,useGroups=T) %>%
    visOptions(highlightNearest = list(enabled =TRUE, degree = 1),selectedBy=list(variable="group",main="select by community")) %>%
    visInteraction(hideEdgesOnDrag = TRUE) %>%
    visPhysics(stabilization = F,timestep = 0.7,minVelocity = 10,maxVelocity = 20) %>%
    visEdges(smooth = FALSE) %>% 
    visEvents(select = "function(nodes){
                Shiny.onInputChange('current_groups_ids', nodes.nodes);
                ;}") %>%
    visEvents(doubleClick = "function(nodes){
      Shiny.onInputChange('current_groups_ids_2', nodes.nodes);
      ;}")
  gc()
  return(list(visnet=visnet,data_contracted=data_contracted))
}
