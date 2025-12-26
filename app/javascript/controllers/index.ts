import {
  AlertBridgeController,
  ButtonBridgeController,
  HapticBridgeController,
  // @ts-expect-error - Untyped package
} from "@joemasilotti/bridge-components";
import RevealController from "@stimulus-components/reveal";
import TextareaAutogrowController from "stimulus-textarea-autogrow";

import { application } from "./application";
import BusyReporterController from "./busy_reporter_controller";
import ClickOnAppearController from "./click_on_appear_controller";
import ClipboardController from "./clipboard_controller";
import DropdownController from "./dropdown_controller";
import ElementRemovalController from "./element_removal_controller";
import EmojiFieldController from "./emoji_field_controller";
import EmojiMartController from "./emoji_mart_controller";
import FilepondController from "./filepond_controller";
import HelloController from "./hello_controller";
import ModalController from "./modal_controller";

// == Native bridge components ==
/* eslint-disable @typescript-eslint/no-unsafe-argument */
application.register("alert-bridge", AlertBridgeController);
application.register("button-bridge", ButtonBridgeController);
application.register("haptic-bridge", HapticBridgeController);
/* eslint-enable @typescript-eslint/no-unsafe-argument */

application.register("dropdown", DropdownController);
application.register("reveal", RevealController);
application.register("textarea-autogrow", TextareaAutogrowController);

application.register("element-removal", ElementRemovalController);
application.register("hello", HelloController);
application.register("filepond", FilepondController);
application.register("busy-reporter", BusyReporterController);
application.register("modal", ModalController);
application.register("emoji-mart", EmojiMartController);
application.register("emoji-field", EmojiFieldController);
application.register("clipboard", ClipboardController);
application.register("click-on-appear", ClickOnAppearController);
