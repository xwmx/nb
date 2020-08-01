# `nb` Markdown Bookmark File Format

## Extension

`.bookmark.md`

## Description

`nb` bookmarks are Markdown documents created using a combination of
user input and data from the bookmarked page.

Bookmarks are identified by a `.bookmark.md` file extension. The
bookmark URL is the first URL in the file within `<` and `>` characters.
To create a minimal valid bookmark file with `nb add`:

```bash
nb add example.bookmark.md --content "<https://example.com>"
```

This creates a file with the name `example.bookmark.md` containing:

```markdown
<https://example.com>
```

## Example

```markdown
# Example Domain (example.com)

<https://example.com>

## Description

Example meta description.

## Quote

> Example quote line one.
>
> Example quote line two.

## Comment

Example comment.

## Tags

#tag1 #tag2

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information\...](https://www.iana.org/domains/example)
```

## Elements

### Title

`Optional`

A markdown `h1` element consisting of the content of the `<title>` of
the bookmarked HTML page, if present, and the domain in parenthesis.

```markdown
# Example Domain (example.com)
```

### URL

`Required`

The URL of the bookmarked resource, with surrounding angle brackets
(`<` / `>`).

This is the only required element.

### Description

`Optional`

A text element containing the content of the bookmarked page's meta description
tag if present.

### Quote

`Optional`

A markdown quote element containing an excerpt from the bookmarked
resource.

### Comment

`Optional`

A text element containing a comment written by the user.

### Tags

`Optional`

A list of tags represented as hashtags.

### Content

`Optional`

The full content of the bookmarked page, converted to Markdown.

### Content (HTML)

`Optional`

The full content of the bookmarked page in raw HTML.
