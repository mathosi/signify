#' generate random GRanges
#'
#' create random granges objects based on supplied chromosome lenghts and desired region widths.
#' For random granges with matched number and width of regions use ChIPseeker::shuffle().
#'
#' @name random_granges
#' @param n number of regions to create
#' @param chr_annot txdb object containing the sizes of chromosomes. Alternatively, named numeric vector of chromosome lengths
#' @param width sizes of the regions, vector of integers from which is sampled
#' @export
#' @examples
#' library(TxDb.Hsapiens.UCSC.hg19.knownGene)
#' txdb = TxDb.Hsapiens.UCSC.hg19.knownGene
#' random_granges(n = 30, chr_annot = txdb, width = pmax(1, as.integer(rnorm(30, mean = 50, sd = 30))))
#' #get 30 width-1 regions from chr1-1-15000
#' random_granges(n = 30, chr_annot = structure(15000, names='chr1'))

random_granges <- function(n, chr_annot, width=1, chroms=NULL){
  if('numeric' %in% class(chr_annot)){
    if(is.null(names(chr_annot))){
      stop('If passing a vector of chromosome lenghts, each entry must have names')
    }
    chr_sizes = chr_annot
  }else{
    chr_sizes <- seqlengths(chr_annot)
    chr_sizes = chr_sizes[grepl('^chr[0-9XY]+$', names(chr_sizes))]
  }
  if(!is.null(chroms[1])){
    stopifnot(all(chroms %in% names(chr_sizes)))
    chr_sizes = chr_sizes[names(chr_sizes) %in% chroms]
  }
  #chr_gr = keepStandardChromosomes(GRanges(seqnames=names(chr_sizes), ranges = IRanges(start = 1, width = 1)), pruning.mode = 'coarse')
  random_chr <- sample(x=names(chr_sizes), size=n, prob=chr_sizes, replace=T)
  random_pos <- sapply(random_chr, function(chrTmp){sample(chr_sizes[names(chr_sizes)==chrTmp],1)})
  random_widhts = sample(width, n, replace = T)
  gr <- GRanges(seqnames = random_chr, ranges = IRanges(start = random_pos, width = random_widhts))
  return(gr)
}
