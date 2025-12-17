import { AppShell, type AppShellNavbarProps } from "@mantine/core";
import { clsx } from "clsx";
import { type FC } from "react";

import classes from "./AppSidebar.module.css";

export interface AppSidebarProps extends AppShellNavbarProps {}

const AppSidebar: FC<AppSidebarProps> = ({ className, ...otherProps }) => (
  <AppShell.Navbar
    className={clsx(classes.sidebar, className)}
    {...otherProps}
  />
);

export default AppSidebar;
