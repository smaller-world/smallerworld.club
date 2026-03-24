export const getMeta = (name: string): string | null | undefined => {
  const el = document.head.querySelector(`meta[name="${name}"][content]`);
  if (el) {
    return el.getAttribute("content");
  }
};
