import { Link, router } from "@inertiajs/react";
import {
  Box,
  Button,
  Group,
  Image,
  Overlay,
  rem,
  RemoveScroll,
  Skeleton,
  Space as MantineSpace,
  Stack,
  Text,
  Title,
} from "@mantine/core";
import { useModals } from "@mantine/modals";
import { isEmpty } from "lodash-es";
import { useEffect } from "react";
import { toast } from "sonner";

import { EmptyCard } from "~/components";
import AppInstallAlert from "~/components/AppInstallAlert";
import AppLayout from "~/components/AppLayout";
import EditSpaceButton from "~/components/EditSpaceButton";
import LoadMoreButton from "~/components/LoadMoreButton";
import PostCard from "~/components/PostCard";
import SpacePageFloatingActions from "~/components/SpacePageFloatingActions";
import SpacePageNotificationsButton from "~/components/SpacePageNotificationsButton";
import SpacePostCardAuthorActions from "~/components/SpacePostCardAuthorActions";
import SpacePostCardFriendActions from "~/components/SpacePostCardFriendActions";
import UserFooter from "~/components/UserFooter";
import { useCurrentUser } from "~/helpers/authentication";
import { useIsHotwireNative } from "~/helpers/hotwire";
import { BackIcon } from "~/helpers/icons";
import { type PageComponent, useQueryParams } from "~/helpers/inertia";
import { openAppInstallModal } from "~/helpers/install";
import { isStandaloneDisplayMode, usePWA } from "~/helpers/pwa";
import routes from "~/helpers/routes";
import { useSpacePosts } from "~/helpers/spaces";
import {
  normalizeUrl,
  queryParamsFromPath,
  withTrailingSlash,
} from "~/helpers/utils";
import { useWebPush } from "~/helpers/webPush";
import { WORLD_ICON_RADIUS_RATIO } from "~/helpers/worlds";
import { useWorldTheme } from "~/helpers/worldThemes";
import { type SharedPageProps, type Space, type World } from "~/types";

import swirlyUpArrowSrc from "~/assets/images/swirly-up-arrow.png";

import classes from "./SpacePage.module.css";

export interface SpacePageProps extends SharedPageProps {
  space: Space;
  userWorld: World | null;
}

const SPACE_ICON_SIZE = 96;

