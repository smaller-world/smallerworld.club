import { type CSSProperties, useEffect, useRef, useState } from "react";
import { type Container, createRoot, type Root } from "react-dom/client";
import { type ExternalToast, toast, Toaster } from "sonner";

export type ToastEvent = CustomEvent<{ message: string; type: string }>;

export const createToasterRoot = (container: Container): Root => {
  const root = createRoot(container);
  root.render(
    <>
      <Toaster
        className="toaster group"
        style={
          {
            "--normal-bg": "var(--popover)",
            "--normal-text": "var(--popover-foreground)",
            "--normal-border": "var(--border)",
            "--border-radius": "var(--radius)",
          } as CSSProperties
        }
        toastOptions={{ className: "toast" }}
        position="bottom-center"
      />
      <ToastListener />
    </>,
  );
  return root;
};

const ToastListener = () => {
  const [ready, setReady] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const { current } = ref;
    if (!current) {
      return;
    }

    const listener = (event: ToastEvent) => {
      const { message, type } = event.detail;
      const options: ExternalToast = {};
      switch (type) {
        case "success":
          toast.success(message, options);
          break;
        case "error":
          toast.error(message, options);
          break;
        case "warning":
          toast.warning(message, options);
          break;
        case "info":
          toast.info(message, options);
          break;
        default:
          toast(message, options);
          break;
      }
    };

    // @ts-expect-error - Custom event
    current.addEventListener("toast", listener);
    setReady(true);
    return () => {
      // @ts-expect-error - Custom event
      current.removeEventListener("toast", listener);
    };
  }, []);
  return (
    <div {...{ ref }} {...(ready && { "data-toaster-target": "listener" })} />
  );
};
