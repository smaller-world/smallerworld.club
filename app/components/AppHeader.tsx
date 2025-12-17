import { Link } from "@inertiajs/react";
import {
  AppShell,
  type AppShellHeaderProps,
  Button,
  Image,
} from "@mantine/core";
import { Group } from "@mantine/core";
import { clsx } from "clsx";
import { forwardRef } from "react";

import routes from "~/helpers/routes";

import logoSrc from "~/assets/images/logo.png";

import AppMenu from "./AppMenu";

import classes from "./AppHeader.module.css";

export interface AppHeaderProps extends Omit<AppShellHeaderProps, "children"> {
  logoHref?: string;
}

const AppHeader = forwardRef<HTMLDivElement, AppHeaderProps>(
  ({ className, logoHref, ...otherProps }, ref) => (
    <AppShell.Header
      {...{ ref }}
      px={8}
      className={clsx("AppHeader", classes.header, className)}
      {...otherProps}
    >
      <Group gap={4}>
        <Button
          component={Link}
          href={logoHref ?? routes.start.web.path()}
          variant="subtle"
          size="compact-md"
          leftSection={<Image src={logoSrc} h={24} w="unset" />}
          className={classes.logoButton}
        >
          smaller world
        </Button>
      </Group>
      <AppMenu className={classes.menu} />
    </AppShell.Header>
  ),
);

export default AppHeader;
