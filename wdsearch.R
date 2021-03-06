
#' Search for Wikidata items
#'
#' @param search A string to search for
#' @param lang Language abbreviation (ISO language codes), as string - default is \code{"en"}
#' @param lim Maximal number of results, as integer - default is \code{10}
#' @param print Logical - if \code{TRUE} (default) the search results are printed
#' @return A list of search results and meta information
#' @export
#' @examples
#' \dontrun{
#' wdsearch("zakopane")
#' zapa <- wdsearch(search="zakopane", lang="pl", lim=1, print=FALSE)
#' }
wdsearch <- function(search, lang="en", lim=10, print=TRUE) UseMethod("wdsearch")


#' Search for Wikidata items - default method
#'
#' @import httr
#' @param search A string to search for
#' @param lang Language abbreviation (ISO language codes), as string
#' @param lim Maximal number of results, as integer
#' @param print Logical - if \code{TRUE} the search results are printed
#' @return A list of search results and meta information
wdsearch.default <- function(search, lang, lim, print) {
		
	# prepare request
	search <- paste("search", search, sep="=")
	lang <- paste("language", lang, sep="=")
	limit <- paste("limit", lim, sep="=")
	query <- paste(search, lang, "format=json&type=item", limit, sep="&")
	url <- paste0("http://www.wikidata.org/w/api.php?action=wbsearchentities&", query)
	
	# execute request
	raw <- GET(url, config=add_headers("User-agent"="rwikidata"))
	
	# parse
	result <- httr::content(raw, as="parsed")
	
	if(is.null(result$success)) warning("search failed\n", "code: ", result$error[[1]], " - ", result$error[[2]]) 
	else {
		class(result) <- "wdsearch"
		if(print) print(result)
		invisible(result)
	}
}


#' Print method for wdsearch
#'
#' @param result wdsearch object with search results
print.wdsearch <- function(result) {
	
	cat("\n\tWikidata search\n\n")
	
	# seach info
	cat("Search term:\t\t", result$searchinfo$search, "\n")
	
	# number of results
	num.results <- length(result$search)
	cat("Number of results:\t", num.results, "\n\n")
		
	# results
	if(num.results>0) {
		cat("Results:\n")
		for(i in 1:num.results) {
			label <- result$search[[i]]$label
			id <- result$search[[i]]$id
			if(is.null(result$search[[i]]$description)) desc <- "\n"
			else desc <- paste("-", result$search[[i]]$description, "\n")
			cat(i, "\t", label, paste0("(", id, ")"), desc)
		}
	}
}
