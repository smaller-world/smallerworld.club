import {
  Anchor,
  type AnchorProps,
  createPolymorphicComponent,
  getThemeColor,
  type MantineColor,
} from "@mantine/core";
import { clsx } from "clsx";
import { type ComponentPropsWithRef, forwardRef } from "react";

import classes from "./AnchorContainer.module.css";

export interface AnchorContainerProps
  extends AnchorProps,
    Omit<ComponentPropsWithRef<"a">, "color" | "style"> {
  borderColor?: MantineColor;
}

const AnchorContainer = createPolymorphicComponent<"a", AnchorContainerProps>(
  forwardRef<HTMLAnchorElement, AnchorContainerProps>(
    ({ borderColor, style, className, children, ...otherProps }, ref) => (
      <Anchor
        {...{ ref }}
        className={clsx("AnchorContainer", classes.container, className)}
        unstyled
        style={[
          style,
          (theme) => ({
            "--ac-active-border-color": getThemeColor(
              borderColor ?? theme.primaryColor,
              theme,
            ),
          }),
        ]}
        {...otherProps}
      >
        {children}
      </Anchor>
    ),
  ),
);

export default AnchorContainer;
