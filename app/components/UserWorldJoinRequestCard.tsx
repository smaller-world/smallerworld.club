import {
  Anchor,
  Badge,
  Button,
  Card,
  type CardProps,
  CopyButton,
  Group,
  List,
  LoadingOverlay,
  Stack,
  Tooltip,
} from "@mantine/core";
import { clsx } from "clsx";
import { DateTime } from "luxon";
import { type FC, useState } from "react";

import { PhoneIcon, UserIcon } from "~/helpers/icons";
import routes from "~/helpers/routes";
import { mutateRoute, useRouteMutation } from "~/helpers/routes/swr";
import { type JoinRequest } from "~/types";

import AddFriendIcon from "~icons/heroicons/user-plus-20-solid";

import DeleteConfirmation from "./DeleteConfirmation";
import Time from "./Time";

import classes from "./UserWorldJoinRequestCard.module.css";

interface UserWorldJoinRequestCardProps extends CardProps {
  joinRequest: JoinRequest;
  onSelectForInvitation: () => void;
}

const UserWorldJoinRequestCard: FC<UserWorldJoinRequestCardProps> = ({
  joinRequest,
  onSelectForInvitation,
  className,
  ...otherProps
}) => {
  const [deleteStarted, setDeleteStarted] = useState(false);
  const { trigger: triggerDelete } = useRouteMutation(
    routes.userWorldJoinRequests.destroy,
    {
      params: {
        id: joinRequest.id,
      },
      descriptor: "remove join request",
      onSuccess: () => {
        void mutateRoute(routes.userWorldJoinRequests.index);
      },
      onError: () => {
        setDeleteStarted(false);
      },
    },
  );

  return (
    <Card
      className={clsx("UserWorldJoinRequestCard", className, classes.card)}
      withBorder
      {...otherProps}
    >
      <Group align="center" gap="xs" justify="space-between">
        <List className={classes.list}>
          <List.Item icon={<UserIcon />} fw={600}>
            {joinRequest.name}
          </List.Item>
          <List.Item icon={<PhoneIcon />}>
            <CopyButton value={joinRequest.phone_number}>
              {({ copied, copy }) => (
                <Tooltip
                  label={copied ? "copied!" : "copy?"}
                  events={{ hover: true, focus: true, touch: true }}
                  position="right"
                  {...(copied && { opened: true })}
                >
                  <Anchor onClick={copy}>{joinRequest.phone_number}</Anchor>
                </Tooltip>
              )}
            </CopyButton>
          </List.Item>
        </List>
        <Stack gap={4}>
          <Button
            leftSection={<AddFriendIcon />}
            onClick={onSelectForInvitation}
          >
            invite to your world
          </Button>
          <DeleteConfirmation
            label="really dismiss?"
            onConfirm={() => {
              setDeleteStarted(true);
              void triggerDelete();
            }}
          >
            <Anchor component="button" size="xs" c="red" inline>
              dismiss join request
            </Anchor>
          </DeleteConfirmation>
        </Stack>
      </Group>
      <Badge className={classes.timestampBadge} variant="default">
        <Time format={DateTime.DATETIME_MED} inline inherit>
          {joinRequest.created_at}
        </Time>
      </Badge>
      <LoadingOverlay visible={deleteStarted} />
    </Card>
  );
};

export default UserWorldJoinRequestCard;
