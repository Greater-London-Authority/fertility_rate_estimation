################################################################################
## WARNING: running this script will update the public facing datastore page. ##
## Have a human check the html file and the  ##
## data output files before running this.                                     ##
################################################################################

# Add the fertility rate estimates data and supporting info page to the London Datastore using
# the London Datastore API

# 1.0 Install and attach required packages ---------------------------------

# 1.1 Install and load required packages
library(ldndatar)
library(magrittr)
library(rmarkdown)
library(tidyr)

# 1.2 Turn off scientific notation
options(scipen = 999)

# 1.3 Set my_api_key for the London Datastore
my_api_key <- Sys.getenv("DATA_STORE_API_KEY")

# 1.4 the slug is the name of the datastore page as given at the end of the page URL
page_slug <- "age-specific-fertility-rates"

# Section 2 - Add Description and Resources to dataset ---------------------

# 2.1 Add births_by_mothers_country_of_birth_markdown.Rmd to the dataset as its description
new_description <-
  list(lds_description_render(
    "datastore_description.Rmd",
    include_title = FALSE,
    save_html = FALSE
  ))
names(new_description) <- "description"


lds_patch_dataset(
  slug = page_slug,
  my_api_key,
  patch = new_description
)

# 2.2 Add all resources to the dataset

# Transform rds data into csv
write.csv(readRDS("data/processed/smooth_asfr_lad_agg_cy.rds"), "smooth_asfr_lad_agg_cy.csv", row.names = FALSE)
write.csv(readRDS("data/processed/tfr_lad_agg_cy.rds"), "tfr_lad_agg_cy.csv", row.names = FALSE)

# Create list of resources which need to be uploaded and their descriptions
datastore_resources_list <-
  list(
    technical_notes = "fertility_rate_analysis.html",
    raw_asfr = "data/processed/raw_asfr_lad_agg_cy.csv",
    smooth_asfr = "data/processed/smooth_asfr_lad_agg_cy.csv",
    tfr = "data/processed/tfr_lad_agg_cy.csv"
  )

datastore_resources_descriptions <-
  list(
    technical_notes = "Technical notes: how age-specifica and total fertility rates are calculated, smoothing technique and background information.",
    raw_asfr = "Raw age-specific fertility ratesestimates. Data for local authority districts, regions, and ITL 2 subregions in England and Wales",
    smooth_asfr = "Smooth age-specific fertility rates estimates. Data for local authority districts, regions, and ITL 2 subregions in England and Wales",
    tfr = "Total fertility rates estimates. Data for local authority districts, regions, and ITL 2 subregions in England and Wales"
  )


# The following algorithm checks if there are any resources associated with this dataset, and uploads all the ones in
# datastore_resources_list if there aren't any.

# If there are already resources associated with the dataset which is being modified then where a new resource has
# the same name as an existing resource it will replace it. Otherwise the new resources will be added alongside those
# that are already there.

if (
  !"resource_id" %in% colnames(lds_meta_dataset(slug = page_slug, my_api_key))
) {
  mapply(
    function(x, y) {
      lds_add_resource(
        file_path = x,
        description = y,
        slug = page_slug,
        my_api_key
      )
    },
    datastore_resources_list,
    datastore_resources_descriptions
  )
} else {
  datastore_resources_descriptions <-
    bind_rows(datastore_resources_descriptions) %>%
    gather(list_item, description)

  datastore_resources_list <-
    bind_rows(datastore_resources_list) %>%
    gather(list_item, filepath) %>%
    mutate(name = basename(filepath)) %>%
    left_join(datastore_resources_descriptions, by = "list_item") %>%
    select(-list_item)

  current_resources_names <-
    select(
      as_tibble(lds_meta_dataset(slug = page_slug, my_api_key)),
      resource_title,
      resource_id
    )

  datastore_resources_list <-
    left_join(
      datastore_resources_list,
      current_resources_names,
      by = c("name" = "resource_title")
    )

  for (i in 1:nrow(datastore_resources_list)) {
    if (is.na(datastore_resources_list$resource_id[i])) {
      lds_add_resource(
        file_path = datastore_resources_list$filepath[i],
        res_title = datastore_resources_list$name[i],
        description = datastore_resources_list$description[i],
        slug = page_slug,
        my_api_key
      )
    } else {
      lds_replace_resource(
        file_path = datastore_resources_list$filepath[i],
        slug = page_slug,
        res_id = datastore_resources_list$resource_id[i],
        res_title = datastore_resources_list$name[i],
        description = datastore_resources_list$description[i],
        api_key = my_api_key
      )
    }
  }
}

# Section 3 - Clear Environment -------------------------------------------

# 3.1
rm(list = ls())
