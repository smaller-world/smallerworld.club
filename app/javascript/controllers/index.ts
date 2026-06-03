import {
  AlertBridgeController,
  ButtonBridgeController,
  HapticBridgeController,
  NotificationTokenBridgeController,
  // @ts-expect-error - Untyped package
} from "@joemasilotti/bridge-components";

import AccountTimeZoneFormController from "./account_time_zone_form_controller";
import AccountWorldCardsFormController from "./account_world_cards_form_controller";
import { application } from "./application";
import AutoclickController from "./autoclick_controller";
import ClearableFileInputController from "./clearable_file_input_controller";
import ClickController from "./click_controller";
import ClipboardController from "./clipboard_controller";
import ComboboxController from "./combobox_controller";
import ConfettiController from "./confetti_controller";
import CurrentTimeZoneInputController from "./current_time_zone_input_controller";
import DialogController from "./dialog_controller";
import DisabledController from "./disabled_controller";
import EmojiInputController from "./emoji_input_controller";
import EmojiMartController from "./emoji_mart_controller";
import FlashController from "./flash_controller";
import FormController from "./form_controller";
import FrameController from "./frame_controller";
import HelloController from "./hello_controller";
import ImageStackController from "./image_stack_controller";
import InputGroupAddonController from "./input_group_addon_controller";
import IntersectionController from "./intersection_controller";
import LexxyEditorController from "./lexxy_editor_controller";
import MaintainScrollController from "./maintain_scroll_controller";
import PassesBridgeController from "./passes_bridge_controller";
import PhoneNumberInputController from "./phone_number_input_controller";
import RadioGroupController from "./radio_group_controller";
import ReplyInitiationFormController from "./reply_initiation_form_controller";
import ScrollToBottomController from "./scroll_to_bottom_controller";
import StreamedLogMessageController from "./streamed_log_message_controller";
import StreamedToastController from "./streamed_toast_controller";
import TippyController from "./tippy_controller";
import ToasterController from "./toaster_controller";
// @ts-expect-error - Untyped package
import TransitionController from "./transition_controller";
import TransitionGroupController from "./transition_group_controller";
import TurnstileController from "./turnstile_controller";
import UppyDndController from "./uppy_dnd_controller";
import UppyGroupController from "./uppy_group_controller";
import WorldCardFormController from "./world_card_form_controller";
import WorldFormController from "./world_form_controller";

// == Bridge Components
/* eslint-disable @typescript-eslint/no-unsafe-argument */
application.register("alert-bridge", AlertBridgeController);
application.register("button-bridge", ButtonBridgeController);
application.register("haptic-bridge", HapticBridgeController);
application.register(
  "notification-token-bridge",
  NotificationTokenBridgeController,
);
/* eslint-enable @typescript-eslint/no-unsafe-argument */
application.register("passes-bridge", PassesBridgeController);

// == Libraries
application.register("turnstile", TurnstileController);
application.register("tippy", TippyController);
application.register("toaster", ToasterController);

// == Demo
application.register("hello", HelloController);

// == Components ==
application.register("autoclick", AutoclickController);
application.register("scroll-to-bottom", ScrollToBottomController);
application.register("intersection", IntersectionController);
application.register("maintain-scroll", MaintainScrollController);
application.register("click", ClickController);
application.register("flash", FlashController);
application.register("combobox", ComboboxController);
application.register("disabled", DisabledController);
application.register("clipboard", ClipboardController);
application.register("current-time-zone-input", CurrentTimeZoneInputController);
application.register("clearable-file-input", ClearableFileInputController);
application.register("input-group-addon", InputGroupAddonController);
application.register("lexxy-editor", LexxyEditorController);
application.register("phone-number-input", PhoneNumberInputController);
application.register("emoji-mart", EmojiMartController);
application.register("emoji-input", EmojiInputController);
application.register("radio-group", RadioGroupController);
application.register("form", FormController);
application.register("dialog", DialogController);
application.register("uppy-dnd", UppyDndController);
application.register("uppy-group", UppyGroupController);
application.register("image-stack", ImageStackController);
application.register("confetti", ConfettiController);
application.register("frame", FrameController);
application.register("streamed-log-message", StreamedLogMessageController);
application.register("streamed-toast", StreamedToastController);
application.register("transition-group", TransitionGroupController);
application.register("transition", TransitionController); // eslint-disable-line @typescript-eslint/no-unsafe-argument

// == Forms ==
application.register("account-time-zone-form", AccountTimeZoneFormController);
application.register(
  "account-world-cards-form",
  AccountWorldCardsFormController,
);
application.register("world-form", WorldFormController);
application.register("reply-initiation-form", ReplyInitiationFormController);
application.register("world-card-form", WorldCardFormController);

// application.register("otp-input", OtpInputController);
