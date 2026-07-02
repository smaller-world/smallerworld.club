import {
  AlertBridgeController,
  ButtonBridgeController,
  HapticBridgeController,
  // @ts-expect-error - Untyped package
} from "@joemasilotti/bridge-components";
import { IntersectionController, UserFocusController } from "stimulus-library";

import { application } from "./application";
import AsyncItemController from "./async_item_controller";
import AutoclickController from "./autoclick_controller";
import CheckboxController from "./checkbox_controller";
import ClearableFileInputController from "./clearable_file_input_controller";
import ClickController from "./click_controller";
import ClipboardController from "./clipboard_controller";
import CollapseController from "./collapse_controller";
import ComboboxController from "./combobox_controller";
import ConfettiController from "./confetti_controller";
import ConnectionController from "./connection_controller";
import CreateWorldButtonLabelController from "./create_world_button_label_controller";
import CurrentTimeZoneInputController from "./current_time_zone_input_controller";
import DialogController from "./dialog_controller";
import DisableWhileSubmittingController from "./disable_while_submitting_controller";
import DisabledController from "./disabled_controller";
import DropdownMenuController from "./dropdown_menu_controller";
import EmojiInputController from "./emoji_input_controller";
import EmojiMartController from "./emoji_mart_controller";
import EventController from "./event_controller";
import FieldErrorController from "./field_error_controller";
import FlashTextController from "./flash_text_controller";
import ForwardClickController from "./forward_click_controller";
import FrameReloadController from "./frame_reload_controller";
import FrameResetController from "./frame_reset_controller";
import ImageStackController from "./image_stack_controller";
import InputGroupAddonController from "./input_group_addon_controller";
import LexxyEditorController from "./lexxy_editor_controller";
import LightboxController from "./lightbox_controller";
import NotificationBadgeCountBridgeController from "./notification_badge_count_bridge_controller";
import NotificationPermissionBridgeController from "./notification_permission_bridge_controller";
import NotificationTokenBridgeController from "./notification_token_bridge_controller";
import PageLoadBridgeController from "./page_load_bridge_controller";
import PassBridgeController from "./pass_bridge_controller";
import PassesBridgeController from "./passes_bridge_controller";
import PhoneNumberInputController from "./phone_number_input_controller";
import MessagingPlatformDropdownController from "./platform_dropdown_controller";
import PostDraftController from "./post_draft_controller";
import PostDraftInfoController from "./post_draft_info_controller";
import PostTimestampController from "./post_timestamp_controller";
import PostTypeSelectController from "./post_type_select_controller";
import DevicePushTokenInputController from "./push_token_input_controller";
import RadioController from "./radio_controller";
import SelectController from "./select_controller";
import StreamedLogMessageController from "./streamed_log_message_controller";
import StreamedToastController from "./streamed_toast_controller";
import SubmitController from "./submit_controller";
import TippyController from "./tippy_controller";
import ToasterController from "./toaster_controller";
// @ts-expect-error - Untyped package
import TransitionController from "./transition_controller";
import TransitionGroupController from "./transition_group_controller";
import TurnstileController from "./turnstile_controller";
import UppyDndController from "./uppy_dnd_controller";
import UppyGroupController from "./uppy_group_controller";
import WorldPostTypeInputController from "./world_post_type_input_controller";

// == Library helpers
application.register("turnstile", TurnstileController);
application.register("tippy", TippyController);
application.register("toaster", ToasterController);

// == General helpers
application.register("connection", ConnectionController);
application.register("autoclick", AutoclickController);
application.register("frame-reload", FrameReloadController);
application.register("frame-reset", FrameResetController);
application.register("submit", SubmitController);
application.register(
  "disable-while-submitting",
  DisableWhileSubmittingController,
);
application.register("intersection", IntersectionController);
application.register("click", ClickController);
application.register("flash-text", FlashTextController);
application.register("disabled", DisabledController);
application.register("clipboard", ClipboardController);
application.register("confetti", ConfettiController);
application.register("transition-group", TransitionGroupController);
application.register("transition", TransitionController); // eslint-disable-line @typescript-eslint/no-unsafe-argument
application.register("async-item", AsyncItemController);
application.register("user-focus", UserFocusController);
application.register("field-error", FieldErrorController);
application.register("collapse", CollapseController);
application.register("event", EventController);
application.register("lightbox", LightboxController);
application.register("forward-click", ForwardClickController);

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
application.register("pass-bridge", PassBridgeController);
application.register("page-load-bridge", PageLoadBridgeController);
application.register(
  "notification-permission-bridge",
  NotificationPermissionBridgeController,
);
application.register(
  "notification-badge-count-bridge",
  NotificationBadgeCountBridgeController,
);

// == General components
application.register("clearable-file-input", ClearableFileInputController);
application.register("current-time-zone-input", CurrentTimeZoneInputController);
application.register("emoji-input", EmojiInputController);
application.register("phone-number-input", PhoneNumberInputController);
application.register("combobox", ComboboxController);
application.register("input-group-addon", InputGroupAddonController);
application.register("lexxy-editor", LexxyEditorController);
application.register("uppy-dnd", UppyDndController);
application.register("uppy-group", UppyGroupController);
application.register("select", SelectController);
application.register("radio", RadioController);
application.register("checkbox", CheckboxController);
application.register("dropdown-menu", DropdownMenuController);
application.register("dialog", DialogController);
application.register("emoji-mart", EmojiMartController);
application.register("image-stack", ImageStackController);
application.register("streamed-log-message", StreamedLogMessageController);
application.register("streamed-toast", StreamedToastController);

// == Specific components
application.register("device-push-token-input", DevicePushTokenInputController);
application.register("world-post-type-input", WorldPostTypeInputController);
application.register(
  "create-world-button-label",
  CreateWorldButtonLabelController,
);
application.register("post-timestamp", PostTimestampController);
application.register("post-draft", PostDraftController);
application.register("post-draft-info", PostDraftInfoController);
application.register("post-type-select", PostTypeSelectController);
application.register(
  "messaging-platform-dropdown",
  MessagingPlatformDropdownController,
);
