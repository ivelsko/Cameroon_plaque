## Load libraries
library(tidyverse)
library(BacDiveR)

## DATA
## Load heatmap block data
species_ancom <- fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_noblanks_HMP_HG.tsv", sep = "\t") 
species_list <- species_ancom %>%
  select(Species) %>% 
  bind_rows(., fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_noblanks_JAE_HG.tsv", sep = "\t") %>%
              select(Species)) %>%
  bind_rows(., fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_cmc_FA_FC.tsv", sep = "\t") %>%
              select(Species)) %>%
  bind_rows(., fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_cmc_FA_LR.tsv", sep = "\t") %>%
              select(Species)) %>%
  bind_rows(., fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_cmc_sex.tsv", sep = "\t") %>%
              select(Species)) %>%
  bind_rows(., fread("/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/ancomBC_species_cmc_toothsite.tsv", sep = "\t") %>%
              select(Species)) %>%
  distinct() %>%
  rename(Taxon = Species)

table_nt <- species_list

## set some additional prior info
bacdive_tibble_names <- c("bacdive_id", "section", "subsection", "field")

empty_bacdive_tibble <- setNames(data.frame(matrix(ncol = 4, nrow = 0)), 
                                 bacdive_tibble_names) %>% 
  as_tibble

## FUNCTIONS
bacdiveadv_to_tibble <- function(x){
  ## Uses advanced search to find only representative strains
  term <- paste0("https://bacdive.dsmz.de/advsearch?site=advsearch&searchparams%5B73%5D%5Bcontenttype%5D=text&searchparams%5B73%5D%5Btypecontent%5D=contains&searchparams%5B73%5D%5Bsearchterm%5D=", str_replace_all({{x}}, "_", "+"),"&searchparams%5B5%5D%5Bsearchterm%5D=1&advsearch=search")
  print(term)
  result <- tryCatch(bd_retrieve_by_search(term), error = function(x) NA)
  length(result) %>% print
  if (length(result) == 0) {
    return(NA)
  } else if (is.na(result)) {
    return(result)
  } else {
    clean_result <- result %>%
      unlist() %>% 
      bind_rows() %>% 
      gather(grouped_category, value, 1:ncol(.)) %>%
      separate(grouped_category, sep = "\\.", into = bacdive_tibble_names)
    return(clean_result)
  }
}

bacdive_to_tibble <- function(x){
  ## Uses broad search for all strains
  term <- str_replace_all({{x}}, "_", " ")
  
  print(term)
  result <- tryCatch(bd_retrieve_taxon(term), error = function(x) NA, warning = function(x) NA)
  length(result) %>% print
  if (length(result) == 0) {
    return(NA)
  } else if (is.na(result)) {
    return(result)
  } else {
    clean_result <- result %>%
      unlist() %>% 
      bind_rows() %>% 
      gather(grouped_category, value, 1:ncol(.)) %>%
      separate(grouped_category, sep = "\\.", into = bacdive_tibble_names)
    return(clean_result)
  }
}

## ANALYSIS
## Perform advanced search and filter for useful data
table_nt_meta <- table_nt %>% 
  mutate(BacDive_Result = map(Taxon, bacdiveadv_to_tibble)) %>%
  mutate(Length = map(BacDive_Result, length) %>% unlist) %>%
  group_by(Length) %>%
  group_split(Length)
  
  
table_nt_meta_new <- table_nt_meta[[1]] %>%
  mutate(BacDive_Result = map(Taxon, bacdive_to_tibble)) %>%
  mutate(Length = map(BacDive_Result, length) %>% unlist) %>%
  filter(Length != 1) %>%
  unnest() %>%
  select(-bacdive_id) %>%
  distinct %>%
  filter(!section %in% c("taxonomy_name", "application_interaction", "strain_availability", "references"),
         !grepl("_reference|text_mined", field),
         !grepl("sequence", subsection)) %>%
  print()

table_nt_meta_rep <- table_nt_meta[[1]] %>%
  filter(Length != 1) %>%
  unnest(c(BacDive_Result)) %>%
  # select(-bacdive_id) %>%
  distinct %>%
  filter(!section %in% c("taxonomy_name", "application_interaction", "strain_availability", "references"),
         !grepl("_reference|text_mined", field),
         !grepl("sequence", subsection)) %>%
  print()


# table_nt_meta_final <- bind_rows(table_nt_meta_rep, table_nt_meta_new)
table_nt_meta_final <-table_nt_meta_new


## Get oxygen data only
data_oxygen <- table_nt_meta_final %>% 
  select(Taxon, field, value) %>%
  filter(grepl("oxygen_tol", field)) %>%
  group_by(Taxon) %>%
  summarise(aggregate_oxygen_tol = paste0(unique(value), collapse = "/"))

data_gram <- table_nt_meta_final %>% 
  select(Taxon, field, value) %>%
  filter(grepl("gram_stain", field)) %>%
  group_by(Taxon) %>%
  summarise(aggregate_gram_stain = paste0(unique(value), collapse = "/"))

data_meta_final <- left_join(data_oxygen, data_gram)

fwrite(data_meta_final, "/Users/velsko/Dropbox (Personal)/MPI-SHH/CMC/Cameroon_plaque/05-results.backup/bacdiveR_metadata.tsv", sep = "\t", quote = F)
# write_tsv(data_meta_final, paste0(tools::file_path_sans_ext(species_ancom), "_metadata.tsv"))
