
#
# Source all files in a folder
# Parameters:
#   path: root
#   pattern: file pattern
#   env: environment
#   chdir: change dir
#
SourceDir <- function (path, pattern = "\\.[rR]$", env = NULL, chdir = TRUE) 
{
    files <- sort(dir(path, pattern, full.names = TRUE))
    lapply(files, source, chdir = chdir)
}
