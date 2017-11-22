###
# Matching for 2008 presidential election survey.
###


# =============================================================================
#   V083097    J1. Party ID: Does R think of self as Dem, Rep, Ind or what
# =============================================================================
#   
#   PRE-ELECTION SURVEY
# 
# -----------------------------------------------------------------
#   Generally speaking, do you usually think of yourself as a 
# [DEMOCRAT, a REPUBLICAN / a REPUBLICAN, a DEMOCRAT], an 
# INDEPENDENT, or what?
# -----------------------------------------------------------------
#   
#   VALID CODES:
#   -----------
# 1. Democrat
# 2. Republican
# 3. Independent
# 4. Other party (SPECIFY)
# 5. No preference {VOL}
# 
# MISSING CODES:
#   -------------
#   -8. Don't know
# -9. Refused
# 
# REFERENCE:
# ---------
# PreRandom.20. (order of parties in text of party id)
# 
# NOTES:
# -----
# The order of the major parties in the question text of 
# party ID question J1 was randomized, as documented in
# PreRandom.20.
# 
# TYPE:
# ----
# Numeric   

# weights <- fread('weights.csv')
# master <- fread('master.csv')
# master <- transform(master, V2 = as.numeric(V2))
# res <- merge(master, weights, by.x = "V2", by.y = "V1")
# fwrite(res,'res.csv')
# res <- fread('res.csv')
# rel <- fread('id_age_party.csv')
# colnames(rel) <- c("na","case_id","age","party")
# hey <- merge(rel, res, by='case_id')
# hey <- hey[,-c('na')]
# fwrite(hey, 'master_survey.csv')


setwd('/Users/kojin/projects/doc2vec')
library('data.table')
library('Matching')
require(reshape2)

df <- fread('master_survey.csv')
df$age_treat <- df$age > 40
sum( df$age > 40)
df <- df[df$party %in% c(1,2)]
df$party <- as.factor(df$party)
match <- Match(Y=df$party,Tr=df$age_treat,X=df[,-c('case_id','age','party','response')])
df[match$index.treated]$response
df[match$index.control]$response

matches <- melt(data.frame(df[match$index.treated]$response,df[match$index.control]$response))
fwrite(matches,'matches.csv')
match$est
match$se.standard
match$se
lm(party ~ age_treat, data=df)

# match in a couple of different ways
# move the cutpoint to make 200 under cutoff -> treat (one-to-one)
# causal efffect on the treated controlling for opinions about 911
# let's look at the lined up 
# 
