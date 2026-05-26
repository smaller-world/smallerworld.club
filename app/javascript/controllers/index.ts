import { application } from "./application";
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
import PhoneNumberInputController from "./phone_number_input_controller";
import RadioGroupController from "./radio_group_controller";
import ScrollToBottomController from "./scroll_to_bottom_controller";
import TippyController from "./tippy_controller";
import TurnstileController from "./turnstile_controller";
import UppyDndController from "./uppy_dnd_controller";
import UppyGroupController from "./uppy_group_controller";
import WorldFormController from "./world_form_controller";

// == Demo
application.register("hello", HelloController);

// == Services
application.register("turnstile", TurnstileController);

application.register("tippy", TippyController);
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
application.register("world-form", WorldFormController);
application.register("radio-group", RadioGroupController);
application.register("form", FormController);
application.register("dialog", DialogController);
application.register("uppy-dnd", UppyDndController);
application.register("uppy-group", UppyGroupController);
application.register("image-stack", ImageStackController);
application.register("confetti", ConfettiController);
application.register("frame", FrameController);

// application.register("otp-input", OtpInputController);
