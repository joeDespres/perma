% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/perma_link.R
\name{perma_create_link}
\alias{perma_create_link}
\title{`perma_create_link`}
\usage{
perma_create_link(
  organization,
  repository,
  sha,
  file,
  line,
  blob = "blob",
  host = "https://github.com"
)
}
\arguments{
\item{organization}{owner or the repository}

\item{repository}{repo name}

\item{sha}{this will usually be the sha of the state rather than the branch}

\item{file}{particular file name}

\item{line}{which line number in the file}

\item{blob}{not sure what this is or does}

\item{host}{hose name (DEFAULT to https://github.com)}
}
\description{
`perma_create_link`
}
