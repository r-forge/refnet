## This is EB's edit's to the instructions on using refnet Forrest wrote up.
## Don't forget that to add your commits to the fork you need to do the following: 
## In RStudio menus go to "Tools"->"Shell" and type the following: git push origin proposed-updates
## See: http://r-bio.github.io/intro-git-rstudio/ for more info.

## THis is Forrest's original instructions for getting started
#	Set this to wherever you unzipped the archive folders (not /src):
# setwd("C:/tmp")
# detach(package:refnet, unload=TRUE)
# remove.packages("refnet")
# Original files
# install.packages("~/Desktop/refnet_0.6.tar.gz", repos = NULL, type="source")
# Unzipped packages
# install.packages("~/Desktop/refnet", repos = NULL, type="source")
# Should only have to do above once.

## TO INSTALL PACKAGE FROM GITHUB (added by EB after forking refnet)
## from http://kbroman.org/pkg_primer/pages/github.html
# Load the devtools package
library(devtools)

# # This installs the original (install_github points to the master branch)
# install_github("embruna/refnet", subdir="pkg") 

# This installs the package from the "proposed-updates" branch 
# Trying to figure out the correct syntax for dfoing this:
# devtools::install_github("embruna/refnet/pkg@proposed-updates") # OR can do like this
devtools::install_github("embruna/refnet", ref = "proposed-updates", subdir = "pkg")


require(refnet)
# to check can run read_references
read_references

# read_references uncomment this to see what code is being read in.

?refnet #Package info

##	This reads in single files. Can specify a directory & set dir=TRUE flag to read in entire directory of files.
##	If the filename_root argument is not "" then it is used to create the root filenames for CSV output:

## EB: I have uploaded three sample datafiles: EBdata, Peru, and Ecuador. They include one that was originally used by FS
## to test-drive refnet, one that got hung up because of the change by T-R in how they coded ResearcherID (Peru)
## and one downloaded from WOS on 11 jan 2016 that has the new ResearchID tag AND has the ORCID ID field code.
## Note that T-R adds ORCID ID all article records retroactively (i.e., even if person didn't have an ORCID ID at the 
## time they had submitted the paper). This and the greater updtake of ORCID than other ID numbers makes it the best 
## option for disambiguating author names.

# This uses some sample datasets posted to guthub Use package RCurl dowload them
# see: https://www.r-bloggers.com/data-on-github-the-easy-way-to-make-your-data-available/ 

# the first argument of "read_references" should point to the folder where your data files are installed. 
ecuador_references <- read_references("./data/Ecuador.txt", dir=FALSE, filename_root="./pkg/output/ecuador")
output <- read_authors(ecuador_references, filename_root="./pkg/output/ecuador")
ecuador_authors <- output$authors
ecuador_authors__references <- output$authors__references

eb_references <- read_references("./data/EBpubs.txt", dir=FALSE, filename_root="./pkg/output/eb")
output <- read_authors(eb_references, filename_root="./pkg/output/eb")
eb <- output$authors
eb_authors__references <- output$authors__references

peru_references <- read_references("./data/peru.txt", dir=FALSE, filename_root="./pkg/output/peru")
output <- read_authors(peru_references, filename_root="./pkg/output/peru")
peru_authors <- output$authors
peru_authors__references <- output$authors__references

##############################################################################################
##########################           NEXT STEPS (12 jan 2017)             #####################
# 1) the researcherID is not being read in correctly due to T-R changing from RID to RI...
# 2) ...but it's a moot point, since we will be changing to ORCID ID to help disambiguate names
###############################################################################################








##	After reading the files in you can check the ecuador_authors.csv file
##	and by hand in Excel, using the AU_ID_Dupe and Similarity fields, merge any author records that represent the same author.
##	After doing so you can read these back into R using the following, or if you're not starting from scratch above:

###	Can be read back in without importing from the following three commands:
#ecuador_references <- read.csv("output/ecuador_references.csv", as.is=TRUE)
#ecuador_authors <- read.csv("output/ecuador_authors.csv", as.is=TRUE)
#ecuador_authors__references <- read.csv("output/ecuador_authors__references.csv", as.is=TRUE)


##	Process Brazilian records:

brazil_references <- read_references("data/savedrecs (5).ciw", dir=FALSE, filename_root="output/brazil")
output <- read_authors(brazil_references, filename_root="output/brazil")
brazil_authors <- output$authors
brazil_authors__references <- output$authors__references

#brazil_references <- read.csv("output/brazil_references.csv", as.is=TRUE)
#brazil_authors <- read.csv("output/brazil_authors.csv", as.is=TRUE)
#brazil_authors__references <- read.csv("output/brazil_authors__references.csv", as.is=TRUE)


##	Calculate the percentage of author records without contact information:

sum(brazil_authors$C1 == "" | is.na(brazil_authors$C1))/length(brazil_authors$C1)*100

