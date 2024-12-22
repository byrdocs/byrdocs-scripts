# byrdocs-scripts

- [extract-single-cover.sh](extract-single-cover.sh) - 从 pdf 中提取封面
- [edit-book-cover.sh](edit-book-cover.sh) - 改变电子书的封面

## 关于 extract-single-cover.sh

你可以使用 `extract-single-cover.sh` 来从 PDF 中提取第一页内容作为封面。举例来说：

```shell
./extract-single-cover.sh tmp.pdf ./image
```

将会在 `.image` 中建立一个 JPG 和一个 WEBP 文件。
