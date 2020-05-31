################################################################################
# Project: Streptococcus sialic acid-binding/serine-rich repeat protein evolution
# Part: Functional gene content
# Step: Factor analysis on SEED proteins
#
# Irina Velsko, 30/05/2020
################################################################################

from snakemake.utils import R

workdir: "/projects1/microbiome_calculus/Cameroon_plaque/02-scripts.backup"

# /projects1/clusterhomes/velsko/R/x86_64-pc-linux-gnu-library/3.5/

rule all:
    input: 
        "../05-results.backup/presentation_pdfs/seed_oblimin_ols_scree.pdf",
        "../05-results.backup/seed_L4.decontam_noblanks.fa_oblimin_ols.df.tsv",
        "../05-results.backup/presentation_pdfs/seed_Varimax_ols_scree.pdf",
        "../05-results.backup/seed_L4.decontam_noblanks.fa_Varimax_ols.df.tsv",
        "../05-results.backup/presentation_pdfs/seed_cmc_oblimin_ols_scree.pdf",
        "../05-results.backup/seed_L4.decontam_cmc.fa_oblimin_ols.df.tsv",
        "../05-results.backup/presentation_pdfs/seed_cmc_Varimax_ols_scree.pdf",
        "../05-results.backup/seed_L4.decontam_cmc.fa_Varimax_ols.df.tsv"


