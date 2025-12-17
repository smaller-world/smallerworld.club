import { ModalsProvider } from "@mantine/modals";
import { type FC, type PropsWithChildren } from "react";

import AmplitudeTracking from "./AmplitudeTracking";
import AppFlash from "./AppFlash";
import CannyTracking from "./CannyTracking";
import ClarityTracking from "./ClarityTracking";
import FullStoryTracking from "./FullStoryTracking";
import MiniProfilerPageTracking from "./MiniProfilerPageTracking";
import PageMeta from "./PageMeta";
import PWAProvider from "./PWAProvider";
import SentryTracking from "./SentryTracking";
import WebPushProvider from "./WebPushProvider";

import "@mantine/core/styles.layer.css";
import "@fontsource-variable/manrope";
import "@fontsource-variable/bricolage-grotesque";

const PageLayout: FC<PropsWithChildren> = ({ children }) => (
  <>
    <PageMeta />
    <PWAProvider>
      <WebPushProvider>
        <ModalsProvider modalProps={{ size: "md" }}>{children}</ModalsProvider>
      </WebPushProvider>
    </PWAProvider>
    <AppFlash />
    <SentryTracking />
    <FullStoryTracking />
    <ClarityTracking />
    <AmplitudeTracking />
    <CannyTracking />
    <MiniProfilerPageTracking />
  </>
);

export default PageLayout;
