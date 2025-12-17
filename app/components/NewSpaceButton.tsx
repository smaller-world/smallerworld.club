import { router } from "@inertiajs/react";
import { Box, Button, type ButtonProps } from "@mantine/core";
import { clsx } from "clsx";
import { type FC, useState } from "react";

import { isHotwireNative } from "~/helpers/hotwire";
import { SpaceIcon } from "~/helpers/icons";
import routes from "~/helpers/routes";

import DrawerModal from "./DrawerModal";
import NewSpaceForm, { type NewSpaceFormProps } from "./NewSpaceForm";

export interface NewSpaceButtonProps
  extends Pick<NewSpaceFormProps, "onSpaceCreated">,
    Omit<ButtonProps, "children"> {}

const NewSpaceButton: FC<NewSpaceButtonProps> = ({
  onSpaceCreated,
  className,
  ...otherProps
}) => {
  const [drawerModalOpened, setDrawerModalOpened] = useState(false);
  return (
    <>
      <Button
        leftSection={<Box component={SpaceIcon} fz="sm" />}
        className={clsx("NewSpaceButton", className)}
        onClick={() => {
          if (isHotwireNative()) {
            router.visit(routes.userSpaces.new.path());
          } else {
            setDrawerModalOpened(true);
          }
        }}
        {...otherProps}
      >
        create a space
      </Button>
      <DrawerModal
        title="new space"
        opened={drawerModalOpened}
        onClose={() => {
          setDrawerModalOpened(false);
        }}
      >
        <NewSpaceForm
          onSpaceCreated={(space) => {
            setDrawerModalOpened(false);
            onSpaceCreated?.(space);
          }}
        />
      </DrawerModal>
    </>
  );
};

export default NewSpaceButton;
