import { Alert, type AlertProps, Stack, Text, Transition } from "@mantine/core";
import { clsx } from "clsx";
import { type FC } from "react";

import { NotificationIcon } from "~/helpers/icons";
import { usePageProps } from "~/helpers/inertia";
import { type PostSharePageProps } from "~/pages/PostSharePage";

import JoinRequestForm from "./JoinRequestForm";

import classes from "./PostSharePageRequestInvitationAlert.module.css";

export interface PostSharePageRequestInvitationAlertProps
  extends Omit<AlertProps, "children"> {}

const PostSharePageRequestInvitationAlert: FC<
  PostSharePageRequestInvitationAlertProps
> = ({ style, className, ...otherProps }) => {
  const { world, invitationRequested } = usePageProps<PostSharePageProps>();
  return (
    <Transition transition="pop" mounted={!invitationRequested}>
      {(transitionStyle) => (
        <Alert
          variant="default"
          icon={<NotificationIcon />}
          title="hear more about what's going on in my life :)"
          className={clsx(
            "PostSharePageRequestInvitationAlert",
            classes.alert,
            className,
          )}
          style={[style, transitionStyle]}
          {...otherProps}
        >
          <Stack gap={8}>
            <Text inherit>
              get notified about my thoughts, ideas, and invitations to events
              i&apos;m going to.
            </Text>
            <JoinRequestForm {...{ world }} />
          </Stack>
        </Alert>
      )}
    </Transition>
  );
};

export default PostSharePageRequestInvitationAlert;
