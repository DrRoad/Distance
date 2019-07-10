# calculate encounter rate variance
# note that as in mrds::dht we assume independence between strata
#  so the vcov matric for ER is (block?) diagonal
# encounter rate variance estimation function
ER_var_f <- function(erdat, innes, er_est, est_density){
  if(est_density){
    # "varflag=0"
    # do the binomial var if A=a
    erdat <- erdat %>%
      mutate(pdot = n/Nc) %>%
      mutate(ER_var = sum(size^2*(1-pdot)/pdot^2) +
                           Nc^2 * group_var/group_mean^2) %>%
      drop(pdot)
  }else{

    # sort the data if we use O2/O3 estimators
    if(er_est %in% c("O2", "O3")){
      warning(paste("Using the", er_est, "encounter rate variance estimator, assuming that sorting on Sample.Label is meaningful"))
      if(!is.numeric(erdat$Sample.Label)){
        warning("Additionally, Sample.Label is not numeric, this may cause additional issues")
      }
      erdat <- erdat %>%
        mutate(.originalorder = 1:nrow(erdat)) %>%
        arrange(Sample.Label)
    }

    if(innes){
      # this is the "varflag=2"
      erdat <- erdat %>%
        mutate(ER_var = varn(Effort, transect_Nc, type=er_est)) %>%
        # put ER var on the Nhat scale
        mutate(ER_var_Nhat = (Area/sum(Covered_area))^2 *
                             (Nc*sum(Effort))^2 *
                               ER_var/sum(transect_n)^2) %>%
        # if any strata only had one transect:
        mutate(ER_var_Nhat = ifelse(length(unique(Sample.Label))>1,
                                     ER_var_Nhat,
                                     transect_Nc^2/transect_Nc)) %>%
        mutate(ER_var_Nhat = ifelse(length(unique(Sample.Label))>1,
                                    ER_var_Nhat,
                                    Nc^2* (1/Nc +
                                           group_var/group_mean^2)))
    }else{
      # this is the "varflag=1"
      erdat <- erdat %>%
        mutate(ER_var = varn(Effort, transect_n, type=er_est)) %>%
        # put ER var on the Nhat scale
        mutate(ER_var_Nhat = ((Area/sum(Covered_area))*Nc*sum(Effort))^2 *
                                ER_var/
                                  sum(transect_n)^2 +
                               Nc^2 * group_var/group_mean^2) %>%
        mutate(ER_var_Nhat = ifelse(length(unique(Sample.Label))>1,
                                    ER_var_Nhat,
                                    Nc^2* (1/transect_n +
                                           group_var/group_mean^2)))

    }
  }

  # let the Nhat estimate be 0 if the ER_var was 0
  erdat <- erdat %>% mutate(ER_var_Nhat = ifelse(is.na(ER_var_Nhat) |
                                             is.nan(ER_var_Nhat),
                                             0, ER_var_Nhat))
  if(er_est %in% c("O2", "O3")){
    erdat <- erdat %>%
      arrange(.originalorder)
    erdat$.originalorder <- NULL
  }

  return(erdat)
}