import { type Page } from "@inertiajs/core";
import { type FC, type PropsWithChildren } from "react";

import ActionCableProvider from "./ActionCableProvider";
import AppMantineProvider from "./AppMantineProvider";
import AppNavProgress from "./AppNavProgress";
import Toaster from "./Toaster";

export interface AppWrapperProps extends PropsWithChildren {
  initialPage: Page;
}

const AppWrapper: FC<AppWrapperProps> = ({ children }) => (
  <ActionCableProvider>
    <AppMantineProvider>
      <AppNavProgress />
      <Toaster />
      {children}
    </AppMantineProvider>
  </ActionCableProvider>
);

export default AppWrapper;