const SpacePage: PageComponent<SpacePageProps> = ({ space }) => {
  useWorldTheme("cloudflow");

  const currentUser = useCurrentUser();
  const queryParams = useQueryParams();
  const isNative = useIsHotwireNative();
  const isOwner = currentUser?.id === space.owner_id;
  const { isStandalone, outOfPWAScope } = usePWA();
  const {
    pushRegistration,
    supported: webPushSupported,
    permission: webPushPermission,
  } = useWebPush();
  const { modals } = useModals();

  // == Load posts
  const { posts, hasMorePosts, setSize, isValidating } = useSpacePosts(
    space.id,
  );

  // == Auto-open install modal
  useEffect(() => {
    const { intent } = queryParamsFromPath(location.href);
    if (intent === "install" && isEmpty(modals) && !isStandaloneDisplayMode()) {
      openAppInstallModal();
    }
  }, []);

  const body = (
    <Stack>
      {currentUser && (
        <Button
          component={Link}
          href={routes.userSpaces.index.path()}
          leftSection={<BackIcon />}
          className={classes.backButton}
        >
          your spaces
        </Button>
      )}
      <Box pos="relative">
        <Stack gap="xs" align="center">
          {space.icon ? (
            <Image
              className={classes.spaceIcon}
              src={space.icon.src}
              {...(!!space.icon.srcset && { srcSet: space.icon.srcset })}
              w={SPACE_ICON_SIZE}
              h={SPACE_ICON_SIZE}
              radius={SPACE_ICON_SIZE / WORLD_ICON_RADIUS_RATIO}
              onClick={() => {
                const pageUrl = normalizeUrl(
                  routes.spaces.show.path({
                    id: space.friendly_id,
                  }),
                );
                void navigator.clipboard.writeText(pageUrl).then(() => {
                  toast.success("space url copied");
                });
              }}
            />
          ) : (
            <>{currentUser && isNative === false && <MantineSpace h="lg" />}</>
          )}
          <Box ta="center">
            <Title size="h2" className={classes.spaceName}>
              {space.name}
            </Title>
            <Text size="xs" c="dimmed">
              {space.description}
            </Text>
          </Box>
          {isStandalone && !outOfPWAScope && <SpacePageNotificationsButton />}
        </Stack>
        {isOwner && (
          <EditSpaceButton
            {...{ space }}
            variant="default"
            size="compact-xs"
            pos="absolute"
            top={0}
            right={0}
            styles={{ section: { marginRight: rem(6) } }}
            onSpaceUpdated={(space) => {
              router.visit(routes.spaces.show.path({ id: space.friendly_id }), {
                only: ["space"],
              });
            }}
          />
        )}
      </Box>
      <Box pos="relative">
        <Stack>
          {isNative === false &&
            (isStandalone === false || outOfPWAScope) &&
            !!currentUser && (
              <AppInstallAlert>
                get notified about new posts in{" "}
                <Text span inherit fw={600}>
                  {space.name}
                </Text>{" "}
                :)
              </AppInstallAlert>
            )}
          {posts ? (
            isEmpty(posts) ? (
              <EmptyCard itemLabel="posts" />
            ) : (
              <>
                {posts.map((post) => (
                  <PostCard
                    key={post.id}
                    {...{ post }}
                    author={{
                      name: post.author_name,
                      world: post.author_world,
                    }}
                    focus={queryParams.post_id === post.id}
                    actions={
                      post.author_id === currentUser?.id ? (
                        <SpacePostCardAuthorActions {...{ space, post }} />
                      ) : (
                        <SpacePostCardFriendActions {...{ post }} />
                      )
                    }
                  />
                ))}
                {hasMorePosts && (
                  <LoadMoreButton
                    loading={isValidating}
                    style={{ alignSelf: "center" }}
                    onVisible={() => {
                      void setSize((size) => size + 1);
                    }}
                  />
                )}
              </>
            )
          ) : (
            [...new Array(3)].map((_, i) => <Skeleton key={i} h={120} />)
          )}
        </Stack>
        {isStandalone &&
          !outOfPWAScope &&
          pushRegistration === null &&
          webPushSupported !== false &&
          webPushPermission !== "denied" && (
            <Overlay backgroundOpacity={0} blur={3}>
              <Group justify="center" align="end" gap="xs">
                <Text className={classes.notificationsRequiredIndicatorText}>
                  pretty&nbsp;please? 👉&#8288;👈
                </Text>
                <Image
                  src={swirlyUpArrowSrc}
                  className={classes.notificationsRequiredIndicatorArrow}
                />
              </Group>
            </Overlay>
          )}
      </Box>
    </Stack>
  );
  return (
    <>
      <RemoveScroll
        enabled={
          isNative === false &&
          isStandalone &&
          !outOfPWAScope &&
          !pushRegistration &&
          webPushSupported !== false &&
          webPushPermission !== "denied"
        }
      >
        {body}
      </RemoveScroll>
      <SpacePageFloatingActions />
    </>
  );
};

SpacePage.layout = (page) => (
  <AppLayout<SpacePageProps>
    title={({ space }) => space.name}
    manifestUrl={routes.userManifest.show.path()}
    pwaScope={withTrailingSlash(routes.landing.show.path())}
    footer={({ currentUser, userWorld }) =>
      currentUser ? <UserFooter {...{ currentUser }} world={userWorld} /> : null
    }
    withContainer
    containerSize="xs"
    withGutter
  >
    {page}
  </AppLayout>
);

export default SpacePage;
