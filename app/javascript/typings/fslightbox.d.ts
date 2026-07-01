interface FsLightboxProps {
  sources?: string[];
  onOpen?: () => void;
  onClose?: () => void;
  onInit?: () => void;
  onShow?: () => void;
}

interface FsLightboxInstance {
  props: FsLightboxProps;
  open(index?: number): void;
  close(): void;
}

type FsLightboxConstructor = new () => FsLightboxInstance;

declare let FsLightbox: FsLightboxConstructor;
declare let fsLightbox: FsLightboxInstance;
declare let fsLightboxInstances: Record<string, FsLightboxInstance>;
declare function refreshFsLightbox(): void;