sum(ecuador_authors$C1 == "" | is.na(ecuador_authors$C1))/length(ecuador_authors$C1)*100


##	Let's remove duplicates from our presumably updated and corrected author lists:

output <- remove_duplicates(authors=ecuador_authors, authors__references=ecuador_authors__references, filename_root="output/ecuador_nodupe")
ecuador_authors <- output$authors
ecuador_authors__references <- output$authors__references

output <- remove_duplicates(authors=brazil_authors, authors__references=brazil_authors__references, filename_root="output/brazil_nodupe")
brazil_authors <- output$authors
brazil_authors__references <- output$authors__references


##	Now let's merge references, authors, and authors__references:

output <- merge_records(
	references=brazil_references, 
	authors=brazil_authors, 
	authors__references=brazil_authors__references, 
	references_merge=ecuador_references, 
	authors_merge=ecuador_authors, 
	authors__references_merge=ecuador_authors__references, 
	filename_root = "output/merged"
)

merged_references <- output$references
merged_authors <- output$authors
merged_authors__references <- output$authors__references

##	And finally after scrolling through and hand-correcting any authors
##		from the merged list that have a high similarity:
#m   erged_authors <- read.csv("merged_authors.csv", as.is=TRUE)

output <- remove_duplicates(authors=merged_authors, authors__references=merged_authors__references, filename_root="output/merged_nodupe")
merged_authors <- output$authors
merged_authors__references <- output$authors__references



######
##	Sample geographic plotting of author locations based on RP or C1:

##	How to process addresses:
authors_working <- merged_authors

##	Process a single address at a time:
refnet_geocode(data.frame("AU_ID"=authors_working$AU_ID[1], "type"="RP", "address"=authors_working$RP[1], stringsAsFactors=FALSE))
refnet_geocode(data.frame("AU_ID"=authors_working$AU_ID[2], "type"="RP", "address"=authors_working$RP[2], stringsAsFactors=FALSE), verbose=TRUE)

##	Process a group of addresses:
read_addresses(data.frame("AU_ID"=authors_working$AU_ID[1:10], "type"="RP", "address"=authors_working$RP[1:10], stringsAsFactors=FALSE), verbose=TRUE)


##	Sample using the first C1 address listed for the first 1000 authors, 
##		keyed by author so we can join it back:
##	NOTE:  The string "NA" does get translated to a point so we'll remove it
##		before passing it along:

address_list_working <- sapply(strsplit(authors_working$C1[1:1000], "\n"), FUN=function(x) { return(x[1]) })
address_list_working_au_id <- authors_working$AU_ID[1:1000][!is.na(address_list_working)]
address_list_working <- address_list_working[!is.na(address_list_working)]

##	Let's try to strip off any institutional references which may complicate geocoding:
address_list_working <- gsub("^.* (.*,.*,.*)$", "\\1", address_list_working)
address_list_working <- gsub("[. ]*$", "", address_list_working)

##	Use the full list to create addresses from the C1 records:
addresses_working <- read_addresses(data.frame("id"=address_list_working_au_id, "type"="C1", "address"=address_list_working, stringsAsFactors=FALSE), filename_root="output/merged_nodupe_addresses_C1_first1000")
#addresses_working <- read.csv("output/merged_nodupe_addresses_C1_first1000_addresses.csv")


##	Now we can use those addresses to plot things out:
plot_addresses_country(addresses_working)
plot_addresses_points(addresses_working)

##	Uncomment to save as a PDF, and display the semi-transparent edge color:
#pdf("output/merged_nodupe_first1000_linkages_countries.pdf")
net_plot_coauthor(addresses_working, merged_authors__references)
#dev.off()
net_plot_coauthor_country(addresses_working, merged_authors__references)

##	The default plot area doesn't show semitransparent colors, so we'll output to PDF:
output <- net_plot_coauthor_country(addresses_working, merged_authors__references)
ggsave("output/merged_nodupe_first1000_linkages_countries_world_ggplot.pdf", output, h = 9/2, w = 9)


##	We can subset records any way that makes sense.  For example, if we wanted to only use references from 2012 (note that the way records are read in they are strings and have a hard return character):
ref_index <- merged_references$PY == "2012\n"
summary(ref_index)

##	Pull reference IDs (UT field) for just those from 2012:
UT_index <- merged_references$UT[ref_index]
merged_authors__references_subset <- merged_authors__references[ merged_authors__references$UT %in% UT_index, ]

##	Plot the subset for 2012:
net_plot_coauthor_country(addresses_working, merged_authors__references_subset)


##	Compare to 2011:
ref_index <- merged_references$PY == "2011\n"
UT_index <- merged_references$UT[ref_index]
merged_authors__references_subset <- merged_authors__references[ merged_authors__references$UT %in% UT_index, ]

##	Plot the subset for 2011:
net_plot_coauthor_country(addresses_working, merged_authors__references_subset)
