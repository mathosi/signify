#' signature enrichment/depletetion p-value
#'
#' Given a peak signature, (binary) scATAC peakmatrix and a cell-to-cluster annotation, calculate an enrichment or
#' depletion p-value for each cluster using bias-matched background peak sets
#'
#' @name get_signature_pvalue
#' @param pmat binary peak matrix (rows = regions in the format 'chr1-10-100', columns = cells)
#' @param group_vector vector of group annotation for the cells in the peak matrix (e.g. clustering result)
#' @param signature_peaks_gr GRanges object of the peak signature
#' @param genome genome for selection of background sequences, e.g. BSgenome.Mmusculus.UCSC.mm10
#' @param n_background_sets number of background sets to compare against, higher values give more precise estimates
#' @keywords ggplot,plot_grobs,plot_grid
#' @export
#' @examples


get_signature_pvalue  = function(pmat, group_vector, signature_peaks_gr, genome, n_background_sets = 300){
  stopifnot(identical(ncol(pmat), length(group_vector)))
  se = SummarizedExperiment(assays = SimpleList(counts = pmat), 
                            rowRanges = StringToGRanges(rownames(pmat)),
                            colData = DataFrame(group = as.character(group_vector)))
  #library(BSgenome.Mmusculus.UCSC.mm10)
  se <- addGCBias(se, genome = genome)
  #draw background peaks from the same peakset for each peak
  message('Getting ', n_background_sets, ' sets of background peaks')
  bgpeaks <- getBackgroundPeaks(se,
                                bias = rowData(se)$bias,
                                niterations = n_background_sets, 
                                w = 0.1, bs = 50)
  message('Calculating peak matrix overlap with signature')
  signature_olap = a_regions_that_have_minOverlap_with_b_regions(rowRanges(se), signature_peaks_gr, return_logical = T)
  message(sprintf('%i/%i peaks are overlapping with the signature.',sum(signature_olap), nrow(pmat)))
  bgpeaks = bgpeaks[signature_olap, ]
  
  message('Calculating signature peak set scores per group')
  mean_cluster_acc = jj_summarize_sparse_mat(pmat[signature_olap, ], 
                                             summarize_by_vec = se$group,
                                             method = 'mean')
  mean_cluster_acc = scale(t(mean_cluster_acc))
  mean_cluster_acc = rowMeans(mean_cluster_acc)
  print(sort(mean_cluster_acc, decreasing=T))
  
  message('Calculating background peak set scores per group')
  bg_mat = jj_initialize_df(ncol = length(unique(se$group)), 
                            nrow = n_background_sets, 
                            init = NA, 
                            col.names = names(mean_cluster_acc),
                            return_matrix = T)
  
  for(i in 1:n_background_sets){
    if(i %% 25 == 0) message(i,'/',n_background_sets)
    peaks_use = bgpeaks[, i]
    mean_bg_cluster_acc = jj_summarize_sparse_mat(pmat[peaks_use, ], 
                                                  summarize_by_vec = se$group,
                                                  method = 'mean')
    mean_bg_cluster_acc = scale(t(mean_bg_cluster_acc))
    bg_mat[i, ] = rowMeans(mean_bg_cluster_acc)
  }
  
  avfc = sapply(seq_along(unique(group_vector)), function(x) mean(mean_cluster_acc[x] / bg_mat[, x], na.rm = T))
  names(avfc) = names(mean_cluster_acc)
  avfc = sort(avfc, decreasing = T)
  
  message('Computing p values')
  #enrichment
  pvals_bigger = sapply(seq_along(unique(group_vector)), function(x) sum(bg_mat[, x] > mean_cluster_acc[x]) / n_background_sets)
  names(pvals_bigger) = names(mean_cluster_acc)
  padjusted_bigger = sort(p.adjust(pvals_bigger, method = 'BH'))
  
  #depletion
  pvals_smaller = sapply(seq_along(unique(group_vector)), function(x) sum(bg_mat[, x] < mean_cluster_acc[x]) / n_background_sets)
  names(pvals_smaller) = names(mean_cluster_acc)
  
  padjusted = p.adjust(c(pvals_bigger, pvals_smaller), method = 'BH')
  padj_enriched = sort(padjusted[1:length(pvals_bigger)])
  padj_depleted = sort(padjusted[(length(pvals_bigger)+1):length(padjusted)])
  
  result_list = list(
    #p_enriched = pvals_bigger,
    #p_depleted = pvals_smaller,
    padj_enriched = padj_enriched,
    padj_depleted = padj_depleted,
    avfc = avfc
  )
  return(result_list)
}