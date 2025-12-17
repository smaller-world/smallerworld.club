import { FullStory, isInitialized } from "@fullstory/browser";
import { type FC, useEffect } from "react";

import { prettyFriendName } from "~/helpers/friends";
import { usePage } from "~/helpers/inertia";

const FullStoryTracking: FC = () => {
  const {
    component,
    props: { currentUser, currentFriend },
  } = usePage();

  // == Current user tracking
  useEffect(() => {
    if (!isInitialized()) {
      return;
    }
    if (currentFriend) {
      void FullStory("setIdentityAsync", {
        uid: currentFriend.id,
        properties: {
          displayName: prettyFriendName(currentFriend),
          type: "friend",
        },
        schema: {
          properties: {
            type: "string",
            handle: "string",
          },
        },
        anonymous: false,
      });
      return () => {
        void FullStory("setIdentityAsync", { anonymous: true });
      };
    } else if (currentUser) {
      const { id, name } = currentUser;
      void FullStory("setIdentityAsync", {
        uid: id,
        properties: { displayName: name, type: "user" },
        schema: {
          properties: {
            type: "string",
            handle: "string",
          },
        },
        anonymous: false,
      });
      return () => {
        void FullStory("setIdentityAsync", { anonymous: true });
      };
    }
  }, [currentFriend, currentUser]);

  // == Page tracking
  useEffect(() => {
    if (!isInitialized()) {
      return;
    }
    void FullStory("setPropertiesAsync", {
      type: "page",
      properties: {
        pageName: component,
      },
    });
  }, [component]);

  return null;
};

export default FullStoryTracking;
