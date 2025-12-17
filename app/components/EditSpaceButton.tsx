import { router } from "@inertiajs/react";
import { Button, type ButtonProps } from "@mantine/core";
import { clsx } from "clsx";
import { type FC, useState } from "react";

import { isHotwireNative } from "~/helpers/hotwire";
import { EditIcon } from "~/helpers/icons";
import { usePageDialogOpened } from "~/helpers/pageDialog";
import routes from "~/helpers/routes";

import DrawerModal from "./DrawerModal";
import EditSpaceForm, { type EditSpaceFormProps } from "./EditSpaceForm";

export interface EditSpaceButtonProps
  extends Pick<EditSpaceFormProps, "space" | "onSpaceUpdated">,
    Omit<ButtonProps, "children"> {}

const EditSpaceButton: FC<EditSpaceButtonProps> = ({
  space,
  onSpaceUpdated,
  className,
  ...otherProps
}) => {
  const [drawerModalOpened, setDrawerModalOpened] = useState(false);
  usePageDialogOpened(drawerModalOpened);
  return (
    <>
      <Button
        leftSection={<EditIcon />}
        className={clsx("EditSpaceButton", className)}
        onClick={() => {
          if (isHotwireNative()) {
            router.visit(
              routes.userSpaces.edit.path({ id: space.friendly_id }),
            );
          } else {
            setDrawerModalOpened(true);
          }
        }}
        data-controller="button-bridge"
        data-bridge-title="edit"
        {...otherProps}
      >
        edit space
      </Button>
      <DrawerModal
        title="edit space"
        opened={drawerModalOpened}
        onClose={() => {
          setDrawerModalOpened(false);
        }}
      >
        <EditSpaceForm
          space={space}
          onSpaceUpdated={(space) => {
            setDrawerModalOpened(false);
            onSpaceUpdated?.(space);
          }}
        />
      </DrawerModal>
    </>
  );
};

export default EditSpaceButton;
