dir <- c("[YOUR_PATH]")
setwd("dir")

library(tidyverse)
library(quanteda)
library(readtext)

# source of debate: http://dipbt.bundestag.de/doc/btp/19/19074.pdf
# debate saved as .txt and encoding converted to UTF-8 
# speakers tagged with ##"NAME" (actual), also ##CHAIR and ##QUESTION -> sometimes speech interrupted 
df_brexit <- readtext("bundestag_19074_brexit_speakers.txt",encoding="UTF-8")

# remove everything in brackets 
x <- df_brexit$text
x_sub <- gsub( " *\\(.*?\\) *", "", x)
brexit_sub <- x_sub 

# remove hyphens
brexit_sub_hyphens <- tokens(brexit_sub, remove_hyphens=TRUE)

# create a corpus 
corpus_brexit <- corpus(brexit_sub)
summary(corpus_brexit)

# Split up speech into speakers using tags 
corp_seg <- corpus_segment(corpus_brexit, pattern = "##*")
summary(corp_seg)

# remove comments by speaker of house / name of speechgiver via tags  
corp_rupt <-  corpus_subset(corp_seg, pattern!="##CHAIR"&pattern!="##QUESTION")
summary(corp_rupt)

# docvars - id
docvars(corp_rupt, "id") <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
docvars(corp_rupt)

# merge interrupted speaker texts 
maas <- corpus_subset(corp_rupt, pattern=="##MAAS")
hebner <- corpus_subset(corp_rupt, pattern=="##HEBNER")
leikert <- corpus_subset(corp_rupt, pattern=="##LEIKERT")
lambsdorff <- corpus_subset(corp_rupt, pattern=="##LAMBSDORFF")
dehm <- corpus_subset(corp_rupt, pattern=="##DEHM")
brantner1 <- corpus_subset(corp_rupt, id==6)
brantner2 <- corpus_subset(corp_rupt, id==7)
brantner <- corpus(paste(texts(brantner1),texts(brantner2)))
töns1 <- corpus_subset(corp_rupt, id==8)
töns2 <- corpus_subset(corp_rupt, id==9)
töns <- corpus(paste(texts(töns1),texts(töns2)))
weyel <- corpus_subset(corp_rupt, pattern=="##WEYEL")
hahn <- corpus_subset(corp_rupt, pattern=="##HAHN")
hacker <- corpus_subset(corp_rupt, pattern=="##HACKER")
seif <- corpus_subset(corp_rupt, pattern=="##SEIF")
hirte <- corpus_subset(corp_rupt, pattern=="##HIRTE")

# back to a corpus 
corp_speakers <- corpus(c(maas,hebner,leikert,lambsdorff,dehm,brantner,töns,weyel,hahn,hacker,seif,hirte))
summary(corp_speakers)
summary(tokens(corp_speakers))

# number of sentences / words 
summary(nsentence(corp_speakers))
summary(ntoken(corp_speakers))

# docvars 
docvars(corp_speakers, "speaker") <- c("Maas","Hebner","Leikert","Lambsdorff","Dehm","Brantner","Töns","Weyel","Hahn","Hacker","Seif","Hirte")
docvars(corp_speakers, "id") <- c(1,2,3,4,5,6,7,8,9,10,11,12)
docvars(corp_speakers, "afd") <- c("Andere","AfD","Andere","Andere","Andere","Andere","Andere","AfD","Andere","Andere","Andere","Andere")
docvars(corp_speakers, "party") <- c("SPD","AfD","CDU/CSU","FDP","Linke","Grüne","SPD","AfD","CDU/CSU","FDP","CDU/CSU","CDU/CSU")
docvars(corp_speakers)

# word cloud improved 
set.seed(10)
brexit_dfm <- dfm(corp_speakers, remove = c(stopwords("german"),"dass","000","90", "herr*", "damen", "kolleg*"), remove_punct = TRUE) %>%
  dfm_trim(min_termfreq = 3)

# comparison plots, grouped 
# afd vs. rest 
afd_rest_dfm <- 
  dfm(corpus_subset(corp_speakers, afd %in% c("AfD", "Andere")),
      remove = c(stopwords("german"),"dass","000","90", "herr*", "damen", "kolleg*"), remove_punct = TRUE, groups = "afd") %>%
  dfm_trim(min_termfreq = 3)

textplot_wordcloud(afd_rest_dfm, comparison = TRUE, max_words = 100,
                   color = c("blue", "red"))

# parties 
parties_dfm <- 
  dfm(corp_speakers,
      remove = c(stopwords("german"),"dass","000","90"), remove_punct = TRUE, groups = "party") %>%
  dfm_trim(min_termfreq = 2)

textplot_wordcloud(parties_dfm, comparison = TRUE, max_words = 180,
                   color = c("blue","black","orange","green","purple","red"))

# topfeatures by party  
docvars(brexit_dfm)
topfeatures(brexit_dfm, n = 7, groups="party")

# plot relative frequencies by group
wfreq_dfm <- brexit_dfm %>%
  dfm_group(groups = "party") %>%
  dfm_weight(scheme = "prop")
# calculate relative frequency by party
relfreq <- textstat_frequency(wfreq_dfm, n = 10,
                             groups = "party")
# plot frequencies
ggplot(data = relfreq, aes(x = nrow(relfreq):1, y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_continuous(breaks = nrow(relfreq):1,
                     labels = relfreq$feature) +
  labs(x = NULL, y = "Relative Häufigkeit")

# kwic()
kwic(corp_speakers, "control", window = 10)
kwic(corp_speakers, "corbyn", window = 10)
kwic(corp_speakers, "briten", window = 10)
kwic(corp_speakers, "EU-Kommissare", window = 20)
kwic(corp_speakers, "deutschen", window = 10)

# wordfish 
fish <- textmodel_wordfish(parties_dfm, dir = c(1,2)) 
summary(fish)

