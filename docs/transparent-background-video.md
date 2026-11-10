# Transparent background video

Use this recipe for monochrome artwork on a nearly white background. The output
is black linework with a soft opacity mask, in HEVC for iPhone and VP9 for
Android Chrome. Run from the repo root on macOS with an FFmpeg build that
provides `hevc_videotoolbox` and `libvpx-vp9`.

## 1. Inspect the source

```sh
src=design/the_dock.mp4
out="$(mktemp -d)/the_dock-web"

ffprobe -v error -select_streams v:0 -count_frames \
  -show_entries stream=width,height,sample_aspect_ratio,avg_frame_rate,nb_read_frames:format=duration,size \
  "$src"
```

Confirm the intended background from a decoded frame. If the source is supposed
to have transparency already, run the alpha check in step 3 on it. A ProRes 4444
export can advertise an alpha channel while every pixel is opaque. Use an
existing working mask when available. For opaque dark artwork on white, derive
the mask from the original clip.

## 2. Key and encode

Split the source so the mask and the flat black foreground inherit its
resolution and frame timestamps. The mask maps luma values at or above 248 to
transparent, values at or below 6 to opaque, and grays between them to partial
opacity. Adjust the white cutoff if the source leaves a haze in blank areas.
Check the thinnest strokes after changing it. Keep full-color artwork out of
this flat-black recipe.

```sh
key="[0:v]split[base][luma];[base]drawbox=color=black:t=fill[ink];[luma]format=gray,lut=y='clip((248-val)*255/242,0,255)'[mask];[ink][mask]alphamerge[v]"

ffmpeg -i "$src" -filter_complex "$key" -map '[v]' \
  -fps_mode passthrough -enc_time_base demux \
  -c:v hevc_videotoolbox -allow_sw 1 -pix_fmt bgra \
  -alpha_quality 0.70 -b:v 120k -g 121 -tag:v hvc1 -movflags +faststart \
  "$out.mov"

ffmpeg -i "$src" -filter_complex "$key" -map '[v]' \
  -fps_mode passthrough -enc_time_base demux \
  -c:v libvpx-vp9 -pix_fmt yuva420p -crf 27 -b:v 0 \
  -deadline good -cpu-used 2 -row-mt 1 -threads 6 -g 121 \
  "$out.webm"
```

Aim for **500,000 bytes per file**. Lower `-alpha_quality` for a smaller MOV.
The MOV bitrate controls the color layer, so tune alpha quality first. Raise
`-crf` for a smaller WebM. Pick the best version that fits and still keeps the
fine linework readable on the page background.

For the original dock MP4, those settings yielded about 452 KB for MOV and 493
KB for WebM. The source has uneven frame spacing and a short final frame. When
reproducing the dock loop, add the following before the WebM output path to
match its 5.017 s duration. For other clips, use this only if the last frame is
padded, with the source's actual last timestamp and display duration.

```sh
-bsf:v "setts=duration='if(gte(PTS*TB,5),round(1/(60*TB)),DURATION)'"
```

## 3. Verify and embed

Run the step 1 probe on each output. Match the source's dimensions, pixel aspect
ratio and decoded frame count. For variable frame timing, compare
`ffprobe -show_frames -show_entries frame=pts_time` across the clip. WebM rounds
timestamps to milliseconds. Check duration separately for loop seams.

Decode both masks and check representative frames over the intended background.
The commands report the alpha range per frame. Expect values near 0 in blank
areas and near 255 in solid ink. A source that returns 255 for both bounds
throughout is opaque. If checking a source with no alpha plane, the explicit
RGBA conversion adds an opaque plane.

```sh
alpha='format=rgba,alphaextract,signalstats,metadata=mode=print:file=-'
ffmpeg -v error -i "$out.mov" -vf "$alpha" -f null -
ffmpeg -v error -c:v libvpx-vp9 -i "$out.webm" -vf "$alpha" -f null -
```

Use MOV first for Safari and WebM second for Chrome on Android. Safari can
recognize VP9 WebM without rendering its alpha correctly. Serve each file with
its declared MIME type. Verify transparency, inline autoplay, and the loop on
the actual page in iPhone Safari and Android Chrome when devices are available.
Record which checks ran if device playback is unavailable.
[Apple HEVC with alpha](https://developer.apple.com/videos/play/wwdc2019/506/),
[WebKit VP9 alpha issue](https://bugs.webkit.org/show_bug.cgi?id=275908),
[Chrome WebM alpha](https://developer.chrome.com/blog/alpha-transparency-in-chrome-video).

```html
<video autoplay muted loop playsinline aria-hidden="true">
  <source src="the_dock-web.mov" type="video/quicktime" />
  <source src="the_dock-web.webm" type="video/webm" />
</video>
```
