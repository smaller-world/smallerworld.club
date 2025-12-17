import dayjs from "dayjs";
import customParseFormat from "dayjs/plugin/customParseFormat";

export const setupDayjs = (): void => {
  // eslint-disable-next-line import-x/no-named-as-default-member
  dayjs.extend(customParseFormat);
};
