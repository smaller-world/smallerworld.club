import { useMantineTheme } from "@mantine/core";
import { useMediaQuery } from "@mantine/hooks";

export const useIsMobileSize = (): boolean | undefined => {
  const { breakpoints } = useMantineTheme();
  return useMediaQuery(`(max-width: ${breakpoints.xs})`);
};
