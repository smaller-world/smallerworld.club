import { type Page } from "@inertiajs/core";
import { useMemo } from "react";

import { usePage } from "~/helpers/inertia";
import { type SharedPageProps } from "~/types";

export type DynamicProp<PageProps extends SharedPageProps, T> =
  | T
  | ((props: PageProps, page: Page<PageProps>) => T);

export const useResolveDynamicProp = <PageProps extends SharedPageProps, T>(
  prop: T | ((props: PageProps, page: Page<PageProps>) => T),
) => {
  const page = usePage<PageProps>();
  return useMemo(() => resolveDynamicProp(prop, page), [prop, page]);
};

export const resolveDynamicProp = <PageProps extends SharedPageProps, T>(
  prop: T | ((props: PageProps, page: Page<PageProps>) => T),
  page: Page<PageProps>,
) => (prop instanceof Function ? prop(page.props, page) : prop);
