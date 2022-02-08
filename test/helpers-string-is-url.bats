#!/usr/bin/env bats

load test_helper

@test "'_string_is_url()' matches URLs." {
  run "${_NB}" helpers string_is_url "aaa://host.example.com:1813;transport=udp;protocol=radius"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "aaas://host.example.com:1813;transport=udp;protocol=radius"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "acap://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "adiumxtra://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "afp://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "afp:/at/example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "aim:example?parameters"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "apt:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "attachment:/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "aw://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "amss:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "barion:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "beshare://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "bitcoin:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "bolo://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "callto:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "chrome://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "chrome-extension://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "cid:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "coap://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "coaps://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "content://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "crid://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "cvs://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "dab:123.456.789.0"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "data:text/vnd-example+xyz;foo=bar;base64,R0lGODdh"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "dict://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "dns://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "dns:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "drm:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ed2k://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "facetime://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "fax:15555555555"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "feed://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "feed:http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "feed:https://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "file:///home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "finger:///home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "fish:///home/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "fm:123.456.789"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ftp://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "geo:123.456,987.654"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "gg:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "git://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "gizmoproject://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "go://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "go:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "gopher://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "gtalk:chat?jid=example@gmail.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "h323://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "https://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "iax:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "im:example@sample"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "imap://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "irc://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "irc6://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ircs://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "itms:"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "jar:example!/sample"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "keyparc://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "lastfm://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ldap://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ldaps://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "magnet:?xt=urn:sha1:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "mailto:example@example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "maps:q=example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "market://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "message://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "message:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "mid:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "mms://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ms-help://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "msnim:add?contact=sample@example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "mumble://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "mvn:org.example/service/0.2.0-SNAPSHOT"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "mvn:http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "mvn:https://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "news:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ni://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "nntp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notes://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "openpgp4fpr:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "palm:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "paparazzi:http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "payto://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "platform:/example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "pop://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "pres:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "proxy:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "psyc:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "query:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "reload://sample@example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "res://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "resource://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "rmi://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "rsync://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "rtmfp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "rtmp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "s3://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "secondlife://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "session:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sftp://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sgn://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sip://sample@example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sips://sample@example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "skype:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "smb://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "sms:+15105550101"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "snmp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "soldat://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "spotify:search:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ssh://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "steam://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "stun:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "stuns:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "svn://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "svn+ssh://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "tag:example.com,2222:1234"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "teamspeak://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "tel:+15105550101"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "telnet://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "things://example?sample"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "turn:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "turns:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "udp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "unreal://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "urn:sample:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ut2004://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ventrilo://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "view-source:http://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "view-source:https://example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "vnc://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "wais://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "webcal://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "ws:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "wtai://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "wyciwyg://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "xfire:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "xmpp://sample@example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "xri://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "ymsgr:sendIM?example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "z39.50r://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "z39.50s://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "admin://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "app://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "doi:10.1000/182"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  # run "${_NB}" helpers string_is_url "javascript:example"

  # printf "\${status}: '%s'\\n" "${status}"
  # printf "\${output}: '%s'\\n" "${output}"

  # [[      "${status}" -eq 0 ]]
  # [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "jdbc:example:sample"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "stratum+tcp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "stratum+udp://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "web-example://sample"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "zoommtg://zoom.us/join?confno=123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "zoomus://example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 0 ]]
  [[  -z  "${output}"       ]]
}

###############################################################################

@test "'_string_is_url()' doesn't match non-URLs." {
  run "${_NB}" helpers string_is_url "aim"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "aim:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "aim:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "attachment:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "data:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "data:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "data:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "fm:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "fm:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "fm:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "geo:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "geo:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "geo:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "im:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "im:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "im:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "Not a URL."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "not-a-url"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notaurl:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notes:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "notebook:example/123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "platform:123"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "spotify:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "spotify:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "urn:"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]

  run "${_NB}" helpers string_is_url "urn:example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[      "${status}" -eq 1 ]]
  [[  -z  "${output}"       ]]
}
