html <- scan(file="data/대선토론2017.txt", what="char", sep="\n" ,quote=NULL, encoding = "UTF-8")
script_html <- grep("<p class=\"content_text\">", html, value=T)

# 후보자 / 사회자 이름만 파싱하기
script_html_stars <- gsub("▲", "▲★", script_html)
script_split <- unlist(strsplit(script_html_stars, "▲"))
only_script_html <- grep("★", script_split, value=T)
name_script_split <- unlist(strsplit(only_script_html, "="))
only_name_star <- name_script_split[seq(1, length(name_script_split), by=2)]
only_name_blank_back <- gsub("★ *", "" ,only_name_star)
only_name <- gsub(" +", "", only_name_blank_back)
candidates <- unique(only_name)
head(candidates)

# 후보자를 잃은 텍스트를 합치기
lost_texts_index <- setdiff(1:length(script_html),grep("[▲◇]",script_html))
lost_texts_index <- lost_texts_index[3:length(lost_texts_index)]
fixed_script_html <- script_html
for (i in rev(lost_texts_index)) {
  fixed_script_html[i-1] <- paste(fixed_script_html[i-1], fixed_script_html[i], sep="" )
}
head(fixed_script_html)
split_by_tri <- unlist(strsplit(gsub("▲","▲★",fixed_script_html),"▲"))
cleaned_script <- grep("★", gsub(" *<(.|\n)*?> *","", split_by_tri), value=T)
cleaned_script
head(cleaned_script)
grep("유승민 ?= ",cleaned_script, value=T)[109]
#여기까지 해봤


dir.create(file.path("newanswer"), showWarnings = FALSE)
for(person in candidates) {
  ques_text = c(" ?= ")
  candidate_catcher = paste(person, ques_text, sep="")
  you <- grep(candidate_catcher,cleaned_script, value=T)
  you_only_texts <- unlist(strsplit(you, "= "))[seq(2,length(unlist(strsplit(you, "= "))),by=2)]
  you_dot_escape <- gsub("[.][^’1-9]", ".★",you_only_texts)
  you_ques_escape <- gsub("[?][^)]", "?☆",you_dot_escape)
  you_dot_split <- unlist(strsplit(you_ques_escape, "★"))
  you_ques_split <- unlist(strsplit(you_dot_split, "☆"))
  you_texts_blank_remove <- gsub("^ *", "", you_ques_split)
  final_answer <- gsub(" *$", "", you_texts_blank_remove)
  cat(final_answer, file=paste(c("newanswer/"), person, c(".txt"), sep=""), sep="\n")
}
