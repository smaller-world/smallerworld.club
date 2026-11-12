import { Controller } from "@hotwired/stimulus";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

export default class AutoplayController extends Controller<HTMLVideoElement> {
  #playbackCheck: number | undefined;
  #playbackAttempt = 0;
  #frameCallback: number | undefined;

  // == Lifecycle ==

  connect(): void {
    addBeforeCacheAction(this, "pause");
  }

  disconnect(): void {
    this.cancelPlaybackCheck();
  }

  // == Actions ==

  resume(): void {
    this.cancelPlaybackCheck();
    if (document.visibilityState !== "visible") {
      return;
    }

    const generation = this.#playbackAttempt;
    let attempts = 0;
    let healthyChecks = 0;
    let frameProgress = 0;
    let checkedProgress = 0;
    let lastFrame: VideoFrameCallbackMetadata | undefined;

    const observeFrame: VideoFrameRequestCallback = (_now, metadata) => {
      if (generation !== this.#playbackAttempt) return;
      if (
        lastFrame &&
        metadata.presentedFrames > lastFrame.presentedFrames &&
        metadata.mediaTime !== lastFrame.mediaTime
      ) {
        frameProgress++;
      }
      lastFrame = metadata;
      this.#frameCallback =
        this.element.requestVideoFrameCallback(observeFrame);
    };
    this.#frameCallback = this.element.requestVideoFrameCallback(observeFrame);

    const check = (): void => {
      if (document.visibilityState !== "visible" || this.element.paused) {
        this.cancelPlaybackCheck();
        return;
      }

      const progressing = frameProgress > checkedProgress;
      checkedProgress = frameProgress;
      healthyChecks = progressing ? healthyChecks + 1 : 0;

      if (healthyChecks >= 2) {
        this.cancelPlaybackCheck();
        return;
      }

      if (progressing) {
        this.#playbackCheck = setTimeout(check, 200);
      } else if (attempts < 5) {
        play();
      } else {
        this.cancelPlaybackCheck();
        throw new Error(
          `Video frames stopped progressing after ${attempts} playback attempts ` +
            `(mediaTime=${lastFrame?.mediaTime}, presentedFrames=${lastFrame?.presentedFrames})`,
        );
      }
    };

    const play = (): void => {
      attempts++;
      void this.#play().then(
        () => {
          if (generation !== this.#playbackAttempt) return;
          this.#playbackCheck = setTimeout(check, 200);
        },
        () => {
          if (generation === this.#playbackAttempt) {
            this.cancelPlaybackCheck();
          }
        },
      );
    };

    play();
  }

  pause(): void {
    this.cancelPlaybackCheck();
    this.element.pause();
  }

  cancelPlaybackCheck(): void {
    this.#playbackAttempt++;
    clearTimeout(this.#playbackCheck);
    this.#playbackCheck = undefined;
    if (this.#frameCallback !== undefined) {
      this.element.cancelVideoFrameCallback(this.#frameCallback);
      this.#frameCallback = undefined;
    }
  }

  // == Helpers ==

  #play(): Promise<void> {
    return this.element.play().catch((error: Error) => {
      if (error.name === "NotAllowedError") {
        this.dispatch("denied");
      } else {
        console.warn("Video autoplay failed", error);
      }
      throw error;
    });
  }
}
