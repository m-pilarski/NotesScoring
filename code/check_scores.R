
read_status_history <- function(.path){
  .status_history_data <- 
    readr::read_tsv(
      file=.path, col_types=readr::cols_only(noteId="c", currentStatus="c")
    ) |> 
    dplyr::mutate(
      currentStatus = 
        currentStatus |> 
        (\(.x){.x[is.na(.x)] <- "- missing -"; .x})() |> 
        factor(
          levels=c(
            "NEEDS_MORE_RATINGS", 
            "CURRENTLY_RATED_HELPFUL",
            "CURRENTLY_RATED_NOT_HELPFUL", 
            "- missing -"
          )
        )
    )
  
  return(.status_history_data)

}

compare_results <- function(.path_own){
  .status_compare <- dplyr::full_join(
    read_status_history(
      here::here("data", "noteStatusHistory", "noteStatusHistory-00000.tsv")
    ),
    read_status_history(.path_own), by=dplyr::join_by(noteId), 
    suffix=c("_ref", "_own")
  )
  
  .status_compare |> 
    dplyr::count(currentStatus_ref == currentStatus_own, name="count") |> 
    dplyr::mutate(prop = count / sum(count)) |> 
    print()

  return(invisible(NULL))

}

compare_results(here::here("data", "results-minute", "note_status_history.tsv"))
compare_results(here::here("data", "results-second", "note_status_history.tsv"))
compare_results(here::here("data", "results-hour", "note_status_history.tsv"))
compare_results(here::here("data", "results-now", "note_status_history.tsv"))

