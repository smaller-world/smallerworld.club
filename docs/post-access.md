# Post access

Anyone with a copied secret link can open an unsuppressed post, including a
signed-out visitor or a friend excluded from the feed. The
[moderation decision](adr/0001-pending-reports-suppress-their-reportable.md)
defines when a report suppresses content on the linked page.

Revoking a key ends access granted by that key on subsequent requests.
Previously loaded posts can remain visible in a page already open.

## World feeds

A friend needs a current key to the post's world and either a selected key type
or an individual inclusion. An individual exclusion wins. Pending or upheld
reports hide the post from friends. Authors can still see their posts. The
copied-link behavior above still applies.

The cutover preserves historical audiences through individual inclusions derived
from legacy grants. Owners can also share historical posts with the key types
their world has when they confirm in the walkthrough.

Post saves filter the three recipient lists to key types and current key holders
in the world. Revoking a key leaves individual exceptions on existing posts
until an edit saves the post while the key is absent. If the friend rejoins
first, those exceptions take effect again. Favoriting preserves them.

See the [key types plan](the-key-types-update.md) for the work still pending
before deploy.
