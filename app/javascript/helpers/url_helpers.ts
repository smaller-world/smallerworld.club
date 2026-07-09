export const urlPathWithQuery = (url: string): string => {
  const { pathname, search } = new URL(url, window.location.origin);
  return search ? `${pathname}${search}` : pathname;
};
