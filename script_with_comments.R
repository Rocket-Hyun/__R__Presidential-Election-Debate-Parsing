html <- scan(file="data/대선토론2017.txt", what="char", sep="\n" ,quote=NULL, encoding = "UTF-8")
# 실제 발언과 관련된 부분만 파싱
# 실제로는 3번째 줄 부터 시작
debate_texts <- grep( '<p class="content_text">', html, value=T)
debate_texts <- debate_texts[3:length(debate_texts)]
# HTML 태그들 제거
debate_texts2 <- gsub('<p class=\"content_text\">', "", debate_texts)
debate_texts3 <- gsub('<br />', "", debate_texts2)
debate_cleaned_texts <- gsub('</p>', "", debate_texts3)
# 후보자의 이름 앞엔 ▲가 붙어있음 따라서 붙은 부분만 뽑기
candidate_parsing1 <- grep( "▲", debate_cleaned_texts, value=T)
# split으로 나누면 ▲가 사라지는데
# 중간에 1줄에 ▲가 2번나오는 경우가 있어서
# ▲를 ▲★로 바꾼다.
candidate_parsing1 <-gsub("▲", "▲★", candidate_parsing1)
# ▲를 기준으로 나눔
candidate_parsing2 <- unlist(strsplit(candidate_parsing1, "▲"))
# ▲를 기준으로 나누면 ▲이전의 html과 실제 연설문로 나눠짐 (뒷부분 html 처리 필요) 
# 이중 어떤 줄은 ▲가 2번나오는 경우가 있어서
# ★를 포함하고 있는 벡터만 뽑음
candidates_parsing3 <- candidate_parsing2[grep("★", candidate_parsing2)]
# =를 기준으로 왼쪽은 후보이름, 오른쪽은 연설문이 됨
# 일단 =를 기준으로 나누면 홀수파트가 후보명, 짝수파트가 연설문이됨
candidates_parsing4 <- unlist(strsplit(candidates_parsing3, "="))
# 홀수파트만 가져온다
candidates_parsing5 <- candidates_parsing4[seq(1, length(candidates_parsing4), by=2)]
# 사회자 부분에 ★와 space 가 들어가 있어서 제거한다
candidates_parsing6 <- gsub(" ", "", candidates_parsing5)
candidates_parsing7 <- gsub("★", "", candidates_parsing6)
# 중복 이름 제거
candidates <- unique(candidates_parsing7)
# 후보의 말이 다음 문장으로 끊어지는 부분은
# ▲|◇가 없는 부분임
# 이를 뽑아내서 lost_texts_index에 인덱스 값들을 저장
indexs <- 1:length(debate_cleaned_texts)
lost_texts_index <- setdiff(indexs, grep("▲|◇",debate_cleaned_texts))
# index 순서를 반대로 돌면서 바로 앞 index의 벡터 값에게
# 자기 값들을 append 함
# 이전 변수 값이 변하지 않게 다른 변수에 넣어둠
debate_full_texts <- debate_cleaned_texts
for(i in rev(lost_texts_index)){
  debate_full_texts[i-1] <- paste(debate_full_texts[i-1], debate_full_texts[i], sep="")
}
final_texts <- grep("▲", debate_full_texts, value=T)
final_texts2 <- unlist(strsplit(final_texts, "▲"))
# 실제 대본들만 뽑음
final_texts3 <- grep("= ", final_texts2, value=T)
# 답들을 담을 폴더 만들기
dir.create(file.path("answer"), showWarnings = FALSE)
for(person in candidates) {
  ques_text = c(" ?= ")
  candidate_catcher = paste(person, ques_text, sep="")
  you <- grep(candidate_catcher,final_texts3, value=T)
  you_only_texts <- unlist(strsplit(you, "= "))[seq(2,length(unlist(strsplit(you, "= "))),by=2)]
  # .으로 나눌껀데 .이 없어지므로 .이 있는 곳엔 .★로 만들고 ★를 기준으로 나눔
  # ?도 같은 원리
  you_dot_escape <- gsub("[.][^’1-9]", ".★",you_only_texts)
  you_ques_escape <- gsub("[?][^)]", "?☆",you_dot_escape)
  you_dot_split <- unlist(strsplit(you_ques_escape, "★"))
  you_ques_split <- unlist(strsplit(you_dot_split, "☆"))
  # 앞뒤 balnk 제거
  you_texts_blank_remove <- gsub("^ *", "", you_ques_split)
  final_answer <- gsub(" *$", "", you_texts_blank_remove)
  cat(final_answer, file=paste(c("answer/"), person, c(".txt"), sep=""), sep="\n")
}
