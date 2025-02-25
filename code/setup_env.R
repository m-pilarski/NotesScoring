################################################################################
## INSTALL SETUP DEPENDENCIES ##################################################
################################################################################

if(!"remotes" %in% installed.packages()){install.packages("remotes")}
pak::pkg_install("m-pilarski/helprrr")

stopifnot(fs::path_file(here::here()) == "NotesScoring")

################################################################################
################################################################################
################################################################################

helprrr::setenv_persist(
  # FOR {arrow}
  LIBARROW_BINARY="TRUE",
  LIBARROW_MINIMAL="FALSE",
  ARROW_USE_PKG_CONFIG="FALSE",
  # FOR {V8}
  DOWNLOAD_STATIC_LIBV8="1",
  # ...
  .path_proj=here::here()
)

################################################################################
################################################################################
################################################################################

renv::init(project=here::here())

################################################################################

python_path <- reticulate::install_python(version="3.10:latest")

reticulate::virtualenv_create(
  envname=here::here("venv"), 
  python=python_path, 
  packages="packaging",
  requirements=here::here("communitynotes/requirements.txt")
)

################################################################################
################################################################################
################################################################################

renv::use_python(
  python=reticulate::virtualenv_python(here::here("venv")), 
  project=here::here(), 
  type="virtualenv"
)

helprrr::setenv_persist(
  RETICULATE_PYTHON=reticulate::virtualenv_python(here::here("venv")),
  RENV_PYTHON=reticulate::virtualenv_python(here::here("venv"))
)

renv::snapshot(prompt=FALSE)
