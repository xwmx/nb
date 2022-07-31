#!/usr/bin/env bats

load test_helper

# import bookmarks ############################################################

@test "'import bookmarks <path>' imports chrome bookmarks." {
  {
    "${_NB}" init

    {
      cat "${NB_TEST_BASE_PATH}/fixtures/example-chrome-bookmarks.html"
    } | {
      sed                                                                                     \
        -e "s|https://example.com\/|file://${NB_TEST_BASE_PATH}/fixtures/example.com.html|g"  \
        -e "s|https://example.org\/|file://${NB_TEST_BASE_PATH}/fixtures/example.org.html|g"  \
        -e "s|https://example.net\/|file://${NB_TEST_BASE_PATH}/fixtures/example.net.html|g"  \
        -e "s|https://example.edu\/|file://${NB_TEST_BASE_PATH}/fixtures/example.edu.html|g"
    } | {
      cat > "${_TMP_DIR}/example-chome-bookmarks-local.html"
    }
  }

  run "${_NB}" import bookmarks \
    "${_TMP_DIR}/example-chome-bookmarks-local.html"
    # "${NB_TEST_BASE_PATH}/fixtures/example-chrome-bookmarks.html"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # cat "${NB_DIR}/home/toolbar/20220731115400.bookmark.md"

  [[ "${status}"    -eq 0 ]]

  [[ "${#lines[@]}" -eq 8 ]]

  [[ "${lines[0]}"  =~ \
Added:\ .*[.*toolbar/1.*].*\ 🔖\ .*toolbar/20220731115400\.bookmark\.md.*\ \"Example\ Com\" ]]

  [[ "${lines[1]}"  =~ \
Added:\ .*[.*toolbar/Example\ Bookmark\ Folder/Example\ Nested\ Folder/1.*].*\ 🔖\                                ]]
  [[ "${lines[1]}"  =~ \
🔖\ .*toolbar/Example\ Bookmark\ Folder/Example\ Nested\ Folder/20220731115404\.bookmark\.md.*\ \"Example\ Org\"  ]]

  [[ "${lines[2]}"  =~ \
Added:\ .*[.*toolbar/Example\ Bookmark\ Folder/1.*].*\ 🔖\                                  ]]
  [[ "${lines[2]}"  =~ \
🔖\ .*toolbar/Example\ Bookmark\ Folder/20220731115402\.bookmark\.md.*\ \"Example\ Net\"    ]]

  [[ "${lines[3]}"  =~ \
Added:\ .*[.*toolbar/3.*].*\ 🔖\ .*toolbar/20220731115602\.bookmark\.md.*\ \"Example\ Edu\" ]]
  [[ "${lines[4]}"  =~ \
Added:\ .*[.*2.*].*\ 🔖\ .*20220731120230\.bookmark\.md.*\ \"Example\ Org\ Other\"          ]]
  [[ "${lines[5]}"  =~ \
Added:\ .*[.*3.*].*\ 🔖\ .*20220731120235\.bookmark\.md.*\ \"Example\ Net\ Other\"          ]]

  [[ "${lines[6]}"  =~ \
Added:\ .*[.*Example\ Folder\ Other/1.*].*\ 🔖\                                             ]]
  [[ "${lines[6]}"  =~ \
🔖\ .*Example\ Folder\ Other/20220731120222\.bookmark\.md.*\ \"Example\ Edu\ Other\"        ]]

  [[ "${lines[7]}"  =~ \
Added:\ .*[.*Example\ Folder\ Other/Example\ Nested\ Folder\ Other/1.*].*\ 🔖\                                      ]]
  [[ "${lines[7]}"  =~ \
🔖\ .*Example\ Folder\ Other/Example\ Nested\ Folder\ Other/20220731120214\.bookmark\.md.*\ \"Example\ Com\ Other\" ]]

  # Adds files.

  [[ -e "${NB_DIR}/home/toolbar/20220731115400.bookmark.md"                                               ]]
  [[ -e "${NB_DIR}/home/toolbar/Example Bookmark Folder/Example Nested Folder/20220731115404.bookmark.md" ]]
  [[ -e "${NB_DIR}/home/toolbar/Example Bookmark Folder/20220731115402.bookmark.md"                       ]]
  [[ -e "${NB_DIR}/home/toolbar/20220731115602.bookmark.md"                                               ]]
  [[ -e "${NB_DIR}/home/20220731120230.bookmark.md"                                                       ]]
  [[ -e "${NB_DIR}/home/20220731120235.bookmark.md"                                                       ]]
  [[ -e "${NB_DIR}/home/Example Folder Other/20220731120222.bookmark.md"                                  ]]
  [[ -e "${NB_DIR}/home/Example Folder Other/Example Nested Folder Other/20220731120214.bookmark.md"      ]]

  diff                                                          \
    <(cat "${NB_DIR}/home/toolbar/20220731115400.bookmark.md")  \
    <(cat << HEREDOC
# Example Com

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

# Example Domain

This domain is for use in illustrative examples in documents. You may use this
domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)
HEREDOC
    )

  diff                                                                                                  \
    <(cat "${NB_DIR}/home/Example Folder Other/Example Nested Folder Other/20220731120214.bookmark.md") \
    <(cat << HEREDOC
# Example Com Other

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html#example>

## Description

Example description.

## Content

# Example Domain

This domain is for use in illustrative examples in documents. You may use this
domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)
HEREDOC
    )

  # Adds to index.

  [[ -e "${NB_DIR}/home/.index"                               ]]

  diff                                                        \
    <(ls -t -r "${NB_DIR}/home")                              \
    <(cat "${NB_DIR}/home/.index")

  # Creates git commit.

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done

  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'
}
