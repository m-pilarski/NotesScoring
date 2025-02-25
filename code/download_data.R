download_dataset <- function(.dataset, .date, .chunk, .data_dir){
  
  # .dataset <<- .dataset
  # .date <<- .date
  # .chunk <<- .chunk
  # .data_dir <<- .data_dir
  
  stopifnot(
    .dataset %in% c("notes", "ratings", "noteStatusHistory", "userEnrollment"),
    lubridate::is.POSIXct(.date) | lubridate::is.Date(.date),
    is.numeric(.chunk) & .chunk < 100000
  )
  
  .date_path <- strftime(.date, "%Y/%m/%d")
  
  .data_path_rel <- 
    .dataset |> 
    dplyr::case_match(
      "notes" ~ "notes/notes",
      "ratings" ~ "noteRatings/ratings",
      "noteStatusHistory" ~ "noteStatusHistory/noteStatusHistory",
      "userEnrollment" ~ "userEnrollment/userEnrollment"
    ) |> 
    paste0("-", sprintf("%05d", .chunk), ".tsv")

  .resp_full <- 
    httr2::request("https://ton.twimg.com/birdwatch-public-data") |> 
    httr2::req_url_path_append(.date_path, .data_path_rel) |>
    httr2::req_error(is_error = \(...){FALSE}) |>
    httr2::req_perform()
  
  message(.resp_full$url)
  
  .resp_status <- httr2::resp_status(.resp_full)
  
  if(.resp_status == 200){
    
    .data_path_local <- fs::path(.data_dir, .data_path_rel)
    
    fs::dir_create(fs::path_dir(.data_path_local))
    
    .resp_full |> 
      httr2::resp_body_raw() |> 
      readr::write_file(file=.data_path_local)
    
  }
  
  return(.resp_status)
  
}

download_database <- function(.date=Sys.time(), .data_dir=.data_dir){

  .dataset_vec <- c("notes", "ratings", "noteStatusHistory", "userEnrollment")
  .first_all <- TRUE
  
  for(.dataset in .dataset_vec){
    
    .chunk <- 0
    repeat{
      .download_status <- download_dataset(
        .dataset=.dataset, .date=.date, .chunk=.chunk, .data_dir=.data_dir
      )
      if(.first_all && .download_status == 404){
        .date <- .date - lubridate::days(1)
        message("reduced .date by one day")
        next
      }else if(.download_status != 200){
        if(.chunk == 0){
          message("failed to download ", .dataset, " (", .download_status, ")")
          stop()
        }else{
          break
        }
      }
      .first_all <- FALSE
      .chunk <- .chunk + 1
    }

  }

  print(fs::dir_tree(.data_dir))

}

download_database(
  .date=lubridate::ymd("2024-06-16"), 
  .data_dir=here::here("data")
)
