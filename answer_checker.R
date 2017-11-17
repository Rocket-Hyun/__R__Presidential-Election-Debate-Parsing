
for(i in candidates) {
  answer <- scan(file=paste(c("data/정답텍스트/"), i, c(".txt"), sep=""), what="char", sep="\n" ,quote=NULL)
  myanswer <- scan(file=paste(c("answer/"), i, c(".txt"), sep=""), what="char", sep="\n" ,quote=NULL)
  print(i)
  print(which( answer != myanswer ))
}
