
#' Get claims of a Wikidata item by API request
#'
#' @param id The Wikidata item id, as string (including the 'Q') or integer value (without the 'Q')
#' @param print Logical - if \code{TRUE} (default) the claims are printed
#' @return A list with basic information about the item
#' @seealso \code{\link{wdgetitem}} for general information about the item, \code{\link{getclaims}} to get claims of a wditem object from \code{\link{wdgetitem}}
#' @export
#' @examples
#' \dontrun{
#' wdgetclaims(144786)
#' zapa.claims <- wdgetclaims(id="q144786", print=FALSE)
#' }
wdgetclaims <- function(id, print=TRUE) UseMethod("wdgetclaims")

#' Get claims of a Wikidata item
#'
#' @param item The Wikidata item object - from \code{wdgetitem()}
#' @param print Logical - if \code{TRUE} (default) the claims are printed
#' @return A data frame listing all claims of the item
#' @seealso \code{\link{wdgetitem}} for general information about the item, \code{\link{wdgetclaims}} to get claims of a wditem object by API request
#' @export
#' @examples
#' \dontrun{
#' zapa.item <- wdgetitem(id="q144786")
#' getclaims(zapa.item)
#' zapa.claims <- getclaims(item=zapa.item, print=FALSE)
#' }
getclaims <- function(item, print=TRUE) UseMethod("getclaims")


#' Get claims of a Wikidata item by API request
#'
#' @import httr
#' @param id The Wikidata item id, as string (including the 'Q') or integer value (without the 'Q')
#' @param print Logical - if \code{TRUE} the claims are printed
#' @return A list with basic information about the item
wdgetclaims.default <- function(id, print=TRUE) {
	
	if(is.numeric(id)) id <- paste0("Q", id)
	
	# prepare request
	url <- paste0("http://www.wikidata.org/w/api.php?action=wbgetclaims&format=json&entity=", id)
	
	# execute request
	raw <- GET(url, config=add_headers("User-agent"="rwikidata"))
		
	# parse
	claim <- httr::content(raw, as="parsed")
	
	if(length(claim$claims)==0) warning("no claims found")
	else {
		claim <- claim$claims
		class(claim) <- "wdclaims"
		if(print) print(claim)
		invisible(claim)
	}
}


#' Get claims of a Wikidata item - default method
#'
#' @param item The Wikidata item object - from \code{\link{wdgetitem}}
#' @param print Logical - if \code{TRUE} the claims are printed
#' @return A data frame listing all claims of the item
getclaims.default <- function(item, print=TRUE) {

	if(is.null(item$entities[[1]]$claims)) warning("no claims found in item", substitute(item))
	else {
		# get claim
		wdclaim <- item$entities[[1]]$claims
		
		class(wdclaim) <- "wdclaims"
		if(print) print(wdclaim)
		invisible(wdclaim)
	}
}


#' Print method for wdclaim
#'
#' @param claim wdclaim object from \code{\link{wdgetclaims}} or \code{\link{getclaims}}
print.wdclaims <- function(claim) {
	
	# get ids and names
	claim.num <- length(claim)
	claim.id <- names(claim)
	claim.name <- NULL
	if(claim.num>0) for(i in 1:claim.num) claim.name <- append(claim.name, wdgetproperty(claim.id[i], print=FALSE)[1])
	else stop("no claims found")
	claim.name[nchar(claim.name)>25] <- paste(substr(claim.name[nchar(claim.name)>25], 1, 25), "...")
	
	# get guids
	claim.guid <- list()
	if(claim.num>0) for(i in 1:claim.num) {
		claim.set <- claim[[i]]
		guid <- NULL
		for(j in 1:length(claim.set)) guid <- append(guid, claim.set[[j]]$id)
		claim.guid[[i]] <- guid
	}
	
	# prepare output
	claim.tbl <- c(claim.id[1], claim.name[1], claim.guid[[1]][1])
	if(length(claim.guid[[1]])>1) for(j in 2:length(claim.guid[[1]])) claim.tbl <- rbind(claim.tbl, c("", "", claim.guid[[1]][j]))
	if(length(claim.id)>1) for(i in 2:length(claim.id)) {
		claim.tbl <- rbind(claim.tbl, c(claim.id[i], claim.name[i], claim.guid[[i]][1]))
		if(length(claim.guid[[i]])>1) for(j in 2:length(claim.guid[[i]])) claim.tbl <- rbind(claim.tbl, c("", "", claim.guid[[i]][j]))
	}
	row.names(claim.tbl) <- c(1:nrow(claim.tbl))
	claim.tbl <- as.data.frame(claim.tbl)
	names(claim.tbl) <- c("Property", "Claim", "GUID")
		
	# print
	cat("\n\tWikidata claims\n\n")
	print(claim.tbl, quote=FALSE, right=FALSE, row.names=FALSE)
}
