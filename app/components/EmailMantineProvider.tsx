import { MantineProvider } from "@mantine/core";
import { type FC, type PropsWithChildren } from "react";

import { useCreateTheme } from "~/helpers/mantine";

const EmailMantineProvider: FC<PropsWithChildren> = ({ children }) => {
  const theme = useCreateTheme();
  return (
    <MantineProvider
      {...{ theme }}
      {...(import.meta.env.RAILS_ENV === "test" && {
        env: "test",
      })}
    >
      {children}
    </MantineProvider>
  );
};

export default EmailMantineProvider;
