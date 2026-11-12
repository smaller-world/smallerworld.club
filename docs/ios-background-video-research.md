# iOS background video: research findings

Investigated 2026-11-12. No device reproduction or application changes were
made.

## Evidence and limits

The supplied traces show a real clock freeze despite `playing`, fulfilled
`play()`, `paused: false`, and sufficient buffered data. A later manual
pause/play recovered twice. They do not establish that an immediate foreground
pause/play works, or that Low Power Mode caused the failure.

The closest public report found is
[WebKit 301484](https://bugs.webkit.org/show_bug.cgi?id=301484): after reopening
an iOS Home Screen app, `play()` fulfills and `playing` fires, while
`currentTime` and decoded-frame counts remain unchanged. It was marked duplicate
of [300990](https://bugs.webkit.org/show_bug.cgi?id=300990), then
[295518](https://bugs.webkit.org/show_bug.cgi?id=295518). These reports concern
iOS 26 PWAs, not the reported iOS 18.7 Hotwire Native WKWebView. They
demonstrate the same observable inconsistency, not the same proven root cause.
Comment 9 on 300990 says fixed in iOS 26.2; the master issue still displays NEW.
That statement is not evidence of a fix for this application's failure.

[WebKit 263627](https://bugs.webkit.org/show_bug.cgi?id=263627) reports an
AudioContext marked running with a stationary clock after foregrounding,
recoverable by suspend/resume. This is an analogy in a different API, not a
video diagnosis. [230922](https://bugs.webkit.org/show_bug.cgi?id=230922)
concerns MediaStream video freezing on iOS 15; its different source pipeline
also prevents treating it as a match.

[WebKit 219889 comment 4](https://bugs.webkit.org/show_bug.cgi?id=219889#c4)
documents Low Power Mode disabling autoplay. This establishes a policy effect,
but does not explain successful play promises and later gesture-free recovery.

## Public signal boundary

The
[HTML media algorithms](https://html.spec.whatwg.org/multipage/media.html#playing-the-media-resource)
describe state transitions and playing notification; they do not provide an
independent continuous decoder-health guarantee. Likewise the
[video frame callback proposal](https://wicg.github.io/video-rvfc/) reports
positive frame delivery. If no callback arrives, there is no negative callback
that can itself trigger recovery. One delivered frame also does not prove
continued playback.

A foreground notification can trigger a single pause/play attempt, but
JavaScript call ordering is not an acknowledgement that the underlying native
media pipeline has completed foreground restoration. Waiting for `pause` or
`playing` does not add such a guarantee. Native app activation concerns app
lifecycle, not the readiness of an individual video's decoder. WKWebView's
[public suspension control](<https://developer.apple.com/documentation/webkit/wkwebview/setallmediaplaybacksuspended(_:completionhandler:)>)
can coordinate intentional suspension. Its completion handler acknowledges
changing suspension status, not frame delivery.

No documented signal-only detector or guaranteed event-driven recovery for this
silent failure was identified. With a strict ban on elapsed-time heuristics, the
smallest reliable presentation is a static background. A single
activation-triggered pause/play is an experiment, not an established fix. The
existing bounded watchdog has encouraging empirical evidence but does not meet
that constraint. Frame callbacks can improve positive playback confirmation
without solving missing-progress detection.
