import filecmp
candidates = ["문재인","사회자","심상정","안철수","유승민","홍준표"]

for i in candidates:
    print(i)
    print(filecmp.cmp("answer/" + i + ".txt", "data/정답텍스트/" + i + ".txt"))
