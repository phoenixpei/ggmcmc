#' Separation plot for models with binary response variables
#'
#' @param D Data frame whith the simulations. Notice that only the fitted / expected posterior outcomes are needed, and so either the previous call to ggs() should have limited the family of parameters to only pass the fitted / expected values. See the example below.
#' @param outcome vector (or matrix or array) containing the observed outcome variable. Currently only a vector is supported.
#' @param fully_bayesian logical, FALSE by default. Currently not implemented
#' @param minimalist logical, FALSE by default. It returns a minimalistic version of the figure with the bare minimum elements, suitable for being used inline as suggested by Greenhill, Ward and Sacks citing Tufte.
#'
#' @return A \code{ggplot} object
#' @references Greenhill, Ward and Sacks (2011): The separation plot: a new visual method for evaluating the fit of binary models. American Journal of Political Science, vol 55, number 4, pg 991-1002.
#' @export
#' @examples
#' data(binary)
#' ggs_separation(ggs(s.binary, family="mu"), outcome=y.binary)

ggs_separation <- function(D, outcome, fully_bayesian=FALSE, minimalist=FALSE) {
  if (fully_bayesian) {
    stop("The fully Bayesian version has not been implemented yet.")
  }
  # Calculate the prediction bands
  if (fully_bayesian) {
  } else {
    q <- data.frame(
      qs=c("low", "median", "high"),
      q=c(0.025, 0.5, 0.975))
    S <- D %>%
      group_by(Parameter) %>%
      do(data.frame(qs=q$qs, q=quantile(.$value, prob=q$q))) %>%
      ungroup() %>%
      spread(qs, q)
  }
  # Sort the observations by predicted value
  S <- inner_join(S, data_frame(Observed=outcome, Parameter=unique(D$Parameter)), by="Parameter") %>%
    dplyr::arrange(median) %>%
    dplyr::mutate(id=1:dim(S)[1])
  # Calculate expected number of events
  if (fully_bayesian) {
  } else {
    N <- length(outcome)
    perc.obs.events <- length(which(outcome==1)) / N            # percent observed events
    ene <- length(which(S$median > perc.obs.events))
  }
  # Plot
  f <- ggplot(S, aes(x=id, y=median)) +
    geom_vline(xintercept=which(S$Observed==1), colour = "red", alpha=0.5, size=0.4)
  f <- f + geom_line() + geom_ribbon(aes(y=median, ymin =low, ymax=high), alpha = 0.25)
  f <- f + xlab("") + scale_x_discrete(breaks=NULL)
  f <- f + theme(legend.position = "none", axis.text.x=element_blank())
  f <- f + geom_point(data=data.frame(ene=ene, y=0), aes(x=ene, y=y), size=3, shape=17)
  if (minimalist) {
    # Plot a minimalist version of the figure to be used inline as suggested by
    # the authors citing Tufte.
    f <- f + scale_y_discrete(breaks=NULL) + theme(axis.text.y=element_blank()) + ylab("")
  } else {
    # Add more elements to the figure
    f <- f + ylab("Predicted")
  }
  return(f)
}
