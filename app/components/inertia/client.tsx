import PageLayout from "~/components/PageLayout";
import { type PageComponent } from "~/helpers/inertia";
import { type SharedPageProps } from "~/types";

export const preparePage = <Props extends SharedPageProps>(
  page: PageComponent<Props>,
): void => {
  page.layout ??= (children) => <PageLayout>{children}</PageLayout>;
};
