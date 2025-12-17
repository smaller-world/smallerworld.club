import { type BoxProps, Group } from "@mantine/core";
import { useInViewport, useMergedRef } from "@mantine/hooks";
import { clsx } from "clsx";
import { groupBy, isEmpty } from "lodash-es";
import { type FC, useMemo } from "react";

import { useCurrentFriend } from "~/helpers/authentication";
import { useTrackPostSeen } from "~/helpers/posts";
import routes from "~/helpers/routes";
import { useRouteSWR } from "~/helpers/routes/swr";
import {
  type PostReaction,
  type SpacePost,
  type UniversePost,
  type UniversePostAssociatedFriend,
  type WorldPost,
} from "~/types";

import NewPostReactionButton from "./NewPostReactionButton";
import PostReactionButton from "./PostReactionButton";

export interface PublicPostCardActionsProps extends Omit<BoxProps, "children"> {
  post: WorldPost | UniversePost | SpacePost;
}

const PublicPostCardActions: FC<PublicPostCardActionsProps> = ({
  post,
  className,
  ...otherProps
}) => {
  const { ref: viewportRef, inViewport } = useInViewport();
  const currentFriend = useCurrentFriend();
  let asFriend: UniversePostAssociatedFriend | undefined;
  if ("associated_friend" in post) {
    asFriend = post.associated_friend;
  }

  // == Track views
  const trackSeenRef = useTrackPostSeen(post, {
    skip: post.seen || (!currentFriend && post.visibility !== "public"),
  });

  // == Load reactions
  const { data } = useRouteSWR<{ reactions: PostReaction[] }>(
    routes.postReactions.index,
    {
      params: { post_id: post.id },
      descriptor: "load reactions",
      keepPreviousData: true,
      refreshInterval: 5000,
      isVisible: () => inViewport,
    },
  );
  const { reactions } = data ?? {};
  const reactionsByEmoji = useMemo(
    () => groupBy(reactions, "emoji"),
    [reactions],
  );

  const mergedRef = useMergedRef(viewportRef, trackSeenRef);
  return (
    <Group
      ref={mergedRef}
      align="start"
      gap={2}
      wrap="wrap"
      className={clsx("PublicPostCardActions", className)}
      {...otherProps}
    >
      <Group gap={2} wrap="wrap" style={{ flexGrow: 1, rowGap: 0 }}>
        {Object.entries(reactionsByEmoji).map(([emoji, reactions]) => (
          <PostReactionButton
            key={emoji}
            {...{ post, emoji, reactions, asFriend }}
          />
        ))}
      </Group>
      <Group justify="end" gap={2} style={{ flexGrow: 1 }}>
        <NewPostReactionButton
          {...{ post, asFriend }}
          hasExistingReactions={!isEmpty(reactions)}
        />
      </Group>
    </Group>
  );
};

export default PublicPostCardActions;
