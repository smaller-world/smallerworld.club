import { init } from "emoji-mart";

const loadEmojiData = (): Promise<void> =>
  fetch("https://cdn.jsdelivr.net/npm/@emoji-mart/data")
    .then((response) => response.json())
    .then((data) => init({ data }));

requestIdleCallback(() => {
  void loadEmojiData();
});
