% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_granges_overlap.R
\name{plot_granges_overlap}
\alias{plot_granges_overlap}
\title{plot overlaps between two granges objects}
\usage{
plot_granges_overlap(
  a_gr,
  b_gr,
  region_gr,
  minOverlap = 0,
  olap_direction = "a"
)
}
\arguments{
\item{a_gr}{Granges object}

\item{b_gr}{Granges object to compare with a_gr}

\item{region_gr}{Granges of length 1 specifying the region that should be plotted}

\item{minOverlap}{minimum required overlap of the region width in a_gr, value between 0-1 (0=minimum 1bp overlap)}

\item{olap_direction}{regions in a_gr are highlighted if there is a minOverlap in the specified direction. Currently, regions in b_gr are not highlighted.}
}
\description{
plot overlaps between two granges objects
}
\examples{
hic_gr <- GRanges(Rle(c("chr1", "chr1", "chrX")),
                  IRanges(start = c(3, 22, 1), end=c(5, 25, 10)),
                  name= paste0('hic_', 1:3))
names(hic_gr) = hic_gr$name
atac_gr <- GRanges(Rle("chr1", 5),
                   IRanges(start = c(4,5,10,20,25), end=c(30,8,22,24,27)),
                   name = paste0('atac_', 1:5))
names(atac_gr) = atac_gr$name

#visualize the result (only looking at region on chromosome 1)
plot_granges_overlap(a_gr = atac_gr,
              b_gr = hic_gr,
              region_gr = Signac::StringToGRanges('chr1-1-100'),
              minOverlap = 0.2,
              olap_direction = 'a')
plot_granges_overlap(a_gr = atac_gr,
              b_gr = hic_gr,
              region_gr = Signac::StringToGRanges('chr1-1-100'),
              minOverlap = 0.4,
              olap_direction = 'b')
plot_granges_overlap(a_gr = unname(atac_gr),
              b_gr = unname(hic_gr),
              region_gr = Signac::StringToGRanges('chr1-1-100'),
              minOverlap = 0.4,
              olap_direction = 'both')
}
