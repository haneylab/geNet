###############################################################################################
############################# functions to format correctly the scores df  ####################
###############################################################################################

#' function to format the final df of scores
#'
#' function to format the final df of scores. The adjustment and filtering steps are executed. 
#' It is automatically called by the geNet() function
#' @param final_df_phi_score the dataframe of scores generated by the generate_final_df() function. Mandatory argument
#' @param sel_weight select the type of weights of the edges. Possible values: 
#' logpvalue: choose the negative log-pvalues as weights of the edges
#' coeff: choose the correlation coefficients as weights of the edges
#' Default to "coeff"
#' @param pval_thr_pos threhold p-value positive edges. Default to 0.01.
#' @param pval_thr_neg threshold p-value negative edges. Default to 0.1.
#' @return Object of class "ffdf", containing the connections between the nodes. 
#' The connections have been filtered and correctly formatted to be converted in an igraph object
#' @export
#' @examples 
#' \dontrun{final_score(final_df_phi_score,sel_weight="coeff")}
#' @import ff ffbase
#' @importFrom stats p.adjust
#' @importFrom stats sd
final_score<-function(final_df_phi_score,
                      sel_weight="coeff",pval_thr_pos=0.01,pval_thr_neg=0.1
                      ){
  # we adjust the p-values
  print("---------Benjamini Hockberg adjusting p-values ------")
  final_df_phi_score$adjusted_pvalue<-ff(p.adjust(final_df_phi_score$pvalue[],method = "BH"),vmode = "double")
  # negative logarithm
  print("---------negative logarithm pvalue ------")
  final_df_phi_score$logpvalue<-ff((-log(final_df_phi_score$adjusted_pvalue[])),vmode = "double") # natural logarithm
  #------- we select the most significant edges for positive and negative edges
  print("------- filter edges -------")
  x<-final_df_phi_score$coefficient
  inds<-ffwhich(x,x>0)
  final_df_phi_score_pos<-final_df_phi_score[inds,]
  inds<-ffwhich(x,x<0)
  final_df_phi_score_neg<-final_df_phi_score[inds,]
  # filter pos edges
  print("filter positive edges")
  x<-final_df_phi_score_pos$adjusted_pvalue
  inds<-ffwhich(x,x<=pval_thr_pos)
  final_df_phi_score_pos<-final_df_phi_score_pos[inds,]
  x<-final_df_phi_score_pos$coefficient
  coeff_thr<-mean(x[])+3*sd(x[])
  if(coeff_thr>=1){
    coeff_thr<-mean(x[])
  }
  print(paste0("pval_pos_thr:",pval_thr_pos))
  print(paste0("coeff_pos_thr:",coeff_thr))
  inds<-ffwhich(x,x>=coeff_thr)
  final_df_phi_score_pos<-final_df_phi_score_pos[inds,]
  # filter neg edges
  print("filter negative edges")
  # Note: the negative edges don't contribute to the generation of the clusters or the topology of the network.
  x<-final_df_phi_score_neg$adjusted_pvalue
  inds<-ffwhich(x,x<=pval_thr_neg)
  final_df_phi_score_neg<-final_df_phi_score_neg[inds,]
  x<-abs(final_df_phi_score_neg$coefficient)
  coeff_thr<-0.02
  print(paste0("pval_neg_thr:",pval_thr_neg))
  print(paste0("coeff_neg_thr:",coeff_thr))
  inds<-ffwhich(x,x>=coeff_thr)
  final_df_phi_score_neg<-final_df_phi_score_neg[inds,]
  # combine neg and pos
  final_df_phi_score<-ffdfappend(final_df_phi_score_pos,final_df_phi_score_neg)
  # ----- round values
  print("--------- round values ------")
  # I don't round the pvalues and adjusted pvalues
  final_df_phi_score$logpvalue<-ff(round(final_df_phi_score$logpvalue[],3),vmode = "double")
  final_df_phi_score$coefficient<-ff(round(final_df_phi_score$coefficient[],3),vmode="double")
  # add the weight of the edges
  if(sel_weight=="logpvalue"){
    final_df_phi_score$weight<-ff(final_df_phi_score$logpvalue,vmode = "double")
  }else if(sel_weight=="coeff"){
    final_df_phi_score$weight<-ff(final_df_phi_score$coefficient,vmode = "double")
  }
  # ----- add width column proportional to weight values -----
  print("-------generating width edges-----")
  if(sel_weight=="coeff"){
    final_df_phi_score$width<-ff(round(abs(final_df_phi_score$coefficient)/max(abs(final_df_phi_score$coefficient)),3)) # make the width prop to coefficients
  }else if(sel_weight=="logpvalue"){
    final_df_phi_score$width<-ff(round(final_df_phi_score$logpvalue/max(final_df_phi_score$logpvalue),3)) # make the width prop to logpvalue
  }
  # format the names correctly
  colnames(final_df_phi_score)<-c("from","to","pvalue","coefficient","color","adjusted_pvalue","logpvalue","weight","width")
  # set weights of negative edge to 0
  x<-final_df_phi_score$coefficient
  idx <- ffwhich(x, x < 0.0)
  if(length(idx)!=0){
    final_df_phi_score$weight<- ffindexset(x=final_df_phi_score$weight,index=idx, value=ff(0.0, length=length(idx), vmode = "double"))
  }
  return(final_df_phi_score)
}
