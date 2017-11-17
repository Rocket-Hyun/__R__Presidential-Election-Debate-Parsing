html <- scan(file="data/대선토론2017.txt", what="char", sep="\n" ,quote=NULL, encoding = "UTF-8")
debate_texts <- grep( '<p class="content_text">', html, value=T)
debate_texts <- debate_texts[3:length(debate_texts)]
debate_texts2 <- gsub('<p class=\"content_text\">', "", debate_texts)
debate_texts3 <- gsub('<br />', "", debate_texts2)
debate_cleaned_texts <- gsub('</p>', "", debate_texts3)
candidate_parsing1 <- grep( "▲", debate_cleaned_texts, value=T)
candidate_parsing1 <-gsub("▲", "▲★", candidate_parsing1)
candidate_parsing2 <- unlist(strsplit(candidate_parsing1, "▲"))
candidates_parsing3 <- candidate_parsing2[grep("★", candidate_parsing2)]
candidates_parsing4 <- unlist(strsplit(candidates_parsing3, "="))
candidates_parsing5 <- candidates_parsing4[seq(1, length(candidates_parsing4), by=2)]
candidates_parsing6 <- gsub(" ", "", candidates_parsing5)
candidates_parsing7 <- gsub("★", "", candidates_parsing6)
candidates <- unique(candidates_parsing7)
indexs <- 1:length(debate_cleaned_texts)
lost_texts_index <- setdiff(indexs, grep("▲|◇",debate_cleaned_texts))
debate_full_texts <- debate_cleaned_texts
for(i in rev(lost_texts_index)){
  debate_full_texts[i-1] <- paste(debate_full_texts[i-1], debate_full_texts[i], sep="")
}
final_texts <- grep("▲", debate_full_texts, value=T)
final_texts2 <- unlist(strsplit(final_texts, "▲"))
final_texts3 <- grep("= ", final_texts2, value=T)
dir.create(file.path("answer"), showWarnings = FALSE)
for(person in candidates) {
  ques_text = c(" ?= ")
  candidate_catcher = paste(person, ques_text, sep="")
  you <- grep(candidate_catcher,final_texts3, value=T)
  you_only_texts <- unlist(strsplit(you, "= "))[seq(2,length(unlist(strsplit(you, "= "))),by=2)]
  you_dot_escape <- gsub("[.][^’1-9]", ".★",you_only_texts)
  you_ques_escape <- gsub("[?][^)]", "?☆",you_dot_escape)
  you_dot_split <- unlist(strsplit(you_ques_escape, "★"))
  you_ques_split <- unlist(strsplit(you_dot_split, "☆"))
  you_texts_blank_remove <- gsub("^ *", "", you_ques_split)
  final_answer <- gsub(" *$", "", you_texts_blank_remove)
  cat(final_answer, file=paste(c("answer/"), person, c(".txt"), sep=""), sep="\n")
}