rule noblanks_oblimin_ols:
    output:
        seed_oblimin_ols_scree = "../05-results.backup/presentation_pdfs/seed_oblimin_ols_scree.pdf",
        noblanks_oblimin_ols = "../05-results.backup/seed_L4.decontam_noblanks.fa_oblimin_ols.df.tsv"

    message: "run factor analysis on SEED proteins with oblimin rotation and ols"
    params:
        seed_tables = "../05-results.backup/CMC_seed_tables.RData",
        metadata = "../05-results.backup/CMC_metadata.RData"

    run:
        R("""
          library(data.table)
          library(psych)
          library(vegan)
          library(ape)
          library(compositions)
          library(MASS)
          library(tidyverse)
          library(gplots)
          
          load({params.seed_tables})
          
          load({params.metadata})
          
          # Determine the prevalence of SEED proteins in each group
          seed_L4.decontam_noblanks_presence_less_30 <- seed_L4.decontam %>%
            select(-matches("EXB|LIB|10M")) %>%
            mutate_if(is.numeric, ~1 * (. > 0)) %>%
            gather("SampleID","Counts",2:ncol(.)) %>%
            inner_join(., metadata %>%
                       select(SampleID, Ethnic_Group), by = "SampleID") %>%
            group_by(Ethnic_Group, Pathway) %>%
            summarize(Percent_presence = sum(Counts)/length(SampleID)*100) %>%
            # select the SEED proteins that are present in at least 30% of at least one group
            ungroup() %>%
            filter(Percent_presence <= 33.33) %>%
            distinct(Pathway) %>%
            # pull out these proteins to keep
            separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
            select(Pathway)

          # SEED proteins, no blanks 
          seed_L4.decontam_noblanks <- seed_L4.decontam %>%
                               select(-matches("EXB|LIB|10M")) %>%
                               separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
                               select(-c("SEED","L2","L3")) %>%
                               anti_join(., seed_L4.decontam_noblanks_presence_less_30, by = "Pathway") %>%
                               gather("SampleID","Counts",2:ncol(.)) %>%
                               spread(Pathway,Counts)

          rownames(seed_L4.decontam_noblanks) <- seed_L4.decontam_noblanks$SampleID

          seed_L4.decontam_noblanks <- seed_L4.decontam_noblanks %>% select(-SampleID)

          seed_L4.decontam_noblanks = seed_L4.decontam_noblanks+1

          # perform PCA to get a clr-transformed species table
          seed_L4.decontam_noblanks.pca <- mixOmics::pca(seed_L4.decontam_noblanks, ncomp = 3, logratio = 'CLR')
          # save the clr-transformed species table
          seed_L4.decontam_noblanks_clr <- as.data.frame.matrix(seed_L4.decontam_noblanks.pca$X)

          # run the factor analysis
          seed_L4.decontam_noblanks.fa <- fa(seed_L4.decontam_noblanks_clr, nfactors = 6, rotate = "oblimin", fm = "ols") # rotate = "Varimax" "oblimin" # fm = "ols" "minres"
          # if using fm = "ols", the column titles will be 1, 2, etc and not M1, M2, etc as you get from using fm = "minres"

          # make and save a scree plot to examine
          seed_oblimin_ols_scree <- seed_L4.decontam_noblanks.fa$values %>%
            as.data.frame(.) %>%
            rename(Eigenvalues = ".") %>%
            arrange(desc(Eigenvalues))%>%
            rownames_to_column("xvalue") %>%
            mutate(xvalue = as.numeric(xvalue)) %>%
            filter(xvalue <= 20) %>%
            ggplot(., aes(xvalue, Eigenvalues)) +
              geom_point() +
              theme_minimal() +
              geom_hline(yintercept = 10, linetype = "dashed", color = "red")
              
          ggsave("{output.seed_oblimin_ols_scree}", plot = seed_oblimin_ols_scree, device = "pdf",
            scale = 1, width = 10, height = 10, units = c("in"), dpi = 300)


          # get the minimum residual values into a datatable
          graphinfo <- as.data.frame(factor2cluster(seed_L4.decontam_noblanks.fa))
          colnames(graphinfo) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          graphinfo <- graphinfo %>%
            rownames_to_column("Species") %>%
            as_tibble(.) 

          # now make loadings into a table and designate each species in the residual with the highest absolute value
          seed_L4.decontam_noblanks.fa.df <- as.data.frame.matrix(seed_L4.decontam_noblanks.fa$loadings)
          # b/c of rotation, the MRs may not be in numerial order. Change the column titles to be in numerical order for downstream processing
          colnames(seed_L4.decontam_noblanks.fa.df) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          seed_L4.decontam_noblanks.fa.df <- seed_L4.decontam_noblanks.fa.df %>%
            as_tibble(.) %>%
            bind_cols(., graphinfo) %>%
            mutate(MR11 = as.character(MR11),
                   MR21 = as.character(MR21),
                   MR31 = as.character(MR31),
                   MR41 = as.character(MR41),
                   MR51 = as.character(MR51)) %>%
            mutate(MR11 = replace(MR11, MR11 != "0", "MR1"),
                   MR21 = replace(MR21, MR21 != "0", "MR2"),
                   MR31 = replace(MR31, MR31 != "0", "MR3"),
                   MR41 = replace(MR41, MR41 != "0", "MR4"),
                   MR51 = replace(MR51, MR51 != "0", "MR5")) %>%
           select(Species,everything(.)) %>%
           gather("Group","Residual", 7:ncol(.)) %>%
           filter(Residual != "0") %>%
           select(Residual, Species, MR1, MR2, MR3, MR4, MR5)
          
          fwrite(seed_L4.decontam_noblanks.fa.df, file = "{output.noblanks_oblimin_ols}", quote = F, sep = "\t")

        """)

