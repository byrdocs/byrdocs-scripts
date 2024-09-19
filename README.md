# byrdocs-scripts

- [organize.sh](organize.sh) - 一键整理（单个）文件。支持文档检视、封面生成、重命名和分类功能。
- [extract-cover.sh](extract-cover.sh) - 从 pdf 中提取封面
- [edit-book-cover.sh](edit-book-cover.sh) - 改变电子书的封面
- [isbn-10-to-13.sh](isbn-10-to-13.sh) - 计算 ISBN-10 转 ISBN-13 的结果
- [.copy-scripts.sh](.copy-scripts.sh) - 将本目录中的指定脚本移入 stockpile 目录中
- [remove-duplicate.sh](remove-duplicate.sh) - 移除具有相同 MD5 码的文件
- [clean.sh](clean.sh) - 清理所有符合特定 pattern 的文件

## `.conf` 文件

如果你需要在本地运行这些脚本，请先编写两个 `.conf` 文件。以下是示例，您可根据自己的需要加以调整。

```bash config
# .config.conf
BYRDOCS_DIR="${HOME}/BYRDOCS/resources"
STOCKPILE_DIR="${HOME}/BYRDOCS/stockpile"
COVERS_DIR="${BYRDOCS_DIR}/covers"
BOOKS_DIR="${BYRDOCS_DIR}/books"
TESTS_DIR="${BYRDOCS_DIR}/tests"
DOCS_DIR="${BYRDOCS_DIR}/docs"
GENERATE_JPG="1"
GENERATE_PNG="0"
GENERATE_WEBP="1"
PDF_VIEWER="evince"
ZIP_VIEWER="ark"
```

### `magick-exception` 文件

`magick`指令可能无法用于某些大文件。你可以把它加入到排除列表中，从而避免引起故障。以下是示例。

```bash config
MAGICK_EXCEPTION=("610f8620aac14b1653849f1a6245f714")
```
