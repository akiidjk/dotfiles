#!/usr/bin/env python3
"""Clean URL: strips tracking parameters from a copied link.

Run by `wl-paste --type text --watch` (autostart.lua): the clipboard text arrives on stdin. Only a lone http(s) URL
is touched; when nothing changes the clipboard is left alone (so the rewrite does not trigger itself forever).
`clean-url.py --test` runs the self-check.
"""
import subprocess
import sys
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

DROP = {"fbclid", "gclid", "dclid", "gbraid", "wbraid", "msclkid", "mc_eid", "mc_cid", "igshid", "igsh", "ref_src",
        "ref_url", "_hsenc", "_hsmi", "mkt_tok", "yclid", "twclid", "ttclid", "si", "feature", "pp"}
# "si" / "feature" / "pp" are tracking only on these hosts (elsewhere they can be real parameters)
SHARE_HOSTS = ("youtube.com", "youtu.be", "spotify.com", "instagram.com")
SHARE_ONLY = {"si", "feature", "pp"}


def clean(text):
    url = text.strip()
    if not url.startswith(("http://", "https://")) or any(c.isspace() for c in url):
        return None
    p = urlsplit(url)
    if not p.query:
        return None
    host = p.hostname or ""
    share = host.endswith(SHARE_HOSTS)
    q = parse_qsl(p.query, keep_blank_values=True)
    keep = [(k, v) for k, v in q
            if not k.lower().startswith("utm_") and (k not in DROP or (k in SHARE_ONLY and not share))]
    if len(keep) == len(q):
        return None
    return urlunsplit(p._replace(query=urlencode(keep, doseq=True)))


def test():
    assert clean("https://a.com/x?utm_source=t&id=3") == "https://a.com/x?id=3"
    assert clean("https://a.com/x?fbclid=abc") == "https://a.com/x"
    assert clean("https://youtu.be/abc?si=XYZ&t=10") == "https://youtu.be/abc?t=10"
    assert clean("https://example.org/s?si=keep") is None          # si only dropped on share hosts
    assert clean("https://a.com/x?id=3") is None                    # nothing to do: no rewrite
    assert clean("hello https://a.com/?utm_x=1") is None             # not a lone URL
    assert clean("ftp://a.com/?utm_x=1") is None
    assert clean("https://a.com/x?utm_a=1#frag") == "https://a.com/x#frag"
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--test"]:
        test()
    else:
        out = clean(sys.stdin.read(8192))
        if out:
            subprocess.run(["wl-copy", out])
