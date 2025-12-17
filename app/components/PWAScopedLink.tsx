import { hrefToUrl } from "@inertiajs/core";
import { type InertiaLinkProps } from "@inertiajs/react";
import { Link } from "@inertiajs/react";
import { forwardRef, useEffect, useState } from "react";

import { getPWAScope, usePWA } from "~/helpers/pwa";
import { queryParamsFromPath } from "~/helpers/utils";
export interface PWAScopedLinkProps extends Omit<InertiaLinkProps, "href"> {
  href: string;
}

const PWAScopedLink = forwardRef<HTMLAnchorElement, PWAScopedLinkProps>(
  ({ href, ...otherProps }, ref) => {
    const { isStandalone } = usePWA();
    const [scopedHref, setScopedHref] = useState<string>();
    useEffect(() => {
      const { pwa_scope: previousScope } = queryParamsFromPath(location.href);
      if (previousScope) {
        setScopedHref(addScopeToHref(href, previousScope));
      } else if (isStandalone) {
        const currentScope = getPWAScope();
        if (currentScope) {
          setScopedHref(addScopeToHref(href, currentScope));
        }
      }
    }, [href, isStandalone]);
    return <Link {...{ ref }} href={scopedHref ?? href} {...otherProps} />;
  },
);

export default PWAScopedLink;

const addScopeToHref = (href: string, scope: string) => {
  const url = hrefToUrl(href);
  url.searchParams.set("pwa_scope", scope);
  return url.toString();
};
