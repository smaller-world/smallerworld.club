import {
  Container,
  type ContainerProps,
  getSize,
  getSpacing,
  type MantineSize,
} from "@mantine/core";
import { clsx } from "clsx";
import { type ComponentPropsWithoutRef, type FC } from "react";

export interface PageContainerProps
  extends ContainerProps,
    Omit<ComponentPropsWithoutRef<"div">, "style"> {
  withGutter?: boolean;
  gutterSize?: MantineSize | (string & {}) | number;
}

const PageContainer: FC<PageContainerProps> = ({
  withGutter,
  gutterSize = "md",
  size = "md",
  className,
  style,
  children,
  ...otherProps
}) => {
  return (
    <Container
      {...{ size }}
      p="md"
      w="100%"
      className={clsx("PageContainer", className)}
      style={[
        style,
        withGutter
          ? () => {
              const sizeValue = getSize(size, "container-size");
              const gutterSizeValue = getSpacing(gutterSize);
              const margin = `clamp(0px, calc((100vw - ${sizeValue}) / 2), ${gutterSizeValue})`;
              return {
                marginTop: margin,
                marginBottom: margin,
              };
            }
          : undefined,
      ]}
      {...otherProps}
    >
      {children}
    </Container>
  );
};

export default PageContainer;
