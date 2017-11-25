###
# Matching for 2016 presidential election survey.
###

# ------------------------------------------------------------------------------
# ---------------------------------------------------------------------------
#   V162007
# POST: Did party contact R about 2016 campaign
# ------------------------------------------------------------------------------
# ---------------------------------------------------------------------------
#   type: numeric (float)
# label: V162007
# range: [-9,2] units: 1
# unique values: 5 missing .: 0/4271
# tabulation: Freq. Numeric Label
# 3 -9 -9. Refused
# 86 -7 -7. No post data, deleted due to
# incomplete IW
# 536 -6 -6. No post-election interview
# 1178 1 1. Yes
# 2468 2 2. No
# -------------------------------------------------------------------------
# 
# ------------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# V162008
# POST: Did anyone other than parties contact R about cands ------------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# type: numeric (float)
# label: V162008
# range: [-8,2] units: 1
# unique values: 5 missing .: 0/4271
# tabulation: Freq. Numeric Label
# 1 -8 -8. Don't know
# 86 -7 -7. No post data, deleted due to
# incomplete IW
# 536 -6 -6. No post-election interview
# 467 1 1. Yes
# 3181 2 2. No
# 
# ------------------------------------------------------------------------------
#   ---------------------------------------------------------------------------
#   V162062x
# 2016 PRE-POST VOTE SUMMARY: 2016 Presidential vote
# ------------------------------------------------------------------------------
#   ---------------------------------------------------------------------------
#   type: numeric (float)
# label: V162062x, but 1 nonmissing value is not labeled
# range: [-9,5] units: 1
# unique values: 8 missing .: 0/4271
# tabulation: Freq. Numeric Label
# 31 -9 -9. Refused
# 2 -8 -8. Don't know (FTF only)
# 1427 -1
# 1364 1 1. Hillary Clinton
# 1245 2 2. Donald Trump
# 118 3 3. Gary Johnson
# 32 4 4. Jill Stein
# 52 5 5. Other candidate SPECIFY
# ------------------------------------------------------------------------------


setwd('/Users/kojin/projects/doc2vec/2016_survey')
library('Matching')
require(reshape2)

df <- read.csv('data/selected_survey.csv')

# throw away those those with turnout data unavailable
df <- df[df$turnout >= -1,]

# convert columns to factors
cols <- c('did_party_contact','did_others_contact','turnout')
df[cols] <- lapply(df[cols], factor)

# plot columns histograms
par(mfrow=c(2,2))
barplot(prop.table(table(df$did_party_contact)),main='did_party_contact')
barplot(prop.table(table(df$did_others_contact)),main='did_others_contact')
barplot(prop.table(table(df$turnout)),main='turnout')
barplot(prop.table(table(factor(paste(df$did_party_contact, df$did_others_contact, sep=':')))),main='party:others')

###
#common
###
non_cov_cols   <- c('id','did_party_contact','did_others_contact','turnout','concat_text','treatment','response')
df$turnout_bin <- df$turnout != -1

find_match <- function(response,treatment,covariates,sub_df,output_fname) {
  match <- Match(Y=response,Tr=treatment,X=covariates)
  matches <- data.frame(sub_df[match$index.treated,]$concat_text,sub_df[match$index.control,]$concat_text)
  fwrite(matches,output_fname)
  cat('Causal Effect:',match$est,'\n')
  cat('Standard Error:',match$se.standard,'\n')
  summary(lm(response ~ treatment, data=df))
}

#################
# 1) contact by party as treatment
#################
sub_df     <- df[df$did_party_contact %in% c(1,2),]
treatment  <- sub_df$did_party_contact == 1
sum(treatment)/length(treatment)
response   <- sub_df$turnout_bin
covariates <- sub_df[,!names(sub_df) %in% non_cov_cols]
find_match(response,treatment,covariates,sub_df,'data/party_contact_matches.csv')

#################
# 2) contact by others as treatment
#################
sub_df     <- df[df$did_others_contact %in% c(1,2),]
treatment  <- sub_df$did_others_contact == 1
sum(treatment)/length(treatment)
response   <- sub_df$turnout_bin
covariates <- sub_df[,!names(sub_df) %in% non_cov_cols]
find_match(response,treatment,covariates,sub_df,'data/others_contact_matches.csv')

#################
# 3) contacted by either party or others as treatment
#################
sub_df     <- df[(df$did_party_contact %in% c(1,2)) & (df$did_others_contact %in% c(1,2)),]
treatment  <- sub_df$did_party_contact == 1 | sub_df$did_others_contact == 1
sum(treatment)/length(treatment)
response   <- sub_df$turnout_bin
covariates <- sub_df[,!names(sub_df) %in% non_cov_cols]
find_match(response,treatment,covariates,sub_df,'data/party_or_others_contact_matches.csv')

