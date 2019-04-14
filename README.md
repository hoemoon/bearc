## bearc
: 태그를 이용해 베어에서 노트들을 추출하는 커맨드라인 프로그램

```bash
# 해당 태그를 가진 노트들을 입력한 위치에 마크다운 형태로 가져오기
bearc --outputPath path/to/directory --tags "public, press"
bearc --outputPath . --tags public
bearc -o path/to/directory -t "public, press"
```

### install
```bash
make build
make install
```