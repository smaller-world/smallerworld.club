import {
  Box,
  Button,
  Code,
  Divider,
  Stack,
  Text,
  TextInput,
  Title,
} from "@mantine/core";
import { DatePickerInput } from "@mantine/dates";
import { type FC } from "react";

import { useForm } from "~/helpers/form";
import { formatJSON } from "~/helpers/json";
import routes from "~/helpers/routes";

import "@mantine/dates/styles.css";

const TestForm: FC = () => {
  // == Form
  const { data, getInputProps, submit, submitting } = useForm({
    name: "test-form",
    action: routes.test.submit,
    descriptor: "submit test form",
    initialValues: {
      name: "",
      birthday: "",
    },
    transformValues: (values) => ({
      model: values,
    }),
  });

  return (
    <Stack gap="xs">
      <Title order={3}>Test form</Title>
      <Box component="form" onSubmit={submit}>
        <Stack gap="xs">
          <TextInput
            {...getInputProps("name")}
            label="Name"
            description={
              <>
                The only server-permitted value is:{" "}
                <Text span inherit tt="none">
                  George
                </Text>
              </>
            }
            required
          />
          <DatePickerInput {...getInputProps("birthday")} label="Birthday" />
          <Button type="submit" loading={submitting}>
            Submit
          </Button>
          {data && (
            <>
              <Divider />
              <Stack gap={4}>
                <Text size="sm" fw={600}>
                  Response:
                </Text>
                <Code block>{formatJSON(data)}</Code>
              </Stack>
            </>
          )}
        </Stack>
      </Box>
    </Stack>
  );
};

export default TestForm;
