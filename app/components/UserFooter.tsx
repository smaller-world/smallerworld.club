import { router } from "@inertiajs/react";
import {
  AppShell,
  type AppShellFooterProps,
  Group,
  Image,
  SegmentedControl,
  type SegmentedControlItem,
} from "@mantine/core";
import { useDidUpdate } from "@mantine/hooks";
import { clsx } from "clsx";
import {
  type FC,
  forwardRef,
  type ReactNode,
  startTransition,
  useMemo,
  useState,
} from "react";

import { usePage } from "~/helpers/inertia/page";
import routes from "~/helpers/routes";
import { withTrailingSlash } from "~/helpers/utils";
import { WORLD_ICON_RADIUS_RATIO } from "~/helpers/worlds";
import { type UserUniversePageProps } from "~/pages/UserUniversePage";
import { type UserWorldPageProps } from "~/pages/UserWorldPage";
import { type User, type World } from "~/types";

import logoSrc from "~/assets/images/logo.png";

import classes from "./UserFooter.module.css";

export interface UserFooterProps extends Omit<AppShellFooterProps, "children"> {
  currentUser: User;
  world: World | null;
}

const WORLD_ICON_SIZE = 18;

const UserFooter = forwardRef<HTMLDivElement, UserFooterProps>(
  ({ currentUser, world, className, ...otherProps }, ref) => {
    const { url } = usePage<UserWorldPageProps | UserUniversePageProps>();
    const [value, setValue] = useState<"world" | "universe" | "spaces">(
      urlValue(url),
    );
    useDidUpdate(() => {
      setValue(urlValue(url));
    }, [url, setValue]);
    const controls = useMemo<SegmentedControlItem[]>(() => {
      const controls: SegmentedControlItem[] = [
        {
          value: "world",
          label: (
            <NavItem
              text="your world"
              icon={
                world?.icon ? (
                  <Image
                    src={world.icon.src}
                    {...(!!world.icon.srcset && {
                      srcSet: world.icon.srcset,
                    })}
                    h={WORLD_ICON_SIZE}
                    w={WORLD_ICON_SIZE}
                    radius={WORLD_ICON_SIZE / WORLD_ICON_RADIUS_RATIO}
                  />
                ) : (
                  <Image src={logoSrc} h={WORLD_ICON_SIZE} w="unset" />
                )
              }
            />
          ),
        },
        {
          value: "universe",
          label: (
            <NavItem
              text="universe"
              icon={<Image src={logoSrc} h={18} w="unset" />}
            />
          ),
        },
      ];
      if (
        value === "spaces" ||
        currentUser.supported_features.includes("spaces")
      ) {
        controls.push({
          value: "spaces",
          label: (
            <NavItem
              text="spaces"
              icon={<span className={classes.spaceEmoji}>🪐</span>}
            />
          ),
        });
      }
      return controls;
    }, [currentUser, world, value]);
    return (
      <AppShell.Footer
        {...{ ref }}
        px={8}
        className={clsx("AppFooter", classes.footer, className)}
        {...otherProps}
      >
        <SegmentedControl
          data={controls}
          {...{ value }}
          onChange={(value) => {
            switch (value) {
              case "world":
                setValue(value);
                startTransition(() => {
                  router.visit(withTrailingSlash(routes.userWorld.show.path()));
                });
                break;
              case "universe":
                setValue(value);
                startTransition(() => {
                  router.visit(routes.userUniverse.show.path());
                });
                break;
              case "spaces":
                setValue(value);
                startTransition(() => {
                  router.visit(routes.userSpaces.index.path());
                });
                break;
            }
          }}
          className={classes.segmentedControl}
        />
      </AppShell.Footer>
    );
  },
);

export default UserFooter;

interface NavItemLabel {
  text: string;
  icon: ReactNode;
}

const NavItem: FC<NavItemLabel> = ({ text, icon }) => (
  <Group gap={6}>
    {icon}
    {text}
  </Group>
);

const urlValue = (url: string): "world" | "universe" | "spaces" =>
  url.startsWith(routes.userUniverse.show.path())
    ? "universe"
    : url.startsWith(routes.userSpaces.index.path()) ||
        url.startsWith("/spaces/")
      ? "spaces"
      : "world";
