import { router } from "@inertiajs/react";

import AppLayout from "~/components/AppLayout";
import NewSpaceForm from "~/components/NewSpaceForm";
import { type PageComponent } from "~/helpers/inertia";
import routes from "~/helpers/routes";
import { useWorldTheme } from "~/helpers/worldThemes";
import { type SharedPageProps } from "~/types";

export interface NewSpacePageProps extends SharedPageProps {}

const NewSpacePage: PageComponent<NewSpacePageProps> = () => {
  useWorldTheme("cloudflow", true);

  return (
    <NewSpaceForm
      onSpaceCreated={(space) => {
        router.visit(routes.spaces.show.path({ id: space.friendly_id }), {
          replace: true,
        });
      }}
    />
  );
};

NewSpacePage.layout = (page) => (
  <AppLayout<NewSpacePageProps>
    title="new space"
    withContainer
    containerSize="xs"
    withGutter
  >
    {page}
  </AppLayout>
);

export default NewSpacePage;
