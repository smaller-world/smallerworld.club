import { usePageProps } from "./inertia";

export const useIsAdmin = (): boolean => {
  const { isAdmin: admin } = usePageProps();
  return admin;
};
