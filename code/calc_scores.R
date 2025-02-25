run_cmd <- function(...){
  processx::run(
    command="bash", 
    args=c("-c", glue::glue(..., .sep="\n")),
    wd=here::here(),
    echo=TRUE,
    spinner=TRUE
  )
} 

################################################################################
################################################################################
################################################################################

epoch_millis <- 
  readr::read_tsv(
    file=fs::path_real(
      here::here("data", "noteStatusHistory", "noteStatusHistory-00000.tsv")
    ),
    col_types=readr::cols_only(timestampMillisOfCurrentStatus="c"),
    n_max=1
  ) |> 
  dplyr::pull(timestampMillisOfCurrentStatus) |> 
  bit64::as.integer64() |> 
  (`+`)(1 * 1 * 60e3) |> # add 1 minute
  as.character()

out_dir <- fs::path_real(fs::dir_create(here::here("data", "results-second")))

enrollment_file_path <- fs::path_real(
  here::here("data", "userEnrollment", "userEnrollment-00000.tsv")
)
notes_file_path <- fs::path_real(
  here::here("data", "notes", "notes-00000.tsv")
)
ratings_dir_path <- fs::path_real(
  here::here("data", "noteRatings")
)
status_file_path <- fs::path_real(
  here::here("data", "noteStatusHistory", "noteStatusHistory-00000.tsv")
)

################################################################################
################################################################################
################################################################################

run_cmd(
  "source venv/bin/activate",
  #################################
  "export CUDA_VISIBLE_DEVICES=''",
  #################################
  "python communitynotes/sourcecode/main.py \\",
  "  --enrollment data/userEnrollment/userEnrollment-00000.tsv \\",
  "  --notes {notes_file_path} \\",
  "  --ratings {ratings_dir_path} \\",
  "  --status {status_file_path} \\",
  "  --outdir {out_dir} \\",
  "  --epoch-millis {epoch_millis} \\",
  "  --nocheck-flips"
)