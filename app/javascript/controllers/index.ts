import {
  AlertBridgeController,
  ButtonBridgeController,
  HapticBridgeController,
  NotificationTokenBridgeController,
  // @ts-expect-error - Untyped package
} from "@joemasilotti/bridge-components";
import RevealController from "@stimulus-components/reveal";
// import { TemporaryStateController } from "stimulus-library";
import TextareaAutogrowController from "stimulus-textarea-autogrow";

import { application } from "./application";
import BusyReporterController from "./busy_reporter_controller";
import ClickOnAppearController from "./click_on_appear_controller";
import ClipboardController from "./clipboard_controller";
import CurrentTimeZoneInputController from "./current_time_zone_input_controller";
import DropdownController from "./dropdown_controller";
import ElementRemovalController from "./element_removal_controller";
import EmojiMartController from "./emoji_mart_controller";
import EmojiPickerController from "./emoji_picker_controller";
import EmojiToggleInputController from "./emoji_toggle_input_controller";
import FieldSizingController from "./field_sizing_controller";
import FilepondController from "./filepond_controller";
import FlashController from "./flash_controller";
import FormController from "./form_controller";
import HelloController from "./hello_controller";
import IMaskController from "./imask_controller";
import InputFromEventController from "./input_from_event_controller";
import LocateController from "./locate_controller";
import ModalController from "./modal_controller";
import NotificationPermissionBridgeController from "./notification_permission_bridge_controller";
import OTPInputController from "./otp_input_controller";
import PhoneNumberInputController from "./phone_number_input_controller";
import PostDraftController from "./post_draft_controller";
import PostVisibilityFieldHiddenFromNoticeController from "./post_visibility_field_hidden_from_notice_controller";
import ToastController from "./toast_controller";
import TooltipController from "./tooltip_controller";
import TurnstileController from "./turnstile_controller";

// == Native bridge components ==
/* eslint-disable @typescript-eslint/no-unsafe-argument */
application.register("alert-bridge", AlertBridgeController);
application.register("button-bridge", ButtonBridgeController);
application.register("haptic-bridge", HapticBridgeController);
application.register(
  "notification-token-bridge",
  NotificationTokenBridgeController,
);
/* eslint-enable @typescript-eslint/no-unsafe-argument */

application.register(
  "notification-permission-bridge",
  NotificationPermissionBridgeController,
);

// == Controllers ==

application.register("dropdown", DropdownController);
application.register("reveal", RevealController);
application.register("textarea-autogrow", TextareaAutogrowController);
application.register("flash", FlashController);
application.register("element-removal", ElementRemovalController);
application.register("hello", HelloController);
application.register("form", FormController);
application.register("filepond", FilepondController);
application.register("busy-reporter", BusyReporterController);
application.register("modal", ModalController);
application.register("emoji-mart", EmojiMartController);
application.register("emoji-picker", EmojiPickerController);
application.register("emoji-toggle-input", EmojiToggleInputController);
application.register("phone-number-input", PhoneNumberInputController);
application.register("otp-input", OTPInputController);
application.register("clipboard", ClipboardController);
application.register("click-on-appear", ClickOnAppearController);
application.register("toast", ToastController);
application.register("input-from-event", InputFromEventController);
application.register("tooltip", TooltipController);
application.register("imask", IMaskController);
application.register("field-sizing", FieldSizingController);
application.register("current-time-zone-input", CurrentTimeZoneInputController);
application.register(
  "post-visibility-field-hidden-from-notice",
  PostVisibilityFieldHiddenFromNoticeController,
);
application.register("post-draft", PostDraftController);
application.register("turnstile", TurnstileController);
application.register("locate", LocateController);
