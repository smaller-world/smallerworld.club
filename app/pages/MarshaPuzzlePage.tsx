import { Head } from "@inertiajs/react";
import { useMantineColorScheme } from "@mantine/core";
import { useViewportSize } from "@mantine/hooks";
import { lazy, Suspense, useEffect } from "react";

import PageLayout from "~/components/PageLayout";
import { type FillPatternOffset } from "~/components/SVGPuzzle";
import { type PageComponent } from "~/helpers/inertia";
import { type SharedPageProps } from "~/types";

const LazySVGPuzzle = lazy(() => import("~/components/SVGPuzzle"));

export interface MarshaPuzzlePageProps extends SharedPageProps {
  puzzleSvg: string;
  pathInitializers: Record<
    string,
    {
      initialPosition: { x: number; y: number };
      fillPatternOffset: FillPatternOffset;
    }
  >;
}

const MarshaPuzzlePage: PageComponent<MarshaPuzzlePageProps> = ({
  puzzleSvg,
  pathInitializers,
}) => {
  const { setColorScheme, clearColorScheme } = useMantineColorScheme();
  useEffect(() => {
    setColorScheme("light");
    return () => {
      clearColorScheme();
    };
  }, []);
  const { width, height } = useViewportSize();
  return (
    <Suspense>
      <LazySVGPuzzle
        svgData={puzzleSvg}
        {...{ width, height, pathInitializers }}
        debugSnapOverlay={true}
      />
    </Suspense>
  );
};

export default MarshaPuzzlePage;

MarshaPuzzlePage.layout = (page) => (
  <PageLayout>
    <Head>
      <title>Marsha's Puzzle</title>
    </Head>
    {page}
  </PageLayout>
);
