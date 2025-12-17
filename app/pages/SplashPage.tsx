import { router } from "@inertiajs/react";
import {
  Box,
  Image,
  Stack,
  Text,
  Title,
  useMantineColorScheme,
} from "@mantine/core";
import { type ReactNode, useEffect } from "react";

import AppLayout from "~/components/AppLayout";
import { type PageComponent } from "~/helpers/inertia";
import routes from "~/helpers/routes";
import { type SharedPageProps } from "~/types";

import logoSrc from "~/assets/images/logo.png";

export interface SplashPageProps extends SharedPageProps {}

const SplashPage: PageComponent<SplashPageProps> = () => {
  const { setColorScheme } = useMantineColorScheme();
  useEffect(() => {
    setColorScheme("light");
    setTimeout(() => {
      router.visit(routes.userSpaces.index.path());
    }, 200);
  }, []);
  return (
    <Stack align="center" justify="center" style={{ flexGrow: 1 }}>
      <Title order={2} size="h3" c="dimmed">
        welcome to
      </Title>
      <Image src={logoSrc} h="unset" w={44} />
      <Box ta="center" mb="sm">
        <Title size="h2">smaller world</Title>
        <Text ff="heading" fw={600} c="dimmed">
          please come stay a while :)
        </Text>
      </Box>
    </Stack>
  );
};

SplashPage.layout = (page: ReactNode) => <AppLayout>{page}</AppLayout>;

export default SplashPage;
