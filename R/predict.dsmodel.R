#' Predictions from a fitted detection function
#'
#' Predict detection probabilities (or effective strip widths/effective areas of detection) from a fitted distance sampling model using either the original data (i.e. "fitted" values) or using new data.
#'
#' For line transects, the effective strip half-width (\code{esw=TRUE}) is the integral of the fitted detection function over either 0 to W or the specified \code{int.range}.  The predicted detection probability is the average probability which is simply the integral divided by the distance range. For point transect models, \code{esw=TRUE} calculates the effective area of detection (commonly referred to as "nu", this is the integral of \code{2/width^2 * r * g(r)}.
#'
#' Fitted detection probabilities are stored in the \code{model} object and these are returned unless \code{compute=TRUE} or \code{newdata} is specified. \code{compute=TRUE} is used to estimate numerical derivatives for use in delta method approximations to the variance.
#'
#' Note that the ordering of the returned results when no new data is supplied (the "fitted" values) will not necessarily be the same as the data supplied to \code{\link{ddf}}, the data (and hence results from \code{predict}) will be sorted by object ID (\code{object}).
#'
#' @param object \code{ds} model object.
#' @param newdata new \code{data.frame} for prediction, this must include a column called "\code{distance}".
#' @param compute if \code{TRUE} compute values and don't use the fitted values stored in the model object.
#' @param esw if \code{TRUE}, returns effective strip half-width (or effective area of detection for point transect models) integral from 0 to the truncation distance (\code{width}) of \eqn{p(y)dy}; otherwise it returns the integral from 0 to truncation width of \eqn{p(y)\pi(y)} where \eqn{\pi(y)=1/w} for lines and \eqn{\pi(y)=2r/w^2} for points.
#' @param se.fit should standard errors on the predicted probabilities of detection (or ESW if \code{esw=TRUE}) estimated? Stored in the \code{se.fit} element
#' @param \dots for S3 consistency
#' @return a list with a single element: \code{fitted}, a vector of average detection probabilities or esw values for each observation in the original data or\code{newdata}. If \code{se.fit=TRUE} there is an additional element \code{$se.fit}, which contains the standard errors of the probabilities of detection or ESW.
#'
#' @author David L Miller
#' @export
#' @importFrom stats predict
predict.dsmodel <- function(object, newdata=NULL, compute=FALSE,
                            esw=FALSE, se.fit=FALSE, ...){
  predict(object$ddf, newdata, compute, esw, se.fit, int.range=NULL, ...)
}
