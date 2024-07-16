################################################################################
## INSTALL SETUP DEPENDENCIES ##################################################
################################################################################

if(!"remotes" %in% installed.packages()){install.packages("remotes")}
remotes::install_github("m-pilarski/helprrr")

################################################################################
################################################################################
################################################################################

path_proj <- here::here()

stopifnot(fs::path_file(path_proj) == "NotesScoring", fs::is_dir(path_proj))

################################################################################
################################################################################
################################################################################

path_libs <- fs::path(path_proj, "libs")

path_conda_lib_exe <- try(fs::path(reticulate::conda_binary()))
if(is(path_conda_lib_exe, "try-error")){
  path_conda_lib <- fs::path(path_libs, "proj_miniconda")
  reticulate::install_miniconda(path_conda_lib)
  path_conda_lib_exe <- fs::path(path_conda_lib, "bin/conda")
}else if(fs::file_exists(path_conda_lib_exe)){
  path_conda_lib <- fs::path(path_conda_lib_exe, "../..")
}else{
  stop()
}

path_renv <- fs::path(path_libs, "proj_renv")

path_conda_env <- fs::path(path_libs, "proj_conda_env")
path_conda_env_py <- fs::path(path_conda_env, "bin/python")

path_renv_lock <- fs::path(path_libs, "proj_renv.lock")
path_conda_env_yml <- fs::path(path_libs, "proj_environment.yml")

################################################################################
################################################################################
################################################################################

helprrr::setenv_persist(
  # FOR {renv}
  RENV_PATHS_RENV=path_renv,
  RENV_PATHS_LOCKFILE=path_renv_lock,
  RENV_PATHS_CONDA_EXPORT=path_conda_env_yml,
  RENV_CONFIG_SANDBOX_ENABLED="FALSE",
  # FOR {arrow}
  LIBARROW_BINARY="TRUE",
  LIBARROW_MINIMAL="FALSE",
  ARROW_USE_PKG_CONFIG="FALSE",
  # FOR {V8}
  DOWNLOAD_STATIC_LIBV8="1",
  # ...
  .path_proj=path_proj
)

################################################################################
################################################################################
################################################################################

writeLines(
  text=fs::path_rel(path_libs, path_proj),
  con=fs::path(".renvignore")
)

renv::init(project=path_proj, restart=FALSE, bare=TRUE)

renv::hydrate(project=path_proj, prompt=FALSE)

if(!"reticulate" %in% installed.packages()){install.packages("reticulate")}
if(fs::dir_exists(path_conda_env)){fs::dir_delete(path_conda_env)}
reticulate::conda_create(
  envname=path_conda_env, conda=path_conda_lib_exe, python_version="3.9"
)
reticulate::conda_install(
  envname=path_conda_env, 
  conda=path_conda_lib_exe,
  packages=readr::read_lines(
    here::here("communitynotes/requirements.txt"), skip_empty_rows=TRUE
  ),
  pip=TRUE
)

renv::use_python(
  python=path_conda_env_py, name=path_conda_env, project=path_proj, type="auto"
)

renv::snapshot(project=path_proj, prompt=FALSE)

renv::activate(project=path_proj)
