# Post access

A friend's world feed follows their key's post-type grants and the author's
recipient selection for each post.

Anyone with a copied secret link can open an unsuppressed post, including a
signed-out visitor or a friend excluded from the feed. The
[moderation decision](adr/0001-pending-reports-suppress-their-reportable.md)
defines when a report suppresses content on the linked page.

Revoking a key ends access granted by that key on subsequent requests.
Previously loaded posts can remain visible in a page already open.