rule noblanks_Varimax_ols:
    output:
        seed_Varimax_ols_scree = "../05-results.backup/presentation_pdfs/seed_Varimax_ols_scree.pdf",
        noblanks_Varimax_ols = "../05-results.backup/seed_L4.decontam_noblanks.fa_Varimax_ols.df.tsv"

    message: "run factor analysis on SEED proteins with Varimax rotation and ols"
    params:
        seed_tables = "../05-results.backup/CMC_seed_tables.RData",
        metadata = "../05-results.backup/CMC_metadata.RData"

    run:
        R("""
          library(data.table)
          library(psych)
          library(vegan)
          library(ape)
          library(compositions)
          library(MASS)
          library(mixOmics)
          library(tidyverse)
          library(gplots)
          
          load({params.seed_tables})
          
          load({params.metadata})
          
          # Determine the prevalence of SEED proteins in each group
          seed_L4.decontam_noblanks_presence_less_30 <- seed_L4.decontam %>%
            select(-matches("EXB|LIB|10M")) %>%
            mutate_if(is.numeric, ~1 * (. > 0)) %>%
            gather("SampleID","Counts",2:ncol(.)) %>%
            inner_join(., metadata %>%
                       select(SampleID, Ethnic_Group), by = "SampleID") %>%
            group_by(Ethnic_Group, Pathway) %>%
            summarize(Percent_presence = sum(Counts)/length(SampleID)*100) %>%
            # select the SEED proteins that are present in at least 30% of at least one group
            ungroup() %>%
            filter(Percent_presence <= 33.33) %>%
            distinct(Pathway) %>%
            # pull out these proteins to keep
            separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
            select(Pathway)

          # SEED proteins, no blanks 
          seed_L4.decontam_noblanks <- seed_L4.decontam %>%
                               select(-matches("EXB|LIB|10M")) %>%
                               separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
                               select(-c("SEED","L2","L3")) %>%
                               anti_join(., seed_L4.decontam_noblanks_presence_less_30, by = "Pathway") %>%
                               gather("SampleID","Counts",2:ncol(.)) %>%
                               spread(Pathway,Counts)

          rownames(seed_L4.decontam_noblanks) <- seed_L4.decontam_noblanks$SampleID

          seed_L4.decontam_noblanks <- seed_L4.decontam_noblanks %>% select(-SampleID)

          seed_L4.decontam_noblanks = seed_L4.decontam_noblanks+1

          # perform PCA to get a clr-transformed species table
          seed_L4.decontam_noblanks.pca <- mixOmics::pca(seed_L4.decontam_noblanks, ncomp = 3, logratio = 'CLR')
          # save the clr-transformed species table
          seed_L4.decontam_noblanks_clr <- as.data.frame.matrix(seed_L4.decontam_noblanks.pca$X)

          # run the factor analysis
          seed_L4.decontam_noblanks.fa <- fa(seed_L4.decontam_noblanks_clr, nfactors = 6, rotate = "Varimax", fm = "ols") # rotate = "Varimax" "oblimin" # fm = "ols" "minres"
          # if using fm = "ols", the column titles will be 1, 2, etc and not M1, M2, etc as you get from using fm = "minres"

          # make and save a scree plot to examine
          seed_Varimax_ols_scree <- seed_L4.decontam_noblanks.fa$values %>%
            as.data.frame(.) %>%
            rename(Eigenvalues = ".") %>%
            arrange(desc(Eigenvalues))%>%
            rownames_to_column("xvalue") %>%
            mutate(xvalue = as.numeric(xvalue)) %>%
            filter(xvalue <= 20) %>%
            ggplot(., aes(xvalue, Eigenvalues)) +
              geom_point() +
              theme_minimal() +
              geom_hline(yintercept = 10, linetype = "dashed", color = "red")
              
          ggsave("{output.seed_Varimax_ols_scree}", plot = seed_Varimax_ols_scree, device = "pdf",
            scale = 1, width = 10, height = 10, units = c("in"), dpi = 300)


          # get the minimum residual values into a datatable
          graphinfo <- as.data.frame(factor2cluster(seed_L4.decontam_noblanks.fa))
          colnames(graphinfo) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          graphinfo <- graphinfo %>%
            rownames_to_column("Species") %>%
            as_tibble(.) 

          # now make loadings into a table and designate each species in the residual with the highest absolute value
          seed_L4.decontam_noblanks.fa.df <- as.data.frame.matrix(seed_L4.decontam_noblanks.fa$loadings)
          # b/c of rotation, the MRs may not be in numerial order. Change the column titles to be in numerical order for downstream processing
          colnames(seed_L4.decontam_noblanks.fa.df) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          seed_L4.decontam_noblanks.fa.df <- seed_L4.decontam_noblanks.fa.df %>%
            as_tibble(.) %>%
            bind_cols(., graphinfo) %>%
            mutate(MR11 = as.character(MR11),
                   MR21 = as.character(MR21),
                   MR31 = as.character(MR31),
                   MR41 = as.character(MR41),
                   MR51 = as.character(MR51)) %>%
            mutate(MR11 = replace(MR11, MR11 != "0", "MR1"),
                   MR21 = replace(MR21, MR21 != "0", "MR2"),
                   MR31 = replace(MR31, MR31 != "0", "MR3"),
                   MR41 = replace(MR41, MR41 != "0", "MR4"),
                   MR51 = replace(MR51, MR51 != "0", "MR5")) %>%
           select(Species,everything(.)) %>%
           gather("Group","Residual", 7:ncol(.)) %>%
           filter(Residual != "0") %>%
           select(Residual, Species, MR1, MR2, MR3, MR4, MR5)
          
          fwrite(seed_L4.decontam_noblanks.fa.df, file = "{output.noblanks_Varimax_ols}", quote = F, sep = "\t")

        """)

