import { type BoxProps, Button } from "@mantine/core";
import { useInViewport } from "@mantine/hooks";
import { type FC, type PropsWithChildren, useEffect } from "react";

export interface LoadMoreButtonProps extends PropsWithChildren, BoxProps {
  loading: boolean;
  onVisible: () => void;
}

const LoadMoreButton: FC<LoadMoreButtonProps> = ({
  children,
  onVisible,
  ...otherProps
}) => {
  const { ref, inViewport } = useInViewport();
  useEffect(() => {
    if (inViewport) {
      onVisible();
    }
  }, [inViewport]);
  return (
    <Button {...{ ref }} {...otherProps}>
      {children ?? "load more"}
    </Button>
  );
};

export default LoadMoreButton;
