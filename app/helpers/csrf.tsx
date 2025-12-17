import { router } from "@inertiajs/react";
import { Button } from "@mantine/core";
import { toast } from "sonner";

import { type PageCSRF, type SharedPageProps } from "~/types";

import ReloadIcon from "~icons/heroicons/arrow-path-rounded-square-20-solid";

import { usePageProps } from "./inertia";

export const useCSRFToken = (): string => {
  const { csrf } = usePageProps();
  return csrf.token;
};

export const isCSRFVerificationError = (error: any): boolean => {
  let message: string | undefined = undefined;
  if (error instanceof Error) {
    message = error.message;
  } else if (typeof error === "string") {
    message = error;
  }
  return message === "Can't verify CSRF token authenticity.";
};

const INVALID_CSRF_TOKEN_TOAST_ID = "invalid-csrf-token";

export const toastInvalidCSRFToken = (): void => {
  toast.error("this page has expired", {
    id: INVALID_CSRF_TOKEN_TOAST_ID,
    description: "please reload this page to continue",
    action: (
      <Button
        size="compact-sm"
        leftSection={<ReloadIcon />}
        style={{ flexShrink: 0 }}
        onClick={() => {
          location.reload();
        }}
      >
        reload
      </Button>
    ),
  });
};

export const reloadCSRF = (): Promise<PageCSRF> =>
  new Promise((resolve, reject) => {
    router.reload({
      only: ["csrf"],
      async: true,
      onSuccess: ({ props }) => {
        const { csrf } = props as unknown as SharedPageProps;
        resolve(csrf);
      },
      onFinish: (visit) => {
        if (!visit.completed) {
          reject(new Error("Failed to reload CSRF token"));
        }
      },
    });
  });