rule cmc_oblimin_ols:
    output:
        seed_cmc_oblimin_ols_scree = "../05-results.backup/presentation_pdfs/seed_cmc_oblimin_ols_scree.pdf",
        cmc_oblimin_ols = "../05-results.backup/seed_L4.decontam_cmc.fa_oblimin_ols.df.tsv"

    message: "CMC samples only - run factor analysis on SEED proteins with oblimin rotation and ols"
    params:
        seed_tables = "../05-results.backup/CMC_seed_tables.RData",
        metadata = "../05-results.backup/CMC_metadata.RData"

    run:
        R("""
          library(data.table)
          library(psych)
          library(vegan)
          library(ape)
          library(compositions)
          library(MASS)
          library(tidyverse)
          library(gplots)
          
          load({params.seed_tables})
          
          load({params.metadata})
          
          # SEED proteins, CMC only 
          # Determine the prevalence of SEED proteins in each group
          seed_L4.decontam_cmc_presence_less_30 <- seed_L4.decontam %>%
            select(-matches("EXB|LIB|10M|SRR|JAE")) %>%
            mutate_if(is.numeric, ~1 * (. > 0)) %>%
            gather("SampleID","Counts",2:ncol(.)) %>%
            inner_join(., metadata %>%
                       select(SampleID, Ethnic_Group), by = "SampleID") %>%
            group_by(Ethnic_Group, Pathway) %>%
            summarize(Percent_presence = sum(Counts)/length(SampleID)*100) %>%
            # select the SEED proteins that are present in at least 30% of at least one group
            ungroup() %>%
            filter(Percent_presence <= 33.33) %>%
            distinct(Pathway) %>%
            # pull out these proteins to keep
            separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
            select(Pathway)

          seed_L4.decontam_cmc <- seed_L4.decontam %>%
                               select(-matches("EXB|LIB|10M|SRR|JAE")) %>%
                               separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
                               select(-c("SEED","L2","L3")) %>%
                               anti_join(., seed_L4.decontam_cmc_presence_less_30, by = "Pathway") %>%
                               gather("SampleID","Counts",2:ncol(.)) %>%
                               spread(Pathway,Counts)

          rownames(seed_L4.decontam_cmc) <- seed_L4.decontam_cmc$SampleID

          seed_L4.decontam_cmc <- seed_L4.decontam_cmc %>% select(-SampleID)
          seed_L4.decontam_cmc = seed_L4.decontam_cmc+1

          # perform PCA to get a clr-transformed species table
          seed_L4.decontam_cmc.pca <- mixOmics::pca(seed_L4.decontam_cmc, ncomp = 3, logratio = 'CLR')
          # save the clr-transformed species table
          seed_L4.decontam_cmc_clr <- as.data.frame.matrix(seed_L4.decontam_cmc.pca$X)

          # run the factor analysis
          seed_L4.decontam_cmc.fa <- fa(seed_L4.decontam_cmc_clr, nfactors = 6, rotate = "oblimin", fm = "ols") # rotate = "Varimax" "oblimin" # fm = "ols" "minres"
          # if using fm = "ols", the column titles will be 1, 2, etc and not M1, M2, etc as you get from using fm = "minres"

          # make and save a scree plot to examine
          seed_cmc_oblimin_ols_scree <- seed_L4.decontam_cmc.fa$values %>%
            as.data.frame(.) %>%
            rename(Eigenvalues = ".") %>%
            arrange(desc(Eigenvalues))%>%
            rownames_to_column("xvalue") %>%
            mutate(xvalue = as.numeric(xvalue)) %>%
            filter(xvalue <= 20) %>%
            ggplot(., aes(xvalue, Eigenvalues)) +
              geom_point() +
              theme_minimal() +
              geom_hline(yintercept = 10, linetype = "dashed", color = "red")
              
          ggsave("{output.seed_cmc_oblimin_ols_scree}", plot = seed_cmc_oblimin_ols_scree, device = "pdf",
            scale = 1, width = 10, height = 10, units = c("in"), dpi = 300)


          # get the minimum residual values into a datatable
          graphinfo <- as.data.frame(factor2cluster(seed_L4.decontam_cmc.fa))
          colnames(graphinfo) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          graphinfo <- graphinfo %>%
            rownames_to_column("Species") %>%
            as_tibble(.) 

          # now make loadings into a table and designate each species in the residual with the highest absolute value
          seed_L4.decontam_cmc.fa.df <- as.data.frame.matrix(seed_L4.decontam_cmc.fa$loadings)
          # b/c of rotation, the MRs may not be in numerial order. Change the column titles to be in numerical order for downstream processing
          colnames(seed_L4.decontam_cmc.fa.df) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          seed_L4.decontam_cmc.fa.df <- seed_L4.decontam_cmc.fa.df %>%
            as_tibble(.) %>%
            bind_cols(., graphinfo) %>%
            mutate(MR11 = as.character(MR11),
                   MR21 = as.character(MR21),
                   MR31 = as.character(MR31),
                   MR41 = as.character(MR41),
                   MR51 = as.character(MR51)) %>%
            mutate(MR11 = replace(MR11, MR11 != "0", "MR1"),
                   MR21 = replace(MR21, MR21 != "0", "MR2"),
                   MR31 = replace(MR31, MR31 != "0", "MR3"),
                   MR41 = replace(MR41, MR41 != "0", "MR4"),
                   MR51 = replace(MR51, MR51 != "0", "MR5")) %>%
           select(Species,everything(.)) %>%
           gather("Group","Residual", 7:ncol(.)) %>%
           filter(Residual != "0") %>%
           select(Residual, Species, MR1, MR2, MR3, MR4, MR5)
          
          fwrite(seed_L4.decontam_cmc.fa.df, file = "{output.cmc_oblimin_ols}", quote = F, sep = "\t")

       """)

