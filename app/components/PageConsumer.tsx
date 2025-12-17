import { type Page } from "@inertiajs/core";
import { usePage } from "@inertiajs/react";
import { type ReactElement, type ReactNode, useMemo } from "react";

import { type SharedPageProps } from "~/types";

export interface PageConsumerProps<PageProps extends Record<string, any>> {
  children: (page: Page<PageProps & SharedPageProps>) => ReactNode;
}

const PageConsumer = <PageProps extends Record<string, any>>({
  children,
}: PageConsumerProps<PageProps>): ReactElement => {
  const data = usePage<PageProps & SharedPageProps>();
  const content = useMemo(() => children(data), [children, data]);
  return <>{content}</>;
};

export default PageConsumer;