rule cmc_Varimax_ols:
    output:
        seed_cmc_Varimax_ols_scree = "../05-results.backup/presentation_pdfs/seed_cmc_Varimax_ols_scree.pdf",
        cmc_Varimax_ols = "../05-results.backup/seed_L4.decontam_cmc.fa_Varimax_ols.df.tsv"

    message: "CMC samples only - run factor analysis on SEED proteins with Varimax rotation and ols"
    params:
        seed_tables = "../05-results.backup/CMC_seed_tables.RData",
        metadata = "../05-results.backup/CMC_metadata.RData"

    run:
        R("""
          library(data.table)
          library(psych)
          library(vegan)
          library(ape)
          library(compositions)
          library(MASS)
          library(tidyverse)
          library(gplots)
          
          load({params.seed_tables})
          
          load({params.metadata})
          
          # SEED proteins, CMC only 
          # Determine the prevalence of SEED proteins in each group
          seed_L4.decontam_cmc_presence_less_30 <- seed_L4.decontam %>%
            select(-matches("EXB|LIB|10M|SRR|JAE")) %>%
            mutate_if(is.numeric, ~1 * (. > 0)) %>%
            gather("SampleID","Counts",2:ncol(.)) %>%
            inner_join(., metadata %>%
                       select(SampleID, Ethnic_Group), by = "SampleID") %>%
            group_by(Ethnic_Group, Pathway) %>%
            summarize(Percent_presence = sum(Counts)/length(SampleID)*100) %>%
            # select the SEED proteins that are present in at least 30% of at least one group
            ungroup() %>%
            filter(Percent_presence <= 33.33) %>%
            distinct(Pathway) %>%
            # pull out these proteins to keep
            separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
            select(Pathway)

          seed_L4.decontam_cmc <- seed_L4.decontam %>%
                               select(-matches("EXB|LIB|10M|SRR|JAE")) %>%
                               separate(., Pathway, into = c("SEED","L2","L3","Pathway"), sep = ";") %>%
                               select(-c("SEED","L2","L3")) %>%
                               anti_join(., seed_L4.decontam_cmc_presence_less_30, by = "Pathway") %>%
                               gather("SampleID","Counts",2:ncol(.)) %>%
                               spread(Pathway,Counts)

          rownames(seed_L4.decontam_cmc) <- seed_L4.decontam_cmc$SampleID

          seed_L4.decontam_cmc <- seed_L4.decontam_cmc %>% select(-SampleID)
          seed_L4.decontam_cmc = seed_L4.decontam_cmc+1

          # perform PCA to get a clr-transformed species table
          seed_L4.decontam_cmc.pca <- mixOmics::pca(seed_L4.decontam_cmc, ncomp = 3, logratio = 'CLR')
          # save the clr-transformed species table
          seed_L4.decontam_cmc_clr <- as.data.frame.matrix(seed_L4.decontam_cmc.pca$X)

          # run the factor analysis
          seed_L4.decontam_cmc.fa <- fa(seed_L4.decontam_cmc_clr, nfactors = 6, rotate = "Varimax", fm = "ols") # rotate = "Varimax" "oblimin" # fm = "ols" "minres"
          # if using fm = "ols", the column titles will be 1, 2, etc and not M1, M2, etc as you get from using fm = "minres"

          # make and save a scree plot to examine
          seed_cmc_Varimax_ols_scree <- seed_L4.decontam_cmc.fa$values %>%
            as.data.frame(.) %>%
            rename(Eigenvalues = ".") %>%
            arrange(desc(Eigenvalues))%>%
            rownames_to_column("xvalue") %>%
            mutate(xvalue = as.numeric(xvalue)) %>%
            filter(xvalue <= 20) %>%
            ggplot(., aes(xvalue, Eigenvalues)) +
              geom_point() +
              theme_minimal() +
              geom_hline(yintercept = 10, linetype = "dashed", color = "red")
              
          ggsave("{output.seed_cmc_Varimax_ols_scree}", plot = seed_cmc_Varimax_ols_scree, device = "pdf",
            scale = 1, width = 10, height = 10, units = c("in"), dpi = 300)


          # get the minimum residual values into a datatable
          graphinfo <- as.data.frame(factor2cluster(seed_L4.decontam_cmc.fa))
          colnames(graphinfo) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          graphinfo <- graphinfo %>%
            rownames_to_column("Species") %>%
            as_tibble(.) 

          # now make loadings into a table and designate each species in the residual with the highest absolute value
          seed_L4.decontam_cmc.fa.df <- as.data.frame.matrix(seed_L4.decontam_cmc.fa$loadings)
          # b/c of rotation, the MRs may not be in numerial order. Change the column titles to be in numerical order for downstream processing
          colnames(seed_L4.decontam_cmc.fa.df) <- c("MR1","MR2","MR3","MR4","MR5","MR6")
          seed_L4.decontam_cmc.fa.df <- seed_L4.decontam_cmc.fa.df %>%
            as_tibble(.) %>%
            bind_cols(., graphinfo) %>%
            mutate(MR11 = as.character(MR11),
                   MR21 = as.character(MR21),
                   MR31 = as.character(MR31),
                   MR41 = as.character(MR41),
                   MR51 = as.character(MR51)) %>%
            mutate(MR11 = replace(MR11, MR11 != "0", "MR1"),
                   MR21 = replace(MR21, MR21 != "0", "MR2"),
                   MR31 = replace(MR31, MR31 != "0", "MR3"),
                   MR41 = replace(MR41, MR41 != "0", "MR4"),
                   MR51 = replace(MR51, MR51 != "0", "MR5")) %>%
           select(Species,everything(.)) %>%
           gather("Group","Residual", 7:ncol(.)) %>%
           filter(Residual != "0") %>%
           select(Residual, Species, MR1, MR2, MR3, MR4, MR5)
          
          fwrite(seed_L4.decontam_cmc.fa.df, file = "{output.cmc_Varimax_ols}", quote = F, sep = "\t")

       """)

